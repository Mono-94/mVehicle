# mVehicles *NEW MONO_CARKEYS* 
*This  is not a garage system, it is only to manage vehicles, you can use this code simply for the key system.*

## Features
- Fully compatible with ESX , standalone (requires database), OX Everything works, but the vehicles do not spawn when the server loads, pending.
- Vehicle are persistent.
- Ability to add metadata to vehicles.
- Records total kilometers driven by vehicles.
- Key system via item or database.
- Menu for sharing keys.
- FakePlate *only works with vehicles spawned by the Vehicles.CreateVehicle() and ox_inventory item*
- ## **Commands**
 - `/givecar [source]`
 - `/setcarowner [source]`
 - `/saveAllcars true/false`: If true, deletes all vehicles; if false, only saves vehicles.
 - `/spawnAllcars`: Forces spawning of vehicles outside of garages.
<details>
<summary>Image</summary>

![GiveCar](https://i.imgur.com/3ja1LQG.png)

![CarKeysMenu](https://i.imgur.com/b3eAY84.png)

![ManageVehicleKeys](https://i.imgur.com/82KfzBc.png)
</details>

## Other Features
- Target for managing the trailer tr2.

## Dependencies
* **OneSync**
* [OXMYSQL](https://github.com/overextended/oxmysql)
* [ox_lib](https://github.com/overextended/ox_lib)
* [ox_inventory](https://github.com/overextended/ox_inventory) (only keys as item)
* [ox_target](https://github.com/overextended/ox_target) (target Carkey and Trailer manager)

Recommended latest 
[FiveM  GameBuild](https://docs.fivem.net/docs/server-manual/server-commands#sv_enforcegamebuild-build)

## Shared file
```lua 
shared_scripts { '@mVehicle/import.lua' }
```


## Install 
1. **update SQL**
2. **Server.cfg**
3. **set mVehicle:Persistent true/false** (Default false) 
4. **start the code after the dependencies of ox and your framework**


<details>
<summary>SQL </summary>

# DataBase 
## ESX 
- Original owned_vehicles 
- - to use it 'standalone' use this same database
```sql
CREATE TABLE `owned_vehicles` (
  `owner` varchar(60) DEFAULT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `job` varchar(20) DEFAULT NULL,
  `stored` tinyint(4) NOT NULL DEFAULT 0,
  `parking` VARCHAR(60) DEFAULT NULL,
  `pound` VARCHAR(60) DEFAULT NULL
) ENGINE=InnoDB;
```

- To inssert new
```sql
ALTER TABLE `owned_vehicles`
ADD COLUMN `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST,
ADD COLUMN `mileage` int(11) DEFAULT 0,
ADD COLUMN `coords` longtext,
ADD COLUMN `lastparking` varchar(100),
ADD COLUMN `keys` longtext DEFAULT '[]',
ADD COLUMN `metadata` longtext
```



## OX 
- Original table
```sql
CREATE TABLE
  IF NOT EXISTS `vehicles` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `plate` CHAR(8) NOT NULL DEFAULT '',
    `vin` CHAR(17) NOT NULL,
    `owner` INT UNSIGNED NULL DEFAULT NULL,
    `group` VARCHAR(50) NULL DEFAULT NULL,
    `model` VARCHAR(20) NOT NULL,
    `class` TINYINT UNSIGNED NULL DEFAULT NULL,
    `data` LONGTEXT NOT NULL,
    `trunk` LONGTEXT NULL DEFAULT NULL,
    `glovebox` LONGTEXT NULL DEFAULT NULL,
    `stored` VARCHAR(50) NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `plate` (`plate`) USING BTREE,
    UNIQUE INDEX `vin` (`vin`) USING BTREE,
    INDEX `FK_vehicles_characters` (`owner`) USING BTREE,
    CONSTRAINT `FK_vehicles_characters` FOREIGN KEY (`owner`) REFERENCES `characters` (`charId`) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `FK_vehicles_groups` FOREIGN KEY (`group`) REFERENCES `ox_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
  );
```
- To inssert new
```sql
ALTER TABLE `vehicles`
ADD COLUMN `mileage` int(11) DEFAULT 0,
ADD COLUMN `coords` longtext,
ADD COLUMN `lastparking` varchar(100),
ADD COLUMN `type` varchar(20) DEFAULT NULL,
ADD COLUMN `keys` longtext DEFAULT '[]',
ADD COLUMN `pound` VARCHAR(60) 
```
</details>

## How to use
- READING IS NOT LAVA


# Items 
<details>
<summary> Items </summary>


```lua
['carkey'] = {
	label = 'Carkey',
},

['lockpick'] = {
	label = 'Lockpick',
	weight = 160,
	decay = true,
	server = {
		export = 'mVehicle.lockpick'
	}
},

['hotwire'] = {
	label = 'Cutter',
	weight = 160,
	server = {
		export = 'mVehicle.hotwire'
	}
},

['fakeplate'] = {
	label = 'Fake Plate',
	consume = 0,
	server = {
		export = 'mVehicle.fakeplate'
	}
},
```
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
* plate  =  vehicle plate    | string *GetVehicleNumberPlateText()*
```lua
  Vehicles.ItemCarKeysClient(action, plate)
```

**Vehicles.ItemCarKeys() Server**
* source = player source    | number 
* action = 'remove' or 'add' | string
* plate  =  vehicle plate    | string 
```lua
  Vehicles.ItemCarKeys(source, action, plate)

  -- or ox_inventory export 
  -- add
  exports.ox_inventory:AddItem(source, 'carkey', 1, { plate = plate, description = plate })
  --remove 
  -- via ox_inventory export 
  exports.ox_inventory:RemoveItem(source, 'carkey', 1, { plate = plate, description = plate })
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

    -- Vehicle props
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
-- local metadata = Entity(entity).state.metadata
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

-- Delete vehicle | fromDatabase
Vehicle.DeleteVehicle(fromDatabase)
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
local AllVechiles = Vehicles.GetAllVehicles(source, VehicleTable, haveKeys) 

```

**Vehicles.GetAllVehicles()** *Server*
* soruce  = player source
* VehicleTable = boolean | true get vehicles from table Vehicles false get vehicles from DB
* haveKeys = boolean  | Have player keys ?

```lua 
local AllVechiles = Vehicles.GetAllVehicles(source, VehicleTable, haveKeys) 

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
