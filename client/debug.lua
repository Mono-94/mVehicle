if not Config.Debug then return end

local RadiusVehicleCoordsAwaitingClient = {}

RegisterNetEvent('mvehicle:persistent:area:debug', function(id, coords, dist, action, bucket)
    if action == 'add' then
        if RadiusVehicleCoordsAwaitingClient[id] then return end
        RadiusVehicleCoordsAwaitingClient[id] = {}
        RadiusVehicleCoordsAwaitingClient[id].radius = AddBlipForRadius(coords.x, coords.y, coords.z, dist)
        SetBlipAlpha(RadiusVehicleCoordsAwaitingClient[id].radius, 50)
        SetBlipColour(RadiusVehicleCoordsAwaitingClient[id].radius, bucket == 0 and 11 or 14)
        RadiusVehicleCoordsAwaitingClient[id].blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(RadiusVehicleCoordsAwaitingClient[id].blip, 11)
        SetBlipDisplay(RadiusVehicleCoordsAwaitingClient[id].blip, 4)
        SetBlipScale(RadiusVehicleCoordsAwaitingClient[id].blip, 1.0)
        SetBlipColour(RadiusVehicleCoordsAwaitingClient[id].blip, bucket == 0 and 11 or 14)
        SetBlipAsShortRange(RadiusVehicleCoordsAwaitingClient[id].blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(('Vehicle ID [ %s ] | Bucket [ %s ] - Awaiting client in Scope'):format(id, bucket))
        EndTextCommandSetBlipName(RadiusVehicleCoordsAwaitingClient[id].blip)
    else
        if RadiusVehicleCoordsAwaitingClient[id] then
            RemoveBlip(RadiusVehicleCoordsAwaitingClient[id].blip)
            RemoveBlip(RadiusVehicleCoordsAwaitingClient[id].radius)
            RadiusVehicleCoordsAwaitingClient[id] = nil
        end
    end
end)



exports.ox_target:addGlobalVehicle({
    {
        distance = 10.0,
        label = 'Change Sound',
        onSelect = function(data)
            local input = lib.inputDialog('Vehicle Sound', {
                { type = 'select', label = 'Select sound', options = EngineSound.Engines }
            })

            if not input then return end

            Vehicles.SetEnGineSound(data.entity, input[1])
        end
    },
    {
        distance = 10.0,
        label = 'type',
        onSelect = function(data)
           print(GetVehicleType(data.entity))
        end
    },
    {
        distance = 10.0,
        label = 'Vehicle data',
        onSelect = function(data)
            local VehicleState = Entity(data.entity).state
            if VehicleState then
                if VehicleState.id then
                    print(("ID: %s"):format(VehicleState.id))
                end

                print(("Plate: %s"):format(VehicleState.plate))

                if VehicleState.owner then
                    print(("Owner: %s"):format(VehicleState.owner))
                end

                print(("Type: %s"):format(VehicleState.type))

                if VehicleState.job then
                    print(("Job: %s"):format(VehicleState.job))
                end

                print(("Fuel Level: %s"):format(VehicleState.fuel))

                if VehicleState.mileage then
                    print(("Mileage: %s"):format(VehicleState.mileage))
                end

                if VehicleState.engineSound then
                    print(("Engine Sound: %s"):format(VehicleState.engineSound))
                end
                if VehicleState.metadata then
                    print(("Metadata: %s"):format(json.encode(VehicleState.metadata, { indent = true })))
                end
                print(VehicleState.metadata.properties)
                print(VehicleState.metadata.parking)
                print(VehicleState.metadata.keys)

                --if VehicleState.keys then
                --    print(("Keys: %s"):format(json.encode(VehicleState.keys, { indent = true })))
                --end
            end
        end
    },
})
