-- API Server Script for Mapdata Component
-- This script would be served from your API server to the mapdata component

Config.debug = false

-- This function would be executed when the script is loaded by the mapdata component
local function Initialize()
    print("^6[API-Mapdata]^3 Initializing mapdata component from API server...^0")
    
    -- Access local variables from the loader script
    local maps = Maps -- From token.lua
    local mapdataId = MapdataId -- From token.lua
    local debug = Config.Debug -- From config.lua
    
    -- Register our existence event
    RegisterNetEvent(mapdataId .. ":exists", function(cb)
        cb(true)
    end)
    
    -- Register events for each map in our list
    for i = 1, #maps do
        local eventName = maps[i] .. ":mapDataExists"
        if debug then 
            print("^6[Mapdata]^3 Creating event: ^0" .. eventName)
        end
        RegisterNetEvent(eventName, function(cb) 
            cb(true)
        end)
    end
    
    if debug then
        print("^6[Mapdata]^2 Map data system initialized successfully.^0")
    end
end

-- Execute the initialization function
Initialize()
