if not Config.PersonalVehicleMenu then return end


local function Update(keys, id)
    return MySQL.update.await('UPDATE `owned_vehicles` SET `keys` = ? WHERE id = ?', { json.encode(keys), id })
end



lib.callback.register('mVehicle:VehicleMenu', function(source, action, data, targetPlayer)
    local Vehicle = Vehicles.GetVehicleByPlate(data.plate)

    local spawned = true
    local keys = {}

    if not Vehicle then
        Vehicle = Vehicles.GetVehicleByID(data.id)
        keys = Vehicle.keys
        spawned = false
    end

    if not Vehicle then
        Utils.Debug('error', 'Vehicle not found')
        return false
    end

    if type(keys) == "string" then
        keys = json.decode(keys)
    end



    if action == 'addkey' then
        local target = Identifier(targetPlayer)
        if target then
            if not spawned then
                if keys[target] then
                    return false
                end
                keys[target] = GetName(targetPlayer)
                Update(keys, data.id)
            else
                local adeed = Vehicle.AddKey(targetPlayer)
                return adeed
            end

            return true
        end
    elseif action == 'removekey' then
        if not spawned then
            if not keys[targetPlayer] then
                return false
            end
            keys[targetPlayer] = nil
            Update(keys, data.id)
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
