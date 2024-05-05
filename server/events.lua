-- entityCreated
AddEventHandler('entityCreated', function(entity)
    local entityType = GetEntityType(entity)

    if entityType == 2 then
        local motor = GetIsVehicleEngineRunning(entity)


        if motor then
            if math.random() <= 0.1 then
                SetVehicleDoorsLocked(entity, 2)
            end
        end

        if not motor then
            SetVehicleDoorsLocked(entity, 2)
        end
    end
end)

-- Vehicle deleted? send to impound
AddEventHandler('entityRemoved', function(entity)
    local vehicle = Vehicles.GetVehicle(entity)
    if vehicle then
        local impound = Config.DefaultImpound
        vehicle.ImpoundVehicle(impound.impoundName, impound.price, impound.note)
    end
end)


if GetConvar("mVehicle:Persistent", "false") == 'true' then
    -- on Resource ...
    AddEventHandler("onResourceStart", function(name)
        if name ~= GetCurrentResourceName() then return end
        Vehicles.SpawnVehicles()
    end)

    AddEventHandler('onResourceStop', function(name)
        if name ~= GetCurrentResourceName() then return end
        Vehicles.SaveAllVehicles()
    end)

    -- TxAdmin
    AddEventHandler("txAdmin:events:serverShuttingDown", function()
        Vehicles.SaveAllVehicles(true)
    end)

    AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
        print(eventData.secondsRemaining)
        if eventData.secondsRemaining == 60 then
            CreateThread(function()
                Wait(45000)
                Vehicles.SaveAllVehicles(true)
            end)
        end
    end)
end
