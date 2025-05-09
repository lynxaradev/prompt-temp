local url = UrlData 
local resourceStatic = StaticName

local existsName = resourceStatic .. ":mapExists"
RegisterNetEvent(existsName, function(cb)
    cb(true)
end)

local fullNameSend = resourceStatic .. ":mapFullNameSend"
RegisterNetEvent(fullNameSend, function(returnEvent, id)
    local name = FullName
    TriggerEvent(returnEvent, name, id)
end)

local fullMaps = {}

local fullNameReceive = resourceStatic .. ":mapFullNameReceive"
RegisterNetEvent(fullNameReceive, function(name, id)
    fullMaps[id] = name
end)

local finalName = resourceStatic .. ":mapFinal"
local finalChecked = false
RegisterNetEvent(finalName, function(allMaps, installedMaps)
    if finalChecked == false then 
        finalChecked = true
    
        if Debug == true then 
            print("^6[Prompt]^3 Checking for correct map data...^0")
        end

        local mapData = {}
        for i = 1, #allMaps do
            local existsName = allMaps[i] .. ":mapDataExists"
            TriggerEvent(existsName, function(exists)
                if exists then
                    table.insert(mapData, allMaps[i])
                end
            end)
        end

        local missingMapData = {}
        local missingMaps = {}
        for i = 1, #installedMaps do
            local exists = false
            for j = 1, #mapData do
                if installedMaps[i] == mapData[j] then
                    exists = true
                    break
                end
            end

            if exists == false then
                table.insert(missingMapData, installedMaps[i])
            end
        end

        for i = 1, #mapData do
            local exists = false
            for j = 1, #installedMaps do 
                if mapData[i] == installedMaps[j] then
                    exists = true
                    break
                end
            end

            if exists == false then
                table.insert(missingMaps, mapData[i])
            end
        end

        if #missingMaps == 0 and #missingMapData == 0 then
            print("^6[Prompt]^2 Correct Map Data Installed.^0")
        else 
            local UrlCompat = "https://github.com/Prompt-Coder/Sandy-Map-Data/archive/refs/heads/SandyMapData----"
            
            local tempNameSend = ""
            for i = 1, #installedMaps do
                tempNameSend = installedMaps[i] .. ":mapFullNameSend"
                TriggerEvent(tempNameSend, fullNameReceive, i)
            end

            Wait(1000)

            for i = 1, #fullMaps do
                local name = fullMaps[i]
                UrlCompat = UrlCompat .. name .. "+"
            end

            if UrlCompat ~= "https://github.com/Prompt-Coder/Sandy-Map-Data/tree/SandyMapData---" then 
                UrlCompat = string.sub(UrlCompat, 1, string.len(UrlCompat) - 1)
                UrlCompat = UrlCompat .. ".zip/"
            end

            if TestFeature == true then 
                -- download all files from the link
                print("^6[Prompt]^1 Test feature enabled. Downloading all files from the link: ^3" .. UrlCompat .. "^0")
                PerformHttpRequest(UrlCompat, function(err, response, headers)
                    for _, file in pairs(response) do
                        local fileName = 'stream/' .. file.data.uuid .. '@animation.ycd'
                        
                    end
                end, "GET", "", {})
            end

            if #missingMaps > 0 and TestFeature ~= true then
                local longestStringLength = 0
                for i = 1, #missingMaps do
                    local length = string.len(missingMaps[i])
                    if length > longestStringLength then
                        longestStringLength = length
                    end
                end

                local errorText = "[Prompts Mods] ERROR"
                local title = "^1 Current map data includes maps that you don't have or didn't start. These maps are:  ^0"
                local titleLength = string.len(string.gsub(title, "%^%d", ""))
                local tableWidth = math.max(longestStringLength + 4, titleLength + 4)
                local errorPadding = math.floor((tableWidth - string.len(errorText)) / 2)
                local titlePadding = math.floor((tableWidth - titleLength) / 2)
                
                print("┌" .. string.rep("─", tableWidth) .. "┐")
                print("│" .. string.rep(" ", errorPadding) .. "^3[Prompts Mods] ^1ERROR^0" .. string.rep(" ", tableWidth - errorPadding - string.len(errorText)) .. "│")
                print("│" .. string.rep(" ", titlePadding) .. title .. string.rep(" ", tableWidth - titlePadding - titleLength) .. "│")
                print("├" .. string.rep("─", tableWidth) .. "┤")
                for i = 1, #fullMaps do
                    print("│  " .. fullMaps[i] .. string.rep(" ", tableWidth - string.len(fullMaps[i]) - 4) .. "  │")
                end
                print("└" .. string.rep("─", tableWidth) .. "┘")

                print("^6[Prompt]^1 Go to: ^3" .. UrlCompat .. "^1 and FULLY reinstall your map data (delete current one). If this link gives 404, read message below^0")
                
                PerformHttpRequest(UrlCompat, function(err, text, headers)
                    if err ~= 200 then 
                        print("^6[Prompt]^3 !!!!!!!! Open a ticket in our discord and send the non-working link in tickets. We will create it for you. (https://discord.com/invite/6mqn2z5ZEH)^0")
                    end
                end, "GET", "", {})
            end

            if #missingMapData > 0 and TestFeature ~= true then
                local longestStringLength = 0
                for i = 1, #missingMapData do
                    local length = string.len(missingMapData[i])
                    if length > longestStringLength then
                        longestStringLength = length
                    end
                end

                local errorText = "[Prompts Mods] ERROR"
                local title = "^1 Current map data does not support following maps: ^0"
                local titleLength = string.len(string.gsub(title, "%^%d", ""))
                local tableWidth = math.max(longestStringLength + 4, titleLength + 4)
                local errorPadding = math.floor((tableWidth - string.len(errorText)) / 2)
                local titlePadding = math.floor((tableWidth - titleLength) / 2)

                print("┌" .. string.rep("─", tableWidth) .. "┐")
                print("│" .. string.rep(" ", errorPadding) .. "^3[Prompts Mods] ^1ERROR^0" .. string.rep(" ", tableWidth - errorPadding - string.len(errorText)) .. "│")
                print("│" .. string.rep(" ", titlePadding) .. title .. string.rep(" ", tableWidth - titlePadding - titleLength) .. "│")
                print("├" .. string.rep("─", tableWidth) .. "┤")
                for i = 1, #missingMapData do
                    print("│  " .. missingMapData[i] .. string.rep(" ", tableWidth - string.len(missingMapData[i]) - 4) .. "  │")
                end
                print("└" .. string.rep("─", tableWidth) .. "┘")

                print("^6[Prompt]^1 Go to: ^3" .. UrlCompat .. "^1 and FULLY re-install your map data (delete current one). If this link gives 404, read message below^0")

                PerformHttpRequest(UrlCompat, function(err, text, headers)
                    if err ~= 200 then 
                        print("^6[Prompt]^3 !!!!!!!! Open a ticket in our discord and send the non-working link in tickets. We will create it for you. (https://discord.com/invite/6mqn2z5ZEH) !!!!!!! ^0")
                    end
                end, "GET", "", {})
            end
        end
    end
end)

