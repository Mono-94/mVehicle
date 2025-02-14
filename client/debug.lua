if not Config.Debug then return end


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
                if VehicleState.keys then
                    print(("Keys: %s"):format(json.encode(VehicleState.keys, { indent = true })))
                end
            end
        end
    },
})
