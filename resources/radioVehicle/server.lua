if GetResourceState('xsound') ~= 'started' then return end

RegisterNetEvent("mVehicle:SoundStatus", function(action, data)
    TriggerClientEvent("mVehicle:VehicleRadio", -1, action, data)
end)

lib.callback.register('mVehicle:radio:PlayList', function(source, action, data)
    local entity = NetworkGetEntityFromNetworkId(data.networkId)
    local vehicle = Vehicles.GetVehicle(entity)

    if action == 'saveSong' then
        if vehicle then
            local metadata = vehicle.GetMetadata('radio')

            for _, song in ipairs(metadata.playlist) do
                if song.link == data.songLink then
                    return metadata.playlist
                end
            end

            table.insert(metadata.playlist, {
                name = data.songName,
                link = data.songLink,
                fav = false,
            })

            vehicle.SetMetadata('radio', metadata)

            return metadata.playlist
        else
            vehicle = Vehicles.GetVehicleByPlate(data.plate, true)

            if vehicle then
                local metadata = json.decode(vehicle.metadata)
                if metadata and metadata.radio then
                    for _, song in ipairs(metadata.radio.playlist) do
                        if song.link == data.songLink then
                            return metadata.radio.playlist
                        end
                    end

                    MySQL.update(Querys.saveMetadata, json.encode(metadata), data.plate)

                    return metadata.radio.playlist
                end
            end
        end
    elseif action == 'deleteSong' then
        if vehicle then
            local metadata = vehicle.GetMetadata('radio')

            for i, song in ipairs(metadata.playlist) do
                if song.link == data.songLink then
                    table.remove(metadata.playlist, i)
                    break
                end
            end

            vehicle.SetMetadata('radio', metadata)

            return metadata.playlist
        else
            vehicle = Vehicles.GetVehicleByPlate(data.plate, true)

            if vehicle then
                local metadata = json.decode(vehicle.metadata)
                if metadata and metadata.radio then
                    for i, song in ipairs(metadata.radio.playlist) do
                        if song.link == data.songLink then
                            table.remove(metadata.radio.playlist, i)
                            break
                        end
                    end

                    MySQL.update(Querys.saveMetadata, json.encode(metadata), data.plate)

                    return metadata.radio.playlist
                end
            end
        end
    elseif action == 'favSong' then
        if vehicle then
            local metadata = vehicle.GetMetadata('radio')

            for i, song in ipairs(metadata.playlist) do
                if song.link == data.songLink then
                    song.fav = not song.fav
                    break
                end
            end

            vehicle.SetMetadata('radio', metadata)

            return metadata.playlist
        else
            vehicle = Vehicles.GetVehicleByPlate(data.plate, true)

            if vehicle then
                local metadata = json.decode(vehicle.metadata)
                if metadata and metadata.radio then
                    for i, song in ipairs(metadata.radio.playlist) do
                        if song.link == data.songLink then
                            table.remove(metadata.radio.playlist, i)
                            break
                        end
                    end

                    MySQL.update(Querys.saveMetadata, json.encode(metadata), data.plate)

                    return metadata.radio.playlist
                end
            end
        end
    end
end)


exports('mradio', function(event, item, inventory, slot, data)
    local playerPed = GetPlayerPed(inventory.id)
    local entity = GetVehiclePedIsIn(playerPed, false)
    local playerSeat = GetPedInVehicleSeat(entity, -1)
    local isPedDriver = playerSeat == playerPed
    local plate = GetVehicleNumberPlateText(entity)


    if event == 'usingItem' then
        if not isPedDriver then return false end

        local vehicle = Vehicles.GetVehicle(entity)

        if vehicle then
            local metadata = vehicle.GetMetadata('radio')

            if metadata and metadata.install then return false end

            vehicle.SetMetadata('radio', { install = true, playlist = {} })
            exports.ox_inventory:RemoveItem(inventory.id, item.name, 1, nil, slot)

            return true
        else
            vehicle = Vehicles.GetVehicleByPlate(plate, true)

            if vehicle then
                local metadata = json.decode(vehicle.metadata)
                if not metadata then metadata = {} end
                if metadata.radio.install then return end
                metadata.radio = { install = true, playlist = {} }
                MySQL.update(Querys.saveMetadata, json.encode(metadata), plate)
                exports.ox_inventory:RemoveItem(inventory.id, item.name, 1, nil, slot)
                return true
            end
        end
    end
end)
