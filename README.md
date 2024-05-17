 [![discord](https://img.shields.io/badge/Join-Discord-blue?logo=discord&logoColor=white)](https://discord.gg/Vk7eY8xYV2)
 ![Discord](https://img.shields.io/discord/1048630711881568267?style=flat&label=Online%20Users)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FMono-94%2FmVehicle&count_bg=%23E9A711&title_bg=%23232323&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

# mVehicles 
*This  is not a garage system, it is only to manage vehicles, you can use this code simply for the key system.*

## Features
- Fully compatible with ESX , standalone (requires database), OX Everything works, but the vehicles do not spawn when the server loads, pending.
- Vehicle are persistent.
- Ability to add metadata to vehicles.
- Records total kilometers driven by vehicles.
- Key system via item or database.
- Engine ignition by Key item/db
- Menu for sharing keys.
- FakePlate *only works with vehicles spawned by the Vehicles.CreateVehicle() and ox_inventory item*
- LockPick, Hotwire + Adapt your skillscheck and dispatch via Config.LockPickItem and  Config.HotWireItem
 

- ## **Commands**
 - `/givecar [source]`
 - - Set a player [source] a vehicle temporarily/indefinitely
 - `/setcarowner [source]`
  - - Establish ownership of the vehicle in which the player is located. [source]
 - `/saveAllcars true/false` 
 - - If true, deletes all vehicles; if false, only save vehicles.
 - `/spawnAllcars` 
 -  Forces spawning vehicles outside garages.
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
* [ox_fuel] (https://github.com/overextended/ox_fuel)

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
* action = 'delete' or 'add' | string
* plate  =  vehicle plate    | string *GetVehicleNumberPlateText()*
```lua
  -- with shared import
  Vehicles.ItemCarKeysClient(action, plate)

    -- or 
  exports.mVehicle:ItemCarKeysClient(action, plate)
```

**Vehicles.ItemCarKeys() Server**
* source = player source    | number 
* action = 'delete' or 'add' | string
* plate  =  vehicle plate    | string 
```lua
  -- with shared import
  Vehicles.ItemCarKeys(source, action, plate)

  -- or ox_inventory export 
  -- add
  exports.ox_inventory:AddItem(source, 'carkey', 1, { plate = plate, description = plate })
  -- delete
  exports.ox_inventory:RemoveItem(source, 'carkey', 1, { plate = plate, description = plate })
 
 -- or 
  exports.mVehicle:ItemCarKeys(source, action, plate)
```

**Vehicles.CreateVehicle() Server**
```lua
local CreateVehicleData = {
    temporary = false, -- if vehicle temporary | date format 'YYYYMMDD HH:MM'     example '20240422 03:00' or false
    job = nil,  -- string or false, nil ...
    setOwner = true,    -- Set vehicle Owner? if Temporary date set true
    owner = 'char:12asd76asd5asdas',    -- player identifier
    coords = vector4(1.0, 1.0, 1.0, 1.0), --vector4 or table with xyzw
    -- Vehicle, you can set as many properties as you want
    vehicle = {                             
        model = 'sulta',                   -- required
        plate = Vehicles.GeneratePlate(),  -- required
        fuelLevel = 100,                   -- required
        color1 = [0,0,0],
        color2 = [0,0,0],                 
    },
}

Vehicles.CreateVehicle(CreateVehicleData, function(data, Vehicle)
   print(json.encode(data, { indent = true} ))

 -- Set Metadata
  Vehicle.SetMetadata('mono', { 
    smoke = 'seems to be very smoked', 
    hungry = 'the subject is very hungry'
  }) 
  Wait(1000)
  -- Get Metadata
  local metadata = Vehicle.GetMetadata('mono',)
  print(('%s, %s'):format(metadata.smoke, metadata.hungry))
  Wait(1000)
  -- delete espeific Metadata
  Vehicle.DeleteMetadata('mono', 'smoke')
  Wait(1000)
  -- Get new metadata
  local metadataNew = Vehicle.GetMetadata('mono')
  print(('%s'):format(metadataNew.hungry))
  Wait(1000)
  -- delete all metadata from 'mono' return nil 
  Vehicle.DeleteMetadata('mono')
  

  --GarageActions
  -- Store/Retry
  Vehicle.StoreVehicle('Pillbox Hill')

  Vehicle.RetryVehicle(CreateVehicleData.coords)

  -- impound
  Vehicle.ImpoundVehicle('Impound Car', 100, 'Vehicle impond', '2024/05/2 15:43')

  Vehicle.RetryImpound('Pillbox Hill', CreateVehicleData.coords)
end)

```
**Vehicles.GetVehicle()** *Server*

```lua
local Vehicle = Vehicles.GetVehicle(entity) 

Vehicle.SetMetadata(key, data)
Vehicle.DeleteMetadata(key, value) 
Vehicle.GetMetadata(key)     
Vehicle.AddKey(source) 
Vehicle.RemoveKey(source)
Vehicle.SaveProps(props)
Vehicle.StoreVehicle(parking)
Vehicle.RetryVehicle(coords)
Vehicle.ImpoundVehicle(parking, price, note, date, endPound)
Vehicle.RetryImpound(ToGarage, coords)
Vehicle.SetFakePlate(plate)
Vehicle.SetFakePlate(boolean)
Vehicle.DeleteVehicle(fromDatabaseBoolean)
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
* VehicleTable = boolean | true get vehicles from table mVehicles false get vehicles from DB
* haveKeys = boolean  | Have player keys ?
* return all vehicles from source

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



![image](https://cdn.discordapp.com/attachments/1234840062181769378/1238255435358666884/307592b7-b7d1-40b4-b615-a1ac0d26c385.jpg?ex=663e9ebd&is=663d4d3d&hm=133b443e1a18490a0ef8669650068d0c546149d9bda930140539665202112e27&)