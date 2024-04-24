# mVehicles

## Features
- Fully compatible with ESX (100%), standalone (100% - requires database), and partially compatible with OX (some adaptations needed), and QB (not started).
- All vehicle models are persistent.
- Ability to add metadata to vehicles.
- Records total kilometers driven by vehicles.
- Key system via item or database.
  - Menu for sharing keys.
- Various administration commands:
  - `/givecar [source]`
  - `/setcarowner [source]`
  - `/saveAllcars true/false`: If true, deletes all vehicles; if false, only saves vehicles.
  - `/spawnAllcars`: Forces spawning of vehicles outside of garages.

## Other Features
- Target for managing the trailer tr2.

## Dependencies
* **OneSync**
* [OXMYSQL](https://github.com/overextended/oxmysql)
* [ox_lib](https://github.com/overextended/ox_lib)
* [ox_inventory](https://github.com/overextended/ox_inventory) (only keys as item)
* [ox_target](https://github.com/overextended/ox_target) (target Carkey and Trailer manager)

Recommended latest gameBuild ❗
[FiveM Server Commands](https://docs.fivem.net/docs/server-manual/server-commands#sv_enforcegamebuild-build)

Call resource via fxManifest:
```lua 
shared_scripts {
  '@mVehicle/import.lua'
}

```

<details>
<summary>Image</summary>

![GiveCar](https://i.imgur.com/3ja1LQG.png)

</details>



# Functions

**Vehicles.VehickeKeysMenu() Client**
```lua
--  all player vehicles
Vehicles.VehickeKeysMenu()

--  Specific plate, 
Vehicles.VehickeKeysMenu('MONO 420', function()
  print('On Close menu or Set/remove key player')
end)
``` 

**Vehicles.ItemCarKeysClient() Client**
* action = 'remove' or 'add' | string
* plate  =  vehicle plate    | string 
```lua
  Vehicles.ItemCarKeysClient(action, plate)
```

**Vehicles.ItemCarKeys() Server**
*  source = player source    | number 
* action = 'remove' or 'add' | string
* plate  =  vehicle plate    | string 
```lua
  Vehicles.ItemCarKeys(source, action, plate)
  -- or ox_inventory export 
  -- add
  exports.ox_inventory:AddItem(source, 'carkey', 1, { plate = plate })
  --remove 
  -- via ox_inventory export 
  exports.ox_inventory:RemoveItem(source, 'carkey', 1, { plate = plate })
```

  **Vehicles.CreateVehicle() Server**
```lua
Vehicles.CreateVehicle(VehicleData, CallBack)

local CreateVehicleData = {
    -- if vehicle temporary | date format 'YYYYMMDD HH:MM'     example '20240422 03:00'   - or false
    temporary = ?, 
     -- string or false, nil ...
    job = ?,
    -- Set vehicle Owner? if Temporary date set true
    setOwner = ?,  
    -- player identifier
    owner = ?,    
    -- same to owner  
    identifier = ?, 

    coords = vector4(1.0, 1.0, 1.0, 1.0),  -- Coords spawn table or vector 4

    -- Vehicle Data
    -- can set your custom props here or use lib.GetVehicleProps() table...
    vehicle = {                            
        model = 'sulta',                  
        plate = Vehicles.GeneratePlate(), 
        fuelLevel = 100,                  
        color1 = [0,0,0],
        color2 = [0,0,0],               
        
    },


Vehicles.CreateVehicle(CreateVehicleData, function(data, action)
   print(json.encode(data, { indent = true} ))
end)
}
```

**Vehicles.GetVehicle()** *Server*

```lua
local Vehicle = Vehicles.GetVehicle(entity) 

Vehicle.SetMetadata(key, value)
-- Example
-- Vehicle.SetMetadata('stolen', { stolenBy = 'Mono Garage'})

Vehicle.DeleteMetadata(key) 
-- Example
-- Vehicle.DeleteMetadata('stolen')

Vehicle.GetMetadata(key)     
-- Example
-- by key Vehicle.GetMetadata('stolen')  or  Vehicles.GetMetadata() return all
-- local metadata = Vehicle.GetMetadata('stolen')
-- print(metadata.stolenBy)   
--- or client/server State 
-- local metadata = Entity(data.entity).state.metadata
-- print(metadata.stolenBy)  

Vehicle.AddKey(source) 
Vehicle.RemoveKey(source)
Vehicle.SaveProps(props)

-- To use in garage script
Vehicle.StoreVehicle(parking, props, license)
Vehicle.RetryVehicle(coords)
Vehicle.ImpoundVehicle(parking, price, note, date)
Vehicle.RetryImpound(ToGarage, coords)

-- Set Fake Plate to vehicle
Vehicle.SetFakePlate('FAKETAXI')
-- To remove 
Vehicle.SetFakePlate(false)

-- Delete DataBase vehicle
Vehicle.DeleteVehicleDB()
```


**GetVehicleByPlate** *Server*
= Vehicles.GetVehicle()
```lua
 local Vehicles.GetVehicleByPlate(plate)
```

**Vehicles.GetVehicleId** *Server*
```lua 
local vehicle = Vehicles.GetVehicleId(id) 
```
**Delete All Vehicles** *Server*
```lua 
local AllVechiles = Vehicles.GetAllVehicles(identifier)
```

**Set Vehicle Owner** *Server*
```lua 
Vehicles.SetVehicleOwner({
    job = ?,
    owner = ?,
    parking = ?,
    plate = ?,
    type = ?,
    vehicle = ?,
})
```

**SetCarOwner** *Server*
```lua
Vehicles.SetCarOwner(src)
```


**Delete All Vehicles** *Server*
```lua 
Vehicles.DelAllVehicles() 
```

**save all vehicles** *Server*
true/false to delete vehicles
```lua 
Vehicles.SaveAllVehicles(delete)
```

**plate exists?** *Server*
return boolean
```lua 
Vehicles.PlateExist(plate) 
```

**Generate plate** *Server*
return plate string
```lua 
Vehicles.GeneratePlate()
```
