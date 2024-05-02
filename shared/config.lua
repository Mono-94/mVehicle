Config = {}

Config.lang = 'EN' -- ES / EN

Config.Debug = true

Config.Framework = 'esx'       -- esx, ox, standalone

Config.Inventory = 'ox'        -- ox_inventory = 'ox' | qs-inventory = 'qs'  -- To give carkey item

Config.TargetTrailer = false   -- manage tr2 trailer

--MAX 8 CHAR
Config.PlateGenerate = "1111AAAA"
-- . = random number or letter
-- 1 = random number
-- A = random letter
-- SPACE IS A CHAR

-- Carkeys

Config.ItemKeys = true           -- false = Vehicles DB

Config.CarKeyItem = 'carkey'      -- item name

Config.TargetOrKeyBind = 'target' -- 'target' or 'keybin'

Config.DoorKeyBind = 'U'

Config.KeyDelay = 500

Config.KeyDistance = 20

Config.KeyMenu = true -- Radial menu to manage vehicles

-- Put Your Garage names here
Config.GarageNames = { 'Pillbox Hill' }

-- on Vehicles delete or /dv
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

-- Generate random plate in metadata item, only ox_inventory
Config.FakePlateItem = {
    item = 'fakeplate',
    ChangePlateTime = 5000 -- in ms
}

Config.LockPickItem = {
    item = 'lockpick',
    skillCheck = function()
        local success = lib.skillCheck({ 'easy', 'easy' })
        return success
    end,
    dispatch = function(playerId, vehicleEntity, coords)
        -- print(playerId, vehicleEntity, coords)
    end
}

Config.HotWireItem = {
    item = 'wirecutt',
    skillCheck = function()
        local success = lib.skillCheck({ 'easy', 'easy' })
        return success
    end,
    dispatch = function(playerId, vehicleEntity, coords)
        --print(playerId, vehicleEntity, coords)
    end
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
