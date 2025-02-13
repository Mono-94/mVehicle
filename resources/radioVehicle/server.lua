if GetResourceState('xsound') ~= 'started' then return end


RegisterNetEvent("mVehicle:SoundStatus", function(action, data)
   
    TriggerClientEvent("mVehicle:VehicleRadio", -1, action, data)
end)

lib.callback.register('mVehicle:radio:PlayList', function(source, action, data)

    local vehicle = Vehicles.GetVehicle(data.entity)

    print(json.encode(data), json.encode(vehicle))

    if action == 'saveSong' then

    elseif action == 'deleteSong' then

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
        end
    end

    Utils.Debug('info', 'Ped: %s, Vehicle: %s, Plate: %s, PlayerSeat: %s, isPedDriver: %s', playerPed, entity, plate,
        playerSeat, isPedDriver)
end)
