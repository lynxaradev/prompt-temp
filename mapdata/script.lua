-- script.lua for test-mapdata
-- Combined mapversioncheck and mapdatahandler functionality

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

-- MapDataHandler functionality
local events = {}

-- Register mapdata exists event
RegisterNetEvent("lyn-mapdata:exists", function(cb)
    cb(true)
end)

-- Check if another mapdata is already installed
CreateThread(function()
    local exists = false 
    TriggerEvent("lyn-mapdata:exists", function(exists)
        if exists then
            exists = true
        end
    end)

    if exists == true then 
        print("^6[Test MapData]^1 Map data already exists. There must be only one mapdata installed!^0")
    end
end)

-- Register events for each map in the Maps table
for i = 1, #Maps do
    local eventName = Maps[i] .. ":mapDataExists"
    if Debug == true then 
        print("^6[Test MapData]^3 Creating event: ^7" .. eventName .. "^0")
    end
    local event = RegisterNetEvent(eventName, function(cb) 
        cb(true)
    end)
    table.insert(events, event)
end

if Debug then
    print("^6[Test MapData]^2 MapData handler initialized successfully.^0")
end
