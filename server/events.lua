AddEventHandler('entityCreated', function(entity)
    local entityType = GetEntityType(entity)
    if entityType == 2 then
        if GetEntityPopulationType(entity) > 5 then
            return
        end

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
    if eventData.secondsRemaining == 60 then
        CreateThread(function()
            Wait(45000)
            Vehicles.SaveAllVehicles(true)
        end)
    end
end)
