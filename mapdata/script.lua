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

    if legacy == true then 
        print("^8 !!!! You have also a legacy mapdata version installed (old version) alongside the new one, please consider deleting it so script can run the new version")
    end

    -- Legacy check
    local legacyMaps = {}
    for i = 1, #Maps do 
        local legacyCheckName = Maps[i].. ":mapExists"
        local legacyExists = false

        TriggerEvent(legacyCheckName, function(existsCB)
            legacyExists = existsCB
        end)
        Wait(100)

        if legacyExists == true then
            if Debug == true then
                print("Found legacy map: ", Maps[i])
            end
            table.insert(legacyMaps, Maps[i])
        end
    end

    if #legacyMaps > 0 then
        if Debug == true then 
            print("Turning on legacy support")
        end

        local newMaps = {}
        for i = 1, #Maps do 
            local isLegacy = false 
            for j = 1, #legacyMaps do
                if legacyMaps[j] == Maps[i] then
                    isLegacy = true
                    break
                end
            end

            if isLegacy == false then
                table.insert(newMaps, Maps[i])
            end

            if Debug == true then 
                print("Adding legacy mapdata support for: ", Maps[i])
            end
            local mapdataExists = Maps[i].. ":mapDataExists"
            RegisterNetEvent(mapdataExists, function(cb)
                cb(true)
            end)
        end

        for i = 1, #newMaps do
            if Debug == true then
                print("Adding fake events for: ", newMaps[i])
            end
            local existsName = newMaps[i].. ":mapExists"
            local nameSend = newMaps[i].. ":mapFullNameSend"
            local final = newMaps[i].. ":mapFinal"

            RegisterNetEvent(existsName, function(cb)
                cb(true)
            end)

            RegisterNetEvent(nameSend, function(returnEvent, id)
                TriggerEvent(returnEvent, newMaps[i], id)
            end)

            RegisterNetEvent(final, function()
                -- do nothing
            end)
        end
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
