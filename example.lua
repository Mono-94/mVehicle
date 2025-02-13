
local vehicle = {
    -- Vehicle Plate ❗ * REQUIRED *
    plate = 'MONO 420',
    -- Vehicle Option, you can use all the properties. ❗ * REQUIRED *
    vehicle = {
        model = 'sultan',
        fuelLevel = 100,
        -- .. Some other props
    },
    -- Cords to spawn ❗ * REQUIRED *
    coords = vec4(420.0, 420.0, 420.0, 420.0),
    -- Vehicle Type ?
    type = 'automobile',
    -- Vehicle Metadata ?
    metadata = {
        -- Use this parameter to set the vehicle to a different dimension when spawning.
        RoutingBucket = 1,
        -- Set Fake Plate
        fakeplate = 'FAKE 240',
        -- Engine Sound 
        engineSound = '',
        -- Door Status 
        DoorStatus = 0,
        
    },

    -- Required intocar/setOwner ?
    source = source,
    -- In to car ?
    intocar = true,
    -- Set current Vehicle owner ?
    setOwner = true,
    -- Does the vehicle have an owner?  owner or nil/false
    owner = 'charid/identifier/license',
    -- Temporary ? date format 'YYYYMMDD HH:MM' example '20240422 03:00' or false
    temporary = false,
    -- Vehicle JOB ?
    job = 'police',
}

local data, GetVehicle = Vehicles.CreateVehicle(vehicle)




---------------------------------------
---
