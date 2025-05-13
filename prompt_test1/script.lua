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
PerformHttpRequest(Urls.AllMapList, function(err, text, headers)
    if err ~= 200 then 
        print("Please update the map, it has old code.")
    else
        local lines = text:gmatch("[^\r\n]+")
        for line in lines do
            table.insert(allMaps, line)
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
    if #legacyMaps > 0 then
        print("+--------------------------------------------------------------------------+")
        print("| ⚠️ ^3 Support for legacy script version found the following maps:^7            |")
        for i = 1, #legacyMaps do
            print("| ^3 - " .. legacyMaps[i] .. "^7" .. string.rep(" ", 70 - #legacyMaps[i]) .. "|")
        end
        print("| ^3 Legacy maps will work, but consider downloading the new version^7          |")
        print("+--------------------------------------------------------------------------+")
    else 
        if Debug == true then 
            print("Found no legacy maps, continuing...")
        end
    end

    -- Making a link for Mapdata in case it does not fit
    -- Example: prompt_test1+prompt_test2+prompt_test3
    local ids = ""
    for i = 1, #existList do
        ids = ids..existList[i]
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
                print("+--------------------------------------------------------------------------+")
                print("| ❌ ^8 Mapdata is not the same as maps installed^7                          |")
                print("|^8 There are more maps than mapdata supports!^7                             |")
                print("|^8", link, "^7")
                print("+--------------------------------------------------------------------------+")
            elseif #existList < #mapdataMaps then
                print("+--------------------------------------------------------------------------+")
                print("| ❌ ^8 Mapdata is not the same as maps installed^7                          |")
                print("|^8 There are less maps than mapdata supports!^7                             |")
                print("|^8", link, "^7")
                print("+--------------------------------------------------------------------------+")
            end
        else 
            print("+--------------------------------------------------------------------------+")
            print("| ✅ ^2Mapdata is the same as maps installed    ^7                             |")
            print("+--------------------------------------------------------------------------+")
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
                
                print("+--------------------------------------------------------------------------+")
                print("| ⚠️ ^3 Support for legacy mapdata found for the following maps:^7             |")
                for i = 1, #legacyMapdataMaps do
                    print("| ^3 - " .. legacyMapdataMaps[i] .. "^7" .. string.rep(" ", 70 - #legacyMapdataMaps[i]) .. "|")
                end
                print("| ^3 Legacy mapdata will work, but consider downloading the new version^7      |")
                print("+--------------------------------------------------------------------------+")
                
                -- Check if mapdata matches installed maps
                checkMapdataMatch(mapdataMaps, existList, link)
            else
                print("+--------------------------------------------------------------------------+")
                print("| ❌ ^8 Mapdata does not exist ^7                                               |")
                print("|^8", link, "^7")
                print("+--------------------------------------------------------------------------+")
            end
        end
    end
end)
