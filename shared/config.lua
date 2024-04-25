Config = {}

Config.lang = 'EN' -- ES / EN

Config.Debug = true

Config.Persistent = true    -- Vehicles persistentes? Los vehiculos se generaran en el ultimo lugar donde el servidor se reinicio/apago

Config.Framework = 'esx'    -- esx, ox, standalone 

Config.Inventory = 'ox'     -- ox_inventory = 'ox' | qs-inventory = 'qs'  -- To give carkey item

Config.TargetTrailer = true -- manage tr2 trailer

-- Carkeys

Config.ItemKeys = false           -- false = Vehicles DB

Config.CarKeyItem = 'carkey'      -- item name

Config.TargetOrKeyBind = 'target' -- 'target' or 'keybin'

Config.DoorKeyBind = 'U'

Config.KeyDelay = 500

Config.KeyDistance = 20

Config.KeyMenu = true -- Radial menu to manage vehicles

-- Generate random plate in metadata item, only ox_inventory
Config.FakePlateItem = 'fakeplate'

-- Put Your Garage names here
Config.GarageNames = { 'Pillbox Hill' }

-- on Vehicles delete
Config.DefaultImpound = {
    impoundName = 'Impound',
    price = 0,
    note = 'Vehicle seized by the municipal service'
}

Config.Commands = {
    givecar = 'givecar',
    setcarowner = 'setcarowner',
    saveallcars = 'saveAllcars',
    spawnallcars = 'spawnAllcars'
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
