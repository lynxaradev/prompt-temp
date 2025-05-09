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
        -- it is multiline test
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

    for i = 1, #allMaps do
        local checkName = "promptmap:i_exist_" .. allMaps[i]
        local exists = false
        if Debug == true then
            print("Checking for ".. allMaps[i])
        end
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

    -- Checking if this map is last 
    if existList[#existList] == MapId then
        local ids = ""
        for i = 1, #existList do
            ids = ids..existList[i]
            if i ~= #existList then
                ids = ids.."+"
            end
        end
        local link = string.format(Urls.DownloadUrl, ids)
        PerformHttpRequest(link, function(code, text, headers)
            if code == 200 then
                link = ("| 🔗 Download: %-56s |"):format(link)
            else
                link = "| 🔗 Download link doesn't exist, please request the upload in support"
            end
        end, "GET")
        
        if #mapdataMaps > 0 then 
            local same = true
            for i = 1, #mapdataMaps do
                if existList[i] == nil or existList[i] ~= mapdataMaps[i] then
                    same = false
                end
            end

            if same == false then 
                print("+--------------------------------------------------------------------------+")
                print("| ❌ ^8 Mapdata is not the same as maps installed    ^7                         |")
                print("|^8", link, "^7")
                print("+--------------------------------------------------------------------------+")
            else 
                print("+--------------------------------------------------------------------------+")
                print("| ✅ ^2Mapdata is the same as maps installed    ^7                             |")
                print("+--------------------------------------------------------------------------+")
            end
        else 
            print("+--------------------------------------------------------------------------+")
            print("| ❌ ^8 Mapdata does not exist ^7                                               |")
            print("|^8", link, "^7")
            print("+--------------------------------------------------------------------------+")
        end
    end
end)
