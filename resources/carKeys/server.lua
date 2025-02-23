local sendNotification = function(src, data)
    Notification(src, {
        title = data.modelName,
        description = (data.Status == 2 and locale('open_door') or locale('close_door')),
        icon = (data.Status == 2 and 'lock-open' or 'lock'),
        iconColor = (data.Status == 2 and '#77e362' or '#e36462'),
    })
end

lib.callback.register('mVehicle:VehicleDoors', function(source, data)
    local identifier = Identifier(source)
    local entity = NetworkGetEntityFromNetworkId(data.NetId)
    local vehicle = Vehicles.GetVehicle(entity)
    local vehicleKeys = {}
    local hasKeys = false

    if not Config.ItemKeys then
        local vehicledb = MySQL.single.await(Querys.getVehicleByPlateOrFakeplate, { data.plate, data.plate })

        if not vehicledb and vehicle then
            vehicledb = { keys = vehicle.GetKeys }
            vehicleKeys = vehicle.GetKeys
        elseif vehicledb then
            vehicleKeys = json.decode(vehicledb.metadata) or { keys = {} }
        else
            return false
        end

        if not vehicleKeys then
            return false
        end

        hasKeys = (identifier == vehicledb.owner) or vehicleKeys.keys[identifier] ~= nil
    else
        hasKeys = true
    end

    if hasKeys then
        local doorStatus = (data.Status == 2) and 0 or 2
        SetVehicleDoorsLocked(entity, doorStatus)
        if vehicle then vehicle.SetMetadata('DoorStatus', doorStatus) end

        sendNotification(source, data)
        return true
    else
        return false
    end
end)
