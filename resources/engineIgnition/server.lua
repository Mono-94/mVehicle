lib.callback.register('mVehicle:VehicleEngine', function(source, data)
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
        return true
    else
        return false
    end
end)