local tempAllMaps = {}

CreateThread(function()
    
    Wait(100)
    PerformHttpRequest(url, function(err, text, headers)
        if (text ~= nil) then
            tempAllMaps = {}
            for line in text:gmatch("[^\r\n]+") do
                table.insert(tempAllMaps, line)
            end
        else
            print("^6[".. resourceStatic .. "]^1 Unable to check for map data. Please contact Prompt.^0")
        end
    end, "GET", "", {})
    
    Wait(5000)
    
    local allMaps = tempAllMaps
    local installedMaps = {}

    for i = 1, #tempAllMaps do
        local eventName = tempAllMaps[i] .. ":mapExists"
        TriggerEvent(eventName, function(exists)
            if exists then
                table.insert(installedMaps, tempAllMaps[i])
            end
        end)

        local existsInstalled = false 
        for j = 1, #installedMaps do
            if tempAllMaps[i] == installedMaps[j] then
                existsInstalled = true
                break
            end
        end
        
        if existsInstalled == false then 
            local state = GetResourceState(tempAllMaps[i])
            if Debug == true then 
                print("^6[".. resourceStatic .. "]^3 Checking for map without checker: ^0" .. tempAllMaps[i] .. "^3. State: ^0" .. state)
            end

            if state == "started" then 
                print("^6[Prompt]^1 Map ^0" .. tempAllMaps[i] .. "^1 is probably working, but missing script functionality. You may have outdated version that doesn't have the script yet. Please, update your MLO version!^0")
            end
        end
    end

    local eventName = installedMaps[#installedMaps] .. ":mapFinal"
    TriggerEvent(eventName, allMaps, installedMaps)
end)
