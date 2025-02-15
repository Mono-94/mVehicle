if GetResourceState('xsound') ~= 'started' then return end


RegisterNetEvent("mVehicle:SoundStatus", function(action, data)
    TriggerClientEvent("mVehicle:VehicleRadio", -1, action, data)
end)

lib.callback.register('mVehicle:radio:PlayList', function(source, action, data)
    local entity = NetworkGetEntityFromNetworkId(data.networkId)

    local vehicle = Vehicles.GetVehicle(entity)
    print(json.encode(data, { indent = true }))

    if action == 'saveSong' then
        if vehicle then
            local metadata = vehicle.GetMetadata('radio')


            table.insert(metadata.playlist, {
                name = data.songName,
                link = data.songLink,
                fav = false,
            })

            vehicle.SetMetadata('radio', metadata)

            return metadata.playlist
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
        if not isPedDriver then return end

        local vehicle = Vehicles.GetVehicle(entity)

        if vehicle then
            local metadata = vehicle.GetMetadata('radio')

            if metadata and metadata.install then return end

            vehicle.SetMetadata('radio', { install = true, playlist = {} })
        else
            vehicle = Vehicles.GetVehicleByPlate(plate, true)

            if vehicle then
                local metadata = json.encode(vehicle.metadata)
            end
        end
    end

    Utils.Debug('info', 'Ped: %s, Vehicle: %s, Plate: %s, PlayerSeat: %s, isPedDriver: %s', playerPed, entity, plate,
        playerSeat, isPedDriver)
end)
