lib.addCommand(Config.Commands.givecar, {
    help = locale('givecar_help'),
    params = { { name = 'target', type = 'number', help = 'Target Player' } },
    restricted = 'group.admin'
}, function(source, args, raw)
    local identifier = Identifier(args.target)

    if identifier then
        local vehicleData = lib.callback.await('mVehicle:GivecarData', source)
        if not vehicleData then return lib.print.info('Command "givecar" action cancelled') end
        local CreateData = {}
        local ped = GetPlayerPed(args.target)

        CreateData.coords = GetCoords(args.target)
        CreateData.plate = Vehicles.GeneratePlate()
        CreateData.vehicle = {
            plate = CreateData.plate,
            fuelLevel = 100,
            model = vehicleData.model,
            color1 = vehicleData.color1,
            color2 = vehicleData.color2
        }
        CreateData.identifier = identifier
        CreateData.setOwner = true
        CreateData.parking = vehicleData.parking
        
        if vehicleData.job == '' then
            CreateData.job = nil
        else
            CreateData.job = vehicleData.job
        end


        if vehicleData.isTemporary then
            local date = math.floor(vehicleData.date / 1000)
            date = os.date('%Y%m%d', date)

            local hour = math.floor(vehicleData.hour / 1000)
            hour = os.date('%H:%M', hour)

            local time = date .. ' ' .. hour
            CreateData.temporary = time
        end


        Vehicles.CreateVehicle(CreateData, function(vehicle)
            if DoesEntityExist(vehicle.entity) then
                TaskWarpPedIntoVehicle(ped, vehicle.entity, -1)
                if Config.ItemKeys then
                    Vehicles.ItemCarKeys(args.target, 'add', CreateData.plate)
                end
                Notification(args.target, {
                    title = 'GiveCar',
                    description = locale('givecar_noty'):format(args.target),
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
    help = locale('givecar_playerveh'),
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


if Config.Debug then
    RegisterServerEvent('getEntityVehicle', function(netid)
        local entity = NetworkGetEntityFromNetworkId(netid)

        if DoesEntityExist(entity) then
            local vehicle = Vehicles.GetVehicle(entity)

            print(vehicle.plate, vehicle.owner)
        else
            print('Vehicle Entity does exists')
        end
    end)
end
