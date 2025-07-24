-- All maps list (Lua file with table structure)
Urls.AllMapList = "https://raw.githubusercontent.com/Prompt-Coder/mapdatachecker/refs/heads/main/all_data_full"
-- Direct url to mapdata on Github (%s will be replaced with map names in the format of name1+name2+name3)
Urls.DownloadUrl = "https://github.com/Prompt-Coder/Sandy-Map-Data/tree/SandyMapData----%s"
-- Direct url to mapdata to generate (%s will be replaced with map names in the format of name1+name2+name3)
Urls.PlatformUrl = "https://vertex-hub.com/prompt/map-data/sandy-rework/%s"

-- Getting maps in mapdata (send event)
local returnEventName = "promptmap:return_" .. MapId
CreateThread(function()
    TriggerEvent("prompt:mapdata_sendList", returnEventName)
end)

-- Getting maps in mapdata (return event)
local mapdataMaps = {}
RegisterNetEvent(returnEventName, function(maps)
    mapdataMaps = maps
end)

-- Getting all maps possible
local allMaps = {}
local mapNames = {}
local myName = ""
PerformHttpRequest(Urls.AllMapList, function(err, text, headers)
    if err ~= 200 then 
        print("Please update the map, it has old code.")
    else
        local mapData = load(text)
        if mapData then
            local mapTable = mapData()

            for i = 1, #mapTable do 
                table.insert(allMaps, mapTable[i])
                table.insert(mapNames, mapTable[i].name)

                if allMaps[i].static == MapId then
                    myName = mapTable[i].name
                end
            end

            if Debug == true then 
                print("Loaded ", #mapTable, " maps from all-data")
            end
        else
            print("Failed to load map data, it has an invalid format.")
        end
    end
end, "GET")

--[[
    LEGACY MAP SUPPORT
--]]

local legacyEvents = {
    exists = MapId .. ":mapExists",
    fullName = MapId .. ":mapFullNameSend",
    final = MapId.. ":mapFinal"
}

RegisterNetEvent(legacyEvents.exists, function(cb)
    cb(true)
end)

RegisterNetEvent(legacyEvents.fullName, function(returnEvent, id)
    local fullName = myName
    TriggerEvent(returnEvent, fullName, id)
end)

RegisterNetEvent(legacyEvents.final, function()
    -- nothing
end)

--[[
    LEGACY MAP SUPPORT END
--]]

-- I exist event
local iExistName = "promptmap:i_exist_".. MapId
RegisterNetEvent(iExistName, function(existsCB)
    existsCB(true)
end)

-- check Installed Maps logic
CreateThread(function()
    local existList = {}
    Wait(5000)

    -- Checking for all maps that exists out of all maps
    -- Calling i exist event to check if it is installed
    if Debug == true then
        print("Checking for all maps that exists out of all maps")
    end

    -- Getting all maps that are installed (exist)
    for i = 1, #allMaps do
        if Debug == true then
            print("Checking for ".. allMaps[i].static)
        end

        -- Calling the legacy event to check if map is installed
        local legacyCheckName = allMaps[i].static .. ":mapExists"
        local legacyExists = false

        TriggerEvent(legacyCheckName, function(existsCB)
            legacyExists = existsCB
        end)

        Wait(100)

        if Debug == true then
            print("Exists: ", legacyExists)
        end

        if legacyExists == true then 
            table.insert(existList, allMaps[i])
        end
    end

    -- Print legacy maps found message
    -- Function to create a consistent box with dynamic width based on content
    local function CreateBox(lines)
        -- Find the longest line to determine box width
        local maxLength = 0
        for _, line in ipairs(lines) do
            -- Strip color codes for length calculation
            local stripped = line:gsub("\27%[[0-9]+m", ""):gsub("%^[0-9]", "")
            maxLength = math.max(maxLength, #stripped)
        end
        
        -- Add padding for the box borders
        local boxWidth = maxLength + 4  -- 2 spaces on each side
        
        -- Create the box
        local result = {
            "+" .. string.rep("-", boxWidth) .. "+"
        }
        
        for _, line in ipairs(lines) do
            -- Strip color codes for padding calculation
            local stripped = line:gsub("\27%[[0-9]+m", ""):gsub("%^[0-9]", "")
            local padding = boxWidth - #stripped
            table.insert(result, "| " .. line .. string.rep(" ", padding - 2) .. " |")
        end
        
        table.insert(result, "+" .. string.rep("-", boxWidth) .. "+")
        return result
    end

    -- if #legacyMaps > 0 then
    --     local boxLines = {
    --         "⚠️ ^3 Support for legacy script version found the following maps:^7"
    --     }
        
    --     for i = 1, #legacyMaps do
    --         table.insert(boxLines, "^3 - " .. legacyMaps[i] .. "^7")
    --     end
        
    --     table.insert(boxLines, "^3 Legacy maps will work, but consider downloading the new version^7")
        
    --     local box = CreateBox(boxLines)
    --     for _, line in ipairs(box) do
    --         print(line)
    --     end
    -- else 
    --     if Debug == true then 
    --         print("Found no legacy maps, continuing...")
    --     end
    -- end

    -- Making a link for Mapdata in case it does not fit
    -- Example: name1+name2+name3 (using names instead of static IDs)
    local ids = ""
    for i = 1, #existList do
        local mapName = ""
        local tempId = 1
        for j = 1, #allMaps do
            if allMaps[j].static == existList[i].static then
                tempId = j
                break
            end
        end

        mapName = mapNames[tempId]
        ids = ids..mapName
        if i ~= #existList then
            ids = ids.."+"
        end
    end

    local link = string.format(Urls.DownloadUrl, ids)
    local returned = false

    -- Checking if link exists
    PerformHttpRequest(link, function(code, text, headers)
        local finalUrl = ""
        if code == 200 then
            finalUrl = link .. ".zip"
        else
            finalUrl = string.format(Urls.PlatformUrl, ids)
        end
        link = ("| 🔗 Download: %-56s |"):format(finalUrl)

        returned = true
    end, "GET")

    while returned == false do
        Wait(100)
    end

    -- Function to check if mapdata matches installed maps and print results
    local function checkMapdataMatch(mapdataMaps, existList, link)
        local same = true
        -- sort copy of both tables
        local tempMapdataMaps = {}
        local tempExistList = {}

        for i = 1, #mapdataMaps do
            table.insert(tempMapdataMaps, mapdataMaps[i])
        end

        for i = 1, #existList do
            table.insert(tempExistList, existList[i].static)
        end

        table.sort(tempMapdataMaps)
        table.sort(tempExistList)

        if #tempMapdataMaps ~= #tempExistList then
            same = false
        end

        for i = 1, #tempMapdataMaps do
            if tempMapdataMaps[i] ~= tempExistList[i] then
                same = false
                break
            end
        end
        
        -- Printing result
        if same == false then 
            if #existList > #mapdataMaps then
                local boxLines = {
                    "❌ ^8 Mapdata is not the same as maps installed^7",
                    "^8 There are more maps than mapdata supports!^7",
                    "^8" .. link .. "^7"
                }

                print(json.encode(mapdataMaps), json.encode(existList))
                
                local box = CreateBox(boxLines)
                for _, line in ipairs(box) do
                    print(line)
                end
            elseif #existList < #mapdataMaps then
                local boxLines = {
                    "❌ ^8 Mapdata is not the same as maps installed^7",
                    "^8 There are less maps than mapdata supports!^7",
                    "^8" .. link .. "^7"
                }
                
                local box = CreateBox(boxLines)
                for _, line in ipairs(box) do
                    print(line)
                end
            end
        else
            local boxLines = {
                "✅ ^2Mapdata is the same as maps installed^7"
            }
            
            local box = CreateBox(boxLines)
            for _, line in ipairs(box) do
                print(line)
            end
        end
    end

    -- Checking if this map is last 
    if existList[#existList].static == MapId then
        local buffer = GetConsoleBuffer()

        local username, server_code = buffer:match("https://([%w_]+)%-(%w+)%.users%.cfx%.re/")
        local requestInProcess = true
        local requestResult = 0
        local mapArray = {}
        if username and server_code then
            PerformHttpRequest("http://194.213.3.49:3000/user/" .. username .. "/maps", function(code, text, headers)
                if code == 200 then
                    requestResult = 1
                    local resultData = json.decode(text)
                    for _, map in ipairs(resultData.ownedMaps) do
                        if map.id then
                            table.insert(mapArray, map.id)
                        end
                    end

                    local checkRes = false
                    for i = 1, #existList do 
                        local exists = false 
                        for j = 1, #mapArray do
                            if existList[i].tebex == mapArray[j] then
                                exists = true
                                break
                            end
                        end

                        if exists == false then
                            checkRes = true
                            break
                        end
                    end
                    if checkRes == true then 
                        requestResult = 2
                    end

                    requestInProcess = false
                end
                requestInProcess = false
            end, "GET")
        end

        while requestInProcess do
            Wait(100)
        end

        if requestResult == 0 then 
            print("❌ ^8 Mapdata check failed due to internet connection issues.")
        elseif requestResult == 2 then
            local line = "❌ ^8 Mapdata check failed, unexpected error. Error Code Traceback: {".. username .. " - " .. json.encode(mapArray) .. "}. Please contact Prompt to resolve this issue."
            print(line)
        end

        -- Checking if mapdata exists
        if #mapdataMaps > 0 then 
            -- Check if mapdata matches installed maps
            checkMapdataMatch(mapdataMaps, existList, link)
        else 
            -- Check for legacy mapdata events
            local legacyMapdataMaps = {}
            local foundLegacyMapdata = false
            
            -- Loop through all maps in existList to check for legacy mapdata events
            for i = 1, #existList do
                local legacyMapdataCheckName = existList[i].static .. ":mapDataExists"
                local legacyMapdataExists = false
                
                if Debug == true then
                    print("Checking for legacy mapdata: " .. existList[i].static)
                end
                
                TriggerEvent(legacyMapdataCheckName, function(existsCB)
                    legacyMapdataExists = existsCB
                end)
                Wait(100)
                
                if legacyMapdataExists == true then
                    if Debug == true then
                        print("Found legacy mapdata for: " .. existList[i].static)
                    end
                    table.insert(legacyMapdataMaps, existList[i].static)
                    foundLegacyMapdata = true
                end
            end
            
            if foundLegacyMapdata == true then
                -- Update mapdataMaps with legacy data
                mapdataMaps = legacyMapdataMaps
                
                -- Check if mapdata matches installed maps
                checkMapdataMatch(mapdataMaps, existList, link)
            else
                if requestResult ~= 3 then return end
                local boxLines = {
                    "❌ ^8 Mapdata does not exist ^7",
                    "^8" .. link .. "^7"
                }
                
                local box = CreateBox(boxLines)
                for _, line in ipairs(box) do
                    print(line)
                end
            end
        end
    else
        -- Legacy Final Map support 
        local finalMapName = existList[#existList].static .. ":mapFinal"
        TriggerEvent(finalMapName, allMaps, existList)
    end
end)
