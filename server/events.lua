-- entityCreated
AddEventHandler('entityCreated', function(entity)
    if not DoesEntityExist(entity) then return end
    local entityType = GetEntityType(entity)

    if entityType == 2 then
        local engine = GetIsVehicleEngineRunning(entity)


        if engine then
            if math.random() <= 0.1 then
                SetVehicleDoorsLocked(entity, 2)
            end
        end

        if not engine then
            SetVehicleDoorsLocked(entity, 2)
        end
    end
end)


local vType = function(type)
    for vehicleType, types in pairs(Config.VehicleTypes) do
        for _, v in ipairs(types) do
            if v == type then
                return Config.DefaultImpound[vehicleType]
            end
        end
    end
end

-- Vehicle deleted? send to impound
if Config.ImpoundVehicledelete then
    AddEventHandler('entityRemoved', function(entity)
        local vehicle = Vehicles.GetVehicle(entity)
        if vehicle then
            if DoesEntityExist(vehicle.entity) then
                vehicle.ImpoundVehicle(vType(vehicle.type), Config.DefaultImpound.price, Config.DefaultImpound.note)
            end
        end
    end)
end

if GetConvar("mVehicle:Persistent", "false") == 'true' then
    -- on Resource

    AddEventHandler("onResourceStart", function(name)
        if name ~= GetCurrentResourceName() then return end
        Vehicles.SpawnVehicles()
    end)

    --
    AddEventHandler('onResourceStop', function(name)
        if name ~= GetCurrentResourceName() then return end
        Vehicles.SaveAllVehicles(true)
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
end
