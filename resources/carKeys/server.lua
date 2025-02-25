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
    local hasKeys = false

    if not Config.ItemKeys then
        if vehicle then
            hasKeys = (identifier == vehicle.owner) or vehicle.metadata.keys[identifier] ~= nil
        else
            local vehicledb = MySQL.single.await(Querys.getVehicleByPlateOrFakeplate, { data.plate, data.plate })

            if FrameWork == 'qbx' and vehicledb then
                vehicledb.parking = vehicledb.garage
                vehicledb.vehicle = vehicledb.mods
                vehicledb.owner = vehicledb.license
            end
            local metdata = json.decode(vehicledb.metadata) or { keys = {} }
            hasKeys = (identifier == vehicledb.owner) or metdata.keys[identifier] ~= nil
        end
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
