if not Config.PersonalVehicleMenu then return end


local function Update(metadata, id)
    return MySQL.update.await('UPDATE `owned_vehicles` SET `metadata` = ? WHERE id = ?', { json.encode(metadata), id })
end



lib.callback.register('mVehicle:VehicleMenu', function(source, action, data, targetPlayer)
    local Vehicle = Vehicles.GetVehicleByPlate(data.plate)
    local spawned = true

    local metadata = {}

    if not Vehicle then
        Vehicle = Vehicles.GetVehicleByID(data.id)
        if Vehicle then
            metadata = json.decode(Vehicle.metadata) or { keys = {} }
            spawned = false
        end
    end


    if not Vehicle then
        Utils.Debug('error', 'Vehicle not found')
        return false
    end


    if action == 'addkey' then
        local target = Identifier(targetPlayer)
        if target then
            if not spawned then
                if metadata.keys[target] then
                    return false
                end
                metadata.keys[target] = GetName(targetPlayer)
                Update(metadata, data.id)
            else
                local adeed = Vehicle.AddKey(targetPlayer)
                return adeed
            end

            return true
        end
    elseif action == 'removekey' then
        if not spawned then
            if not metadata.keys[targetPlayer] then
                return false
            end
            metadata.keys[targetPlayer] = nil
            Update(metadata, data.id)
        else
            local remove = Vehicle.RemoveKey(targetPlayer)
            return remove
        end

        return true
    elseif action == 'setBlip' then
        if Vehicle then
            return { coords = Vehicle.GetCoords(), model = Vehicle.vehicle.model }
        end
    end

    return false
end)
