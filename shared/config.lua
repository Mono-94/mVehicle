Config = {}

Config.lang = 'EN' -- ES / EN       

Config.Debug = true

Config.Framework = 'esx' -- esx,ox,standalone,qb

Config.Inventory = 'ox'  -- ox_inventory = 'ox' | qs-inventory = 'qs'  -- To give carkey item

Config.TargetTrailer = true  -- manage tr2 traiel

-- Carkeys

Config.ItemKeys = false           -- false = Vehicles DB

Config.CarKeyItem = 'carkey'      -- item name

Config.TargetOrKeyBind = 'target' -- 'target' or 'keybin'

Config.DoorKeyBind = 'U'

Config.KeyDelay = 500

Config.KeyDistance = 20

Config.KeyMenu = true -- Radial menu to manage carkeys

-- Generate random plate in metadata item, only ox_inventory
Config.FakePlateItem = 'fakeplate'

-- Put Your Garage names here
Config.GarageNames = { 'Pillbox Hill' }

-- Defalut Impound info
-- Cuando ejecutas el comando /dv los vehiculos eliminados y generados por mVehicles iran al impound
Config.DefaultImpound = {
    impoundName = 'Impound',
    price = 100,
    note = 'Vehículo incautado por el ayuntamiento'
}

Config.Commands = {
    givecar = 'givecar',
    setcarowner = 'setcarowner',
    saveallcars = 'saveAllcars',
    spawnallcars = 'spawnAllcars'
}

LANG = {
    ['ES'] = {
        -- Trailer
        flip_trailer      = 'Voltear Remolque',
        up_dow_ramp       = 'Subir/Bajar Rampa',
        up_dow_platform   = 'Subir/Bajar Plataforma',
        attach_vehicle    = 'Acoplar Vehículo',
        dettach_vehicle   = 'Desacoplar Vehículo',
        -- Vehicle doors
        open_door         = 'Abrir Puerta',
        close_door        = 'Cerrar Puerta',

        -- Keys
        key_string        = 'Matrícula: %s',
        key_targetdoors   = 'Abrir / Cerrar Puertas',

        -- Givecar
        givecar_noty      = 'Ahora eres propietario de este vehículo %s',
        givecar_help      = 'Dar un vehículo a un jugador con múltiples opciones.',
        givecar_playerveh = 'Establecer como propiedad el vehículo en el que se encuentra un jugador',
        givecar_yes       = 'Sí',
        givecar_no        = 'No',
        givecar_menu1     = 'Modelo del vehículo',
        givecar_menu2     = 'Garaje',
        givecar_menu3     = '¿Vehículo temporal?',
        givecar_menu4     = 'Fecha',
        givecar_menu5     = 'Hora',
        givecar_menu6     = 'Minutos',
        givecar_menu7     = 'Color 1 Vehículo',
        givecar_menu8     = 'Color 2 Vehículo',


    },
    ['EN'] = {
        -- Trailer
        flip_trailer      = 'Flip Trailer',
        up_dow_ramp       = 'Raise/Lower Ramp',
        up_dow_platform   = 'Raise/Lower Platform',
        attach_vehicle    = 'Attach Vehicle',
        dettach_vehicle   = 'Detach Vehicle',
        -- Vehicle doors
        open_door         = 'Open Door',
        close_door        = 'Close Door',

        -- Keys
        key_string        = 'License Plate: %s',
        key_targetdoors   = 'Open / Close Doors',

        -- Givecar
        givecar_noty      = 'You are now the owner of this vehicle %s',
        givecar_help      = 'Give a vehicle to a player with multiple options.',
        givecar_playerveh = 'Set the vehicle the player is in as owned',
        givecar_yes       = 'Yes',
        givecar_no        = 'No',
        givecar_menu1     = 'Vehicle Model',
        givecar_menu2     = 'Garage',
        givecar_menu3     = 'Temporary Vehicle?',
        givecar_menu4     = 'Date',
        givecar_menu5     = 'Hour',
        givecar_menu6     = 'Minutes',
        givecar_menu7     = 'Vehicle Color 1',
        givecar_menu8     = 'Vehicle Color 2',
    }
}

Config.Locales = LANG[Config.lang]


function Notification(data)
    lib.notify({
        title = data.title,
        description = data.description,
        position = data.position or 'center-left',
        icon = data.icon or 'ban',
        type = data.type or 'warning',
        iconAnimation = data.iconAnimation or 'beat',
        iconColor = data.iconColor or '#C53030',
        duration = data.duration or 2000,
        showDuration = true,
    })
end
