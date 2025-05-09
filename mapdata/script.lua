CreateThread(function()
    -- pcalling an event to check if mapdata already exists (prompt:mapdata_initialized). If exists, not creating event
    local error = pcall(function()
        TriggerEvent("prompt:mapdata_initialized")
    end)
    if not error then
        -- Creating event to check if mapdata already exists (prompt:mapdata_initialized)
        RegisterNetEvent("prompt:mapdata_initialized", function()
            -- do something
        end)

        RegisterNetEvent("prompt:mapdata_sendList", function(returnevent)
            TriggerEvent(returnevent, Maps)
        end)
    else 
        print("Mapdata already exists somewhere, you have multiple mapdata scripts loaded.")
    end
end)
