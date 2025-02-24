--- mVehicle
--- GitHub    :  https://github.com/Mono-94
--- Discord   :  https://discord.gg/Vk7eY8xYV2
--- Documents :  https://mono-94.github.io/mDocuments/
----------------------------------------------------------------------
--- Config -----------------------------------------------------------
Config                     = {}

--- Prints | Some extra dev tools
Config.Debug               = false

--- ox_inventory = 'ox' | qs-inventory = 'qs' not sure if it works
Config.Inventory           = 'ox'

--- Enable Bike Helmet
Config.EnableBikeHelmet    = true

--- Personal Vehicle Menu 
Config.PersonalVehicleMenu = true

--- Vehicle Density | 0.0 min | 1.0 max
Config.VehicleDensity      = {
    CloseAllVehicles = true,
    VehicleDensity = 1.0,
    RandomVehicleDensity = 1.0,
    ParkedVehicleDensity = 1.0
}

--- Persistent
--- Vehicle persistents in world
Config.Persistent          = false

--- Commands
Config.Commands            = {
    givecar = 'givecar',
    setcarowner = 'setcarowner',
    saveallcars = 'saveAllcars',
    spawnallcars = 'spawnAllcars'
}

--- Manage tr2 trailer
Config.TargetTrailer       = true

----------------------------------------------------------------------
--- Carkeys
Config.ItemKeys            = false    -- false = Vehicles DB

Config.CarKeyItem          = 'carkey' -- item name

Config.DoorKeyBind         = 'U'

Config.KeyDelay            = 500

Config.KeyDistance         = 5

--- Engine ignition need keys or hotwire
Config.VehicleEngine       = {
    ToggleEngine = false,
    KeyBind = 'M',
    keepEngineOnWhenLeave = true, -- requires ToggleEngine
}
----------------------------------------------------------------------
-- Seat Shuffle front + back seats | SHIFT + E
Config.SeatShuffle         = true

----------------------------------------------------------------------
--- Vehicle Radio
--- xSound Dependency | https://github.com/Xogy/xsound 
Config.Radio               = {
    command = false, -- false or string 
    KeyBind = false, -- false or string
    radial = true,   -- true/false
    distance = 5,    -- distance sound
}

----------------------------------------------------------------------
-- Plate
--MAX 8 CHAR
Config.PlateGenerate       = ".... ..."
-- . = random number or letter
-- 1 = random number
-- A = random letter
-- SPACE IS A CHAR


-- Generate random plate in metadata item, only ox_inventory
Config.FakePlateItem = {
    item = 'fakeplate',
    ChangePlateTime = 10000 -- in ms
}
----------------------------------------------------------------------

---SetFuel / client side
Config.SetFuel = function(vehicleEntity, fuelLevel)
    -- LegacyFuel example
    -- exports.LegacyFuel:SetFuel(vehicleEntity, fuelLevel)

    -- Native
    SetVehicleFuelLevel(vehicleEntity, fuelLevel)
end

Config.LockPickItem = {
    item = 'lockpick',
    skillCheck = function()
        local success = lib.skillCheck({ 'easy', 'easy' })
        return success
    end,
    dispatch = function(plyServerId, vehicleEntity, coords)
        print(plyServerId, vehicleEntity, coords)
    end
}

Config.HotWireItem = {
    item = 'wirecutt',
    skillCheck = function()
        local success = lib.skillCheck({ 'easy', 'easy' })
        return success
    end,
    dispatch = function(plyServerId, vehicleEntity, coords)
        print(plyServerId, vehicleEntity, coords)
    end
}

-------------------------------------------------------
Config.VehicleTypes = {
    ['car'] = { 'automobile', 'bicycle', 'bike', 'quadbike', 'trailer', 'amphibious_quadbike', 'amphibious_automobile' },
    ['boat'] = { 'submarine', 'submarinecar', 'boat' },
    ['air'] = { 'blimp', 'heli', 'plane' },
}
