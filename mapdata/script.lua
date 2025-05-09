Maps = {
    "Sheriff"
}

CreateThread(function()
    local exists = false 
    TriggerEvent("prompt:mapdata_exists", function(varExists)
        exists = varExists
    end)

    local legacy = false 
    TriggerEvent("lyn-mapdata:exists", function(res)
        legacy = res
    end)

    Wait(500)
    if exists == true then 
        print("^8 !!!! You have multiple instances of mapdata that can cause incompatibility issues !!!!^7")
    end

    if legacy == true then 
        print("^8 !!!! You have legacy mapdata installed (old version), please consider deleting it so script can suggest the new version")
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
