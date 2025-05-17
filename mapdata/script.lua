CreateThread(function()
    local exists = false 
    TriggerEvent("prompt:mapdata_exists", function(varExists)
        exists = varExists
    end)

    -- Legacy event support
    local legacy = false 
    TriggerEvent("lyn-mapdata:exists", function(res)
        legacy = res
    end)

    Wait(500)

    if legacy == true then 
        print("^8 !!!! You have also a legacy mapdata version installed (old version) alongside the new one, please consider deleting it so script can run the new version")
    end

    -- Legacy mapdata support
    for i = 1, #Maps do 
        if Debug == true then 
            print("Adding legacy mapdata support for: ", Maps[i])
        end
        local mapdataExists = Maps[i].. ":mapDataExists"
        RegisterNetEvent(mapdataExists, function(cb)
            cb(true)
        end)
    end
end)

RegisterNetEvent("prompt:mapdata_sendList", function(returnevent)
    if Debug == true then
        print("Getting maps in mapdata (return event) To: ", returnevent)
    end
    TriggerEvent(returnevent, Maps)
end)

RegisterNetEvent("prompt:mapdata_exists", function(returnValue)
    returnValue(true)
end)
