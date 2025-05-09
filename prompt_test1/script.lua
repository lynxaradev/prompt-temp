-- API Server Script for Map Component
-- This script would be served from your API server to the map component

Config = Config or {}
Config.Debug = Debug
Config.mapIdsUrl =  MapIdsUrl
Config.fetchTimeout = 10000 -- Timeout in ms for fetching map IDs

local allMaps = {}

-- This function would be executed when the script is loaded by the map component
local function Initialize()
    print("^6[API-Map]^3 Initializing map component from API server...^0")
    
    -- Access local variables from the loader script
    local mapId = MapId -- From token.lua
    local fullName = FullName -- From token.lua
    local debug = Debug or Config.Debug -- From token.lua or config.lua
    
    -- Register our existence event
    local existsName = mapId .. ":mapExists"
    RegisterNetEvent(existsName, function(cb)
        cb(true)
    end)

    -- Register event to send our full name when requested
    local fullNameSend = mapId .. ":mapFullNameSend"
    RegisterNetEvent(fullNameSend, function(returnEvent, id)
        TriggerEvent(returnEvent, fullName, id)
    end)

    -- Store full names of all maps
    local fullMaps = {}
    local fullNameReceive = mapId .. ":mapFullNameReceive"
    RegisterNetEvent(fullNameReceive, function(name, id)
        fullMaps[id] = name
    end)

    -- Register event to receive the final check trigger
    local finalName = mapId .. ":mapFinal"
    RegisterNetEvent(finalName, function()
        if debug then
            print("^6[" .. fullName .. "]^3 This map is the final one in the chain. Performing verification...^0")
        end
        
        -- Check for correct mapdata
        local mapData = {}
        local mapdataExists = false
        
        -- First check if mapdata exists at all
        TriggerEvent("lyn-mapdata:exists", function(exists)
            mapdataExists = exists
        end)
        
        -- If we need to fetch the map IDs list, do it now
        if #allMaps == 0 then
            print("^6[" .. fullName .. "]^3 Fetching map IDs list...^0")
            FetchMapIds()
            -- Wait for the fetch to complete
            local startTime = GetGameTimer()
            while #allMaps == 0 and (GetGameTimer() - startTime) < Config.fetchTimeout do
                Wait(100)
            end
        end
        
        if not mapdataExists then
            print("^6[" .. fullName .. "]^1 ERROR: Mapdata does not exist! Please download and install the required mapdata.^0")
            -- Generate a link for mapdata download using the template from token.lua
            local mapsParam = table.concat(allMaps, "+")
            local downloadLink = MapDataDownloadUrlTemplate
            if MapDataDownloadUrlTemplate:find("{map_ids}") then
                downloadLink = string.gsub(MapDataDownloadUrlTemplate, "{map_ids}", mapsParam)
            end
            print("^6[" .. fullName .. "]^3 Download mapdata from: ^0" .. downloadLink)
            return
        end
        
        -- Check which maps are installed
        local installedMaps = {}
        for i = 1, #allMaps do
            local mapExistsName = allMaps[i] .. ":mapExists"
            TriggerEvent(mapExistsName, function(exists)
                if exists then
                    table.insert(installedMaps, allMaps[i])
                end
            end)
        end
        
        -- Check which maps are in mapdata
        for i = 1, #allMaps do
            local dataExistsName = allMaps[i] .. ":mapDataExists"
            TriggerEvent(dataExistsName, function(exists)
                if exists then
                    table.insert(mapData, allMaps[i])
                end
            end)
        end
        
        -- Compare installed maps with mapdata maps
        if #installedMaps ~= #mapData then
            print("^6[" .. fullName .. "]^1 ERROR: Mismatch between installed maps and mapdata!^0")
            print("^6[" .. fullName .. "]^1 Installed maps: " .. #installedMaps .. ", Maps in mapdata: " .. #mapData .. "^0")
            
            -- Generate a link for correct mapdata download using the template from token.lua
            local mapsParam = table.concat(installedMaps, "+")
            local downloadLink = MapDataDownloadUrlTemplate
if MapDataDownloadUrlTemplate:find("{map_ids}") then
    downloadLink = string.gsub(MapDataDownloadUrlTemplate, "{map_ids}", mapsParam)
end
            print("^6[" .. fullName .. "]^3 Download correct mapdata from: ^0" .. downloadLink)
            return
        end
        
        -- Verify the map data order matches the expected order
        local orderCorrect = true
        for i = 1, #allMaps do
            if i <= #mapData and allMaps[i] ~= mapData[i] then
                orderCorrect = false
                break
            end
        end
        
        if not orderCorrect then
            print("^6[" .. fullName .. "]^1 ERROR: Map order in mapdata does not match expected order!^0")
            -- Generate a link for correct mapdata download using the template from token.lua
            local mapsParam = table.concat(allMaps, "+")
            local downloadLink = MapDataDownloadUrlTemplate
if MapDataDownloadUrlTemplate:find("{map_ids}") then
    downloadLink = string.gsub(MapDataDownloadUrlTemplate, "{map_ids}", mapsParam)
end
            print("^6[" .. fullName .. "]^3 Download correct mapdata from: ^0" .. downloadLink)
            return
        end
        
        if debug then
            print("^6[" .. fullName .. "]^2 Map verification completed successfully.^0")
        end
    end)

    -- Get the list of all maps from the API
    -- Fetch the map IDs from a URL
    local allMaps = {}
    
    -- Function to fetch map IDs from URL
    function FetchMapIds() -- Changed to global function so it can be called from other parts of the script
        local mapIdsUrl = Config.mapIdsUrl
        local fetchStartTime = GetGameTimer()
        
        -- Set up a timeout check
        CreateThread(function()
            while #allMaps == 0 and (GetGameTimer() - fetchStartTime) < Config.fetchTimeout do
                Wait(500)
            end
            
            if #allMaps == 0 then
                print("^6[" .. fullName .. "]^1 Timed out fetching map IDs from API server. Using fallback map IDs.^0")
                -- Fallback to some default map IDs in case the fetch fails
                allMaps = {"map_example1", "map_example2", "map_example3"}
            end
        end)
        
        PerformHttpRequest(mapIdsUrl, function(errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print("^6[" .. fullName .. "]^1 Error fetching map IDs: " .. tostring(errorCode) .. "^0")
                return
            end
            
            -- Parse each line as a map ID
            for mapId in string.gmatch(resultData, "[^\r\n]+") do
                table.insert(allMaps, mapId)
            end
            
            if debug then
                print("^6[" .. fullName .. "]^3 Fetched " .. #allMaps .. " map IDs from API server.^0")
            end
        end)
    end
    
    -- Fetch the map IDs
    FetchMapIds()
    
    -- Determine if this is the last map in the sequence
    CreateThread(function()
        Wait(3000) -- Wait for all maps to initialize and fetch map IDs
        
        -- Check if we're the last map in the list
        if #allMaps > 0 then
            local lastMapId = allMaps[#allMaps]
            if lastMapId == mapId then
                -- We are the last map, trigger the final check
                TriggerEvent(mapId .. ":mapFinal")
                if debug then
                    print("^6[" .. fullName .. "]^3 This is the last map in sequence. Triggering verification...^0")
                end
            end
        end
    end)
    
    -- Get the list of installed maps
    local installedMaps = {}
    CreateThread(function()
        -- Wait for map IDs to be fetched
        while #allMaps == 0 do
            Wait(500)
        end
        
        Wait(2000) -- Wait for all maps to initialize
        
        for i = 1, #allMaps do
            local eventName = allMaps[i] .. ":mapExists"
            TriggerEvent(eventName, function(exists)
                if exists then
                    table.insert(installedMaps, allMaps[i])
                    if debug then
                        print("^6[" .. fullName .. "]^3 Found installed map: ^0" .. allMaps[i])
                    end
                end
            end)
        end
        
        -- Get full names of all installed maps
        for i = 1, #installedMaps do
            local fullNameEvent = installedMaps[i] .. ":mapFullNameSend"
            TriggerEvent(fullNameEvent, mapId .. ":mapFullNameReceive", i)
        end
        
        -- Trigger the final map to perform verification
        if #installedMaps > 0 then
            local finalMap = installedMaps[#installedMaps]
            local finalEvent = finalMap .. ":mapFinal"
            TriggerEvent(finalEvent)
        end
    end)
    
    if debug then
        print("^6[" .. staticName .. "]^2 Map system initialized successfully.^0")
    end
end

-- Function to verify map data
local function VerifyMapData(mapData)
    -- Access local variables from the loader script
    local staticName = StaticName -- From token.lua
    local debug = Debug or Config.Debug -- From token.lua or config.lua
    
    -- Get the list of installed maps
    local installedMaps = {}
    -- Wait for map IDs to be fetched if needed
    if #allMaps == 0 then
        if debug then
            print("^6[" .. staticName .. "]^3 Waiting for map IDs to be fetched...^0")
        end
        -- We'll use the global allMaps variable once it's populated
        return
    end
    
    for i = 1, #allMaps do
        local eventName = allMaps[i] .. ":mapExists"
        TriggerEvent(eventName, function(exists)
            if exists then
                table.insert(installedMaps, allMaps[i])
            end
        end)
    end
    
    -- Check for missing map data
    local missingMapData = {}
    for i = 1, #installedMaps do
        local exists = false
        for j = 1, #mapData do
            if installedMaps[i] == mapData[j] then
                exists = true
                break
            end
        end

        if not exists then
            table.insert(missingMapData, installedMaps[i])
        end
    end
    
    -- Check for extra map data
    local extraMapData = {}
    for i = 1, #mapData do
        local exists = false
        for j = 1, #installedMaps do 
            if mapData[i] == installedMaps[j] then
                exists = true
                break
            end
        end

        if not exists then
            table.insert(extraMapData, mapData[i])
        end
    end
    
    -- Report any issues
    if #missingMapData > 0 then
        local missingList = table.concat(missingMapData, ", ")
        print("^6[" .. staticName .. "]^1 Error: Missing map data for: ^0" .. missingList)
        print("^6[" .. staticName .. "]^1 Please install the correct mapdata that includes these maps.^0")
        -- Generate a link for mapdata download using the template from token.lua
        local mapsParam = table.concat(installedMaps, "+")
        local downloadLink = MapDataDownloadUrlTemplate
if MapDataDownloadUrlTemplate:find("{map_ids}") then
    downloadLink = string.gsub(MapDataDownloadUrlTemplate, "{map_ids}", mapsParam)
end
        print("^6[" .. staticName .. "]^1 Get the correct mapdata from: ^0" .. downloadLink)
    end
    
    if #extraMapData > 0 then
        local extraList = table.concat(extraMapData, ", ")
        print("^6[" .. staticName .. "]^1 Error: Mapdata contains extra maps that are not installed: ^0" .. extraList)
        print("^6[" .. staticName .. "]^1 Please install the correct mapdata that matches your installed maps.^0")
        -- Generate a link for mapdata download using the template from token.lua
        local mapsParam = table.concat(installedMaps, "+")
        local downloadLink = MapDataDownloadUrlTemplate
if MapDataDownloadUrlTemplate:find("{map_ids}") then
    downloadLink = string.gsub(MapDataDownloadUrlTemplate, "{map_ids}", mapsParam)
end
        print("^6[" .. staticName .. "]^1 Get the correct mapdata from: ^0" .. downloadLink)
    end
    
    if #missingMapData == 0 and #extraMapData == 0 then
        print("^6[" .. staticName .. "]^2 Map verification complete. All maps have correct mapdata.^0")
    end
end

-- Execute the initialization function
Initialize()
