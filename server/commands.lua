lib.addCommand(Config.Commands.givecar, {
    help = Config.Locales.givecar_help,
    params = { { name = 'target', type = 'number', help = 'Target Player' } },
    restricted = 'group.admin'
}, function(source, args, raw)
    local identifier = Identifier(args.target)
    if identifier then
        local vehicleData = lib.callback.await('mVehicle:GivecarData', source)
        if not vehicleData then return lib.print.info('Command "givecar" action cancelled') end
        local data = {}
        local ped = GetPlayerPed(args.target)

        data.coords = GetCoords(args.target)
        data.plate = Vehicles.GeneratePlate()
        data.vehicle = {
            plate = data.plate,
            fuelLevel = 100,
            model = vehicleData[1],
            color1 = vehicleData[7],
            color2 = vehicleData[8]
        }
        data.identifier = identifier
        data.setOwner = true
        data.parking = vehicleData[2]

        if vehicleData[3] then
            local timestamp = math.floor(vehicleData[4] / 1000)
            local date = nil
            if vehicleData[5] and vehicleData[6] then
                local hour = tonumber(vehicleData[5])
                local min = tonumber(vehicleData[6])

                date = os.date('%Y%m%d %H:%M', timestamp)
                date = date:gsub('%d%d:%d%d$', ('%02d:%02d'):format(hour, min))
            elseif vehicleData[5] then
                local hour = tonumber(vehicleData[5])
                date = os.date('%Y%m%d %H:%M', timestamp)
                date = date:gsub('%d%d:%d%d$', ('%02d:00'):format(hour))
            else
                date = os.date('%Y%m%d %H:00', timestamp)
            end

            data.temporary = date
        end

        Vehicles.CreateVehicle(data, function(vehicle)
            if DoesEntityExist(vehicle.entity) then
                TaskWarpPedIntoVehicle(ped, vehicle.entity, -1)
                if Config.ItemKeys then
                    Vehicles.ItemCarKeys(args.target, 'add', data.plate)
                end
                Notification(args.target, {
                    title = 'GiveCar',
                    description = Config.Locales.givecar_noty:format(args.target),
                    type = 'success',
                    icon = 'database',
                    iconColor = 'green'
                })
            end
        end)
    else
        lib.print.error(("Command 'givecar' source [ %s ] not found "):format(args.target))
    end
end)


lib.addCommand(Config.Commands.setcarowner, {
    help = Config.Locales.givecar_playerveh,
    params = {
        {
            name = 'target',
            type = 'number',
            help = 'Target Player',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    Vehicles.SetCarOwner(args.target)
end)



lib.addCommand(Config.Commands.saveallcars, {
    help = 'Save all vehicles, delete option ',
    params = {
        {
            name = 'delete',
            type = 'string',
            help = 'Delete Vehicles?',
            optional = true,
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    if args.delete == 'true' then
        Vehicles.SaveAllVehicles(true)
    else
        Vehicles.SaveAllVehicles(false)
    end
end)


lib.addCommand(Config.Commands.spawnallcars, {
    help = 'Force to spawn all vehicles',
    restricted = 'group.admin'
}, function(source, args, raw)
    Vehicles.SpawnVehicles()
end)
