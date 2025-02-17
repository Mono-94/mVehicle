local vehicle = nil
local engineStatus = false

lib.onCache('vehicle', function(value)
    vehicle = value

    if vehicle then
        SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
    end

    while true do
        if not vehicle then break end

        engineStatus = GetIsVehicleEngineRunning(vehicle)

        if not engineStatus then
            --    if IsControlPressed(0, 75) then
            --        Citizen.Wait(200)
            --        if IsControlPressed(0, 75) then
            --            SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
            --        else
            --            SetVehicleEngineOn(vehicle, false, true, false)
            --            SetVehicleKeepEngineOnWhenAbandoned(vehicle, false)
            --        end
            --    end
            --else
            SetVehicleEngineOn(vehicle, false, true, true)
            DisableControlAction(0, 71, true)
        end

        Citizen.Wait(10)
    end
end)

if not Config.VehicleEngine.ToggleEngine then return end


lib.addKeybind({
    name = 'mVehice_toggle_engine',
    description = 'Keybin engine',
    defaultKey = Config.VehicleEngine.KeyBind,
    onPressed = function()
        if not vehicle then return end
        local isDriver = (GetPedInVehicleSeat(vehicle, -1) == cache.ped)

        if not isDriver then return end

        if not Config.ItemKeys then
            local key = lib.callback.await('mVehicle:VehicleEngine', nil,
                { NetId = VehToNet(vehicle), plate = GetVehicleNumberPlateText(vehicle) })
            if not key then return end
        else
            local plate = GetVehicleNumberPlateText(vehicle)
            local key = Utils.KeyItem(plate)
            if not key then return end
        end

        local vehicleClass = GetVehicleClass(vehicle)

        if vehicleClass ~= 8 then
            TaskPlayAnim(cache.ped, 'veh@std@ds@fpsbase', 'start_engine', 8.0, 1.0, -1, 0, 0, 0, 0, 0)
        end

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
