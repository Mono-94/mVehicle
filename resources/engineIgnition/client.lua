

if not Config.VehicleEngine.ToggleEngine then return end


lib.addKeybind({
    name = 'mVehice_toggle_engine',
    description = 'Keybin engine',
    defaultKey = Config.VehicleEngine.KeyBind,
    onPressed = function()
        local vehicle = cache.vehicle

        if not vehicle then return end

        local isDriver = GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped

        if not isDriver then return end

        local key = Vehicles.HasKeyClient(vehicle)

        if not key then return end

        local vehicleClass = GetVehicleClass(vehicle)

        if vehicleClass ~= 8 then
            TaskPlayAnim(cache.ped, 'veh@std@ds@fpsbase', 'start_engine', 8.0, 1.0, not engineStatus and 1500 or 1000, 49,
                0, 0, 0, 0)
        end
        local engineStatus = GetIsVehicleEngineRunning(vehicle)

        Citizen.Wait(not engineStatus and 1500 or 1000)

        SetVehicleEngineOn(vehicle, not engineStatus, true, true)

        if not engineStatus then
            local totalDuration = 500
            local waitTime = 10
            local iterations = totalDuration / waitTime

            for i = 1, iterations do
                SetVehicleCurrentRpm(vehicle, 1.0)
                Citizen.Wait(waitTime)
            end
        end
    end
})


lib.requestAnimDict('veh@std@ds@fpsbase')
