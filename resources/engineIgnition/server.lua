lib.callback.register('mVehicle:VehicleEngine', function(source, data)
    local identifier = Identifier(source)
    local entity = NetworkGetEntityFromNetworkId(data.NetId)
    local vehicle = Vehicles.GetVehicle(entity)
    local vehicleKeys = {}
    local hasKeys = false

    if not Config.ItemKeys then
        local vehicledb = MySQL.single.await(Querys.getVehicleByPlateOrFakeplate, { data.plate, data.plate })

        if FrameWork == 'qbx' and vehicledb then
            vehicledb.parking = vehicledb.garage
            vehicledb.vehicle = vehicledb.mods
            vehicledb.owner = vehicledb.license
        end
        
        if not vehicledb and vehicle then
            vehicledb = {
                keys = vehicle.GetKeys,
                owner = vehicle.owner,
             }
             vehicleKeys = vehicle.GetKeys
        elseif vehicledb then
            vehicleKeys = json.decode(vehicledb.metadata) or { keys = {} }
            if not vehicleKeys.keys then
                vehicleKeys.keys = {}
            end
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
        return true
    else
        return false
    end
end)


