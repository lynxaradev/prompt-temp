RegisterNetEvent("prompt:mapdata_sendList", function(returnevent)
    if Debug == true then
        print("Getting maps in mapdata (return event) To: ", returnevent)
    end
    TriggerEvent(returnevent, Maps)
end)

RegisterNetEvent("prompt:mapdata_exists", function(returnValue)
    returnValue(true)
end)
