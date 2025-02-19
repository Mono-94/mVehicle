local PlateCron = {}

function DeleteTemporary(plate, hour, min)
    if PlateCron[plate] then return end

    local expression = ('%s %s * * *'):format(min, hour)

    lib.cron.new(expression, function(task, date)
        PlateCron[plate] = false

        MySQL.execute(Querys.deleteByPlate, { plate })

        local vehicle = Vehicles.GetVehicleByPlate(plate)

        if vehicle then vehicle.DeleteVehicle(false) end

        task:stop()
    end, { debug = Config.Debug })

    PlateCron[plate] = true
end

function CheckTemporary(data)
    if data.metadata.temporary then
        local datetime = data.metadata.temporary
        local date = datetime:sub(1, 8)
        local time = datetime:sub(10)
        local actualtime = os.time()

        local current_date = os.date('%Y%m%d', actualtime)
        local current_hour = os.date('%H', actualtime)
        local current_minute = os.date('%M', actualtime)

        local metadata_hour = tonumber(time:sub(1, 2))
        local metadata_minute = tonumber(time:sub(4))

        if current_date == date then
            if tonumber(current_hour) > metadata_hour or tonumber(current_minute) > metadata_minute then
                MySQL.execute(Querys.deleteByPlate, { data.plate })
                if DoesEntityExist(data.entity) then
                    DeleteEntity(data.entity)
                end
                Vehicles.Vehicles[data.entity] = nil
                return true
            else
                DeleteTemporary(data.plate, metadata_hour, metadata_minute)
                return false
            end
        end
    end
    return false
end

lib.callback.register('mVehicle:VehicleState', function(source, action, data)
    local vehicle = nil
    if data then
        vehicle = Vehicles.GetVehicleByPlate(data.plate)
    end

    if action == 'update' then
        if vehicle then
            vehicle.SaveLeftVehicle(data.coords, data.props, data.mileage)
        else
            MySQL.update(Querys.saveLeftVehicle,
                { math.floor(data.mileage * 100), data.coords, json.encode(data.props), data.plate })
        end
    elseif action == 'savetrailer' then
        return vehicle and vehicle.CoordsAndProps(data.coords, data.props)
    elseif action == 'addkey' then
        if data.serverid == source and not Config.Utils.Debug then return end
        local target = Identifier(data.serverid)

        if target then
            if not data.keys then data.keys = {} end
            if data.keys[target] then return end
            data.keys[target] = GetName(data.serverid)
            if vehicle then
                vehicle.AddKey(data.serverid)
            else
                MySQL.update(Querys.saveKeys, { json.encode(data.keys), data.plate })
            end
        end
    elseif action == 'deletekey' then
        if vehicle and data.identifier then
            vehicle.RemoveKey(data.identifier)
        else
            MySQL.update(Querys.saveKeys, { json.encode(data.keys), data.plate })
        end
    elseif action == 'getkeys' then
        local identifier = Identifier(source)
        return MySQL.query.await(Querys.getKeys, { identifier })
    elseif action == 'getVeh' then
        local vehicle = Vehicles.GetVehicleByPlate(data, true)

        if vehicle then
            return { vehicle = true, mileage = vehicle.mileage }
        else
            return false
        end
    end
end)


-- Close doors on entityCreated
AddEventHandler('entityCreated', function(entity)
    if not Config.VehicleDensity.CloseAllVehicles then return end
    if DoesEntityExist(entity) then
        local entityType = GetEntityType(entity)

        if entityType == 2 then
            SetVehicleDoorsLocked(entity, 2)
        end
    end
end)


-- TxAdmin
AddEventHandler("txAdmin:events:serverShuttingDown", function()
    if Config.Persistent then Vehicles.SaveAllVehicles() end
end)

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if eventData.secondsRemaining == 60 and Config.Persistent then
        Citizen.CreateThread(function()
            Citizen.Wait(50000)
            Vehicles.SaveAllVehicles(true)
        end)
    end
end)
