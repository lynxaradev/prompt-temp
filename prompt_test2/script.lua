-- script.lua for test-map
-- Combined mapversioncheck and mapchainhandler functionality

-- MapVersionCheck functionality
local resourceStatic = StaticName
local url = UrlVersion
local version = "1.0.0" -- This would normally be fetched from resource metadata

-- Check for updates
PerformHttpRequest(url, function(err, text, headers)
    if (text ~= nil) then
        local newestVersion = string.sub(text, 1, string.find(text, "\n") - 1)
        local changelog = string.sub(text, string.find(text, "\n") + 1)
        
        if version ~= newestVersion then
            -- Function to get string length without color codes
            local function getVisibleLength(str)
                return #string.gsub(str, "%^%d", "")
            end
            
            -- Headers for columns
            local header1 = "Your version"
            local header2 = "Latest version"
            local ver1 = version
            local ver2 = newestVersion
            
            -- Calculate max width for each column including headers
            local col1Width = math.max(#header1, #ver1)
            local col2Width = math.max(#header2, #ver2)
            local totalWidth = col1Width + col2Width + 7  -- 7 for padding and borders
            
            -- Create table parts
            local topBorder = "^6╔" .. string.rep("═", totalWidth - 2) .. "╗"
            local titleText = "Update Available"
            local title = "^6║" .. string.rep(" ", math.floor((totalWidth - #titleText)/2)) .. 
                         "^3" .. titleText .. string.rep(" ", math.ceil((totalWidth - #titleText)/2 - 2)) .. "^6║"
            
            -- Create resource name row
            local resourceText = FullName
            local resourceRow = "^6║" .. string.rep(" ", math.floor((totalWidth - #resourceText)/2)) .. 
                              "^7" .. resourceText .. 
                              string.rep(" ", math.ceil((totalWidth - #resourceText)/2) - 2) .. "^6║"
            
            -- Create headers row with padding
            local headersRow = "^6║ ^3" .. header1 .. string.rep(" ", col1Width - #header1) ..
                             " ^6│ ^3" .. header2 .. string.rep(" ", col2Width - #header2) .. " ^6║"
            
            -- Create separator
            local separator = "^6╟" .. string.rep("─", col1Width + 2) .. "┼" .. 
                            string.rep("─", col2Width + 2) .. "╢"
            
            -- Create versions row
            local versionsRow = "^6║ ^7" .. ver1 .. string.rep(" ", col1Width - #ver1) ..
                              " ^6│ ^7" .. ver2 .. string.rep(" ", col2Width - #ver2) .. " ^6║"
            
            -- Create download row
            local downloadText = "Download: keymaster.fivem.net"
            local downloadRow = "^6║ ^3" .. downloadText .. 
                              string.rep(" ", totalWidth - #downloadText - 3) .. "^6║"
            
            -- Create bottom border
            local bottomBorder = "^6╚" .. string.rep("═", totalWidth - 2) .. "╝^0"
            
            -- Print complete table
            print(topBorder .. "\n" .. 
                  title .. "\n" .. 
                  resourceRow .. "\n" ..
                  headersRow .. "\n" .. 
                  separator .. "\n" ..
                  versionsRow .. "\n" .. 
                  downloadRow .. "\n" .. 
                  bottomBorder)
            
            -- Print changelog separately
            print("^6Changes:\n^7" .. changelog)
        end
    else
        print("^6[".. resourceStatic .. "]^1 Unable to check for new version. Please contact Prompt.^0")
    end
end, "GET", "", {})

-- MapChainHandler functionality
local url = UrlData 
local resourceStatic = StaticName

-- Register map exists event
local existsName = resourceStatic .. ":mapExists"
RegisterNetEvent(existsName, function(cb)
    cb(true)
end)

-- Register full name send event
local fullNameSend = resourceStatic .. ":mapFullNameSend"
RegisterNetEvent(fullNameSend, function(returnEvent, id)
    local name = FullName
    TriggerEvent(returnEvent, name, id)
end)

-- Store full map names
local fullMaps = {}

-- Register full name receive event
local fullNameReceive = resourceStatic .. ":mapFullNameReceive"
RegisterNetEvent(fullNameReceive, function(name, id)
    fullMaps[id] = name
end)

-- Register final map check event
local finalName = resourceStatic .. ":mapFinal"
local finalChecked = false
RegisterNetEvent(finalName, function(allMaps, installedMaps)
    if finalChecked == false then 
        finalChecked = true
    
        if Debug == true then 
            print("^6[Test Map]^3 Checking for correct map data...^0")
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
            print("^6[Test Map]^2 Correct Map Data Installed.^0")
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
                print("^6[Test Map]^1 Test feature enabled. Downloading all files from the link: ^3" .. UrlCompat .. "^0")
                -- Implementation for downloading files would go here
            end
        end
    end
end)

if Debug then
    print("^6[Test Map]^2 Map handler initialized successfully.^0")
end
