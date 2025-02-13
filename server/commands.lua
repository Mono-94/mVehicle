lib.addCommand(Config.Commands.givecar, {
    help = locale('givecar_help'),
    params = { { name = 'target', type = 'number', help = 'Target Player' } },
    restricted = 'group.admin'
}, function(source, args, raw)
    local identifier = Identifier(args.target)
    local plate = Vehicles.GeneratePlate()

    if identifier then
        local vehicleData = lib.callback.await('mVehicle:GivecarData', source)

        if not vehicleData then return lib.print.info('Command "givecar" action cancelled') end

        local CreateData = {}


    
        CreateData.coords = GetCoords(args.target)
        CreateData.vehicle = {
            plate = plate,
            fuelLevel = 100,
            model = vehicleData.model,
        }

        CreateData.source = args.target
        CreateData.intocar = true
        CreateData.setOwner = true

        if vehicleData.job == '' then
            CreateData.job = nil
        else
            CreateData.job = vehicleData.job
        end


        if vehicleData.isTemporary then
            local date = os.date('%Y%m%d', math.floor(vehicleData.date / 1000))
            local hour = os.date('%H:%M', math.floor(vehicleData.hour / 1000))
            local time = date .. ' ' .. hour
            CreateData.temporary = time
        end

        if vehicleData.parking then
            CreateData.parking = vehicleData.parking
        end

        Vehicles.CreateVehicle(CreateData, function(vehicle)
            if DoesEntityExist(vehicle.entity) then

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
