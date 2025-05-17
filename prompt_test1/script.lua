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
PerformHttpRequest(Urls.AllMapList, function(err, text, headers)
    if err ~= 200 then 
        print("Please update the map, it has old code.")
    else
        local mapData = load(text)
        if mapData then
            local mapTable = mapData()

            for i = 1, #mapTable do 
                table.insert(allMaps, mapTable[i].static)
                table.insert(mapNames, mapTable[i].name)
            end

            if Debug == true then 
                print("Loaded ", #mapTable, " maps from all-data")
            end
        else
            print("Failed to load map data, it has an invalid format.")
        end
    end
end, "GET")

-- I exist event
local iExistName = "promptmap:i_exist_".. MapId
RegisterNetEvent(iExistName, function(existsCB)
    existsCB(true)
end)

-- check Installed Maps logic
CreateThread(function()
    local existList = {}
    Wait(1000)

    -- Checking for all maps that exists out of all maps
    -- Calling i exist event to check if it is installed
    if Debug == true then
        print("Checking for all maps that exists out of all maps")
    end

    -- Getting all maps that are installed (exist)
    for i = 1, #allMaps do
        local checkName = "promptmap:i_exist_" .. allMaps[i]
        local exists = false
        if Debug == true then
            print("Checking for ".. allMaps[i])
        end

        -- Calling the event to check if it is installed and started
        TriggerEvent(checkName, function(existsCB)
            exists = existsCB
        end)
        Wait(100)

        if Debug == true then
            print("Exists: ", exists)
        end

        if exists == true then 
            table.insert(existList, allMaps[i])
        end
    end

    -- Check for legacy maps using static:mapExists event
    local legacyMaps = {}
    for i = 1, #allMaps do
        -- Skip if already in existList
        local alreadyExists = false
        for j = 1, #existList do
            if allMaps[i] == existList[j] then
                alreadyExists = true
                break
            end
        end

        if not alreadyExists then
            -- Try legacy event
            local legacyCheckName = allMaps[i] .. ":mapExists"
            local legacyExists = false
            
            TriggerEvent(legacyCheckName, function(existsCB)
                legacyExists = existsCB
            end)
            Wait(100)

            if legacyExists == true then
                print("Found legacy map: ", allMaps[i])
                table.insert(existList, allMaps[i])
                table.insert(legacyMaps, allMaps[i])
            end
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

    if #legacyMaps > 0 then
        local boxLines = {
            "⚠️ ^3 Support for legacy script version found the following maps:^7"
        }
        
        for i = 1, #legacyMaps do
            table.insert(boxLines, "^3 - " .. legacyMaps[i] .. "^7")
        end
        
        table.insert(boxLines, "^3 Legacy maps will work, but consider downloading the new version^7")
        
        local box = CreateBox(boxLines)
        for _, line in ipairs(box) do
            print(line)
        end
    else 
        if Debug == true then 
            print("Found no legacy maps, continuing...")
        end
    end

    -- Making a link for Mapdata in case it does not fit
    -- Example: name1+name2+name3 (using names instead of static IDs)
    local ids = ""
    for i = 1, #existList do
        local mapName = ""
        local tempId = 1
        for j = 1, #allMaps do
            if allMaps[j] == existList[i] then
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

    -- Checking if link exists
    PerformHttpRequest(link, function(code, text, headers)
        if code == 200 then
            link = ("| 🔗 Download: %-56s |"):format(link)
        else
            link = "| 🔗 Download link doesn't exist, please request the upload in support"
        end
    end, "GET")

    -- Function to check if mapdata matches installed maps and print results
    local function checkMapdataMatch(mapdataMaps, existList, link)
        local same = true
        for i = 1, #mapdataMaps do
            if existList[i] == nil or existList[i] ~= mapdataMaps[i] then
                same = false
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
    if existList[#existList] == MapId then
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
                local legacyMapdataCheckName = existList[i] .. ":mapDataExists"
                local legacyMapdataExists = false
                
                if Debug == true then
                    print("Checking for legacy mapdata: " .. existList[i])
                end
                
                TriggerEvent(legacyMapdataCheckName, function(existsCB)
                    legacyMapdataExists = existsCB
                end)
                Wait(100)
                
                if legacyMapdataExists == true then
                    if Debug == true then
                        print("Found legacy mapdata for: " .. existList[i])
                    end
                    table.insert(legacyMapdataMaps, existList[i])
                    foundLegacyMapdata = true
                end
            end
            
            if foundLegacyMapdata then
                -- Update mapdataMaps with legacy data
                mapdataMaps = legacyMapdataMaps
                
                local boxLines = {
                    "⚠️ ^3 Support for legacy mapdata found for the following maps:^7"
                }
                
                for i = 1, #legacyMapdataMaps do
                    table.insert(boxLines, "^3 - " .. legacyMapdataMaps[i] .. "^7")
                end
                
                table.insert(boxLines, "^3 Legacy mapdata will work, but consider downloading the new version^7")
                
                local box = CreateBox(boxLines)
                for _, line in ipairs(box) do
                    print(line)
                end
                
                -- Check if mapdata matches installed maps
                checkMapdataMatch(mapdataMaps, existList, link)
            else
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
    end
end)
