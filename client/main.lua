local is_ox_fuel = GetResourceState('ox_fuel') == 'started'

--- Set some flags on PlayerPedId Change
lib.onCache('ped', function (ped)
    SetPedConfigFlag(ped, 380, Config.EnableBikeHelmet)

    -- CPED_CONFIG_FLAG_DisableStartEngine | 429
    SetPedConfigFlag(ped, 429, Config.VehicleEngine.ToggleEngine)

    -- CPED_CONFIG_FLAG_LeaveEngineOnWhenExitingVehicles | 241
    SetPedConfigFlag(ped, 241, Config.VehicleEngine.keepEngineOnWhenLeave)
end)


Citizen.CreateThread(function()
    local lastVehicle = nil

    while true do
        local vehicleEntity = GetVehiclePedIsTryingToEnter(cache.ped)

        if vehicleEntity ~= lastVehicle then
            lastVehicle = vehicleEntity
            cache:set('TryEnterVehicle', vehicleEntity ~= 0 and vehicleEntity or false)
        end

        Citizen.Wait(200)
    end
end)


--- Vehicle density loop
Citizen.CreateThread(function()
    while Config.VehicleDensity.density do
        SetVehicleDensityMultiplierThisFrame(Config.VehicleDensity.VehicleDensity)
        SetRandomVehicleDensityMultiplierThisFrame(Config.VehicleDensity.RandomVehicleDensity)
        SetParkedVehicleDensityMultiplierThisFrame(Config.VehicleDensity.ParkedVehicleDensity)
        Citizen.Wait(0)
    end
end)


--- Request Props client to server
RegisterNetEvent('mVehicles:RequestProps', function(id, entity)
    local props
    if entity then
        if NetworkDoesNetworkIdExist(entity) then
            entity = NetToVeh(entity)
            props = lib.getVehicleProperties(entity)
        else
            props = false
        end
    else
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if DoesEntityExist(vehicle) then
            props = lib.getVehicleProperties(vehicle)
        else
            props = false
        end
    end

    TriggerServerEvent('mVehicle:ReceiveProps', id, json.encode(props))
end)



--- Give Car CallBack
lib.callback.register('mVehicle:GivecarData', function()
    local options = {}
    local disable = true

    local status, GarageZones = pcall(function()
        return exports.mGarage:GetGaragesData()
    end)

    if status then
        disable = false
        for _, garage in ipairs(GarageZones.garage) do
            local label = garage.jobname or garage.name
            table.insert(options, { value = garage.name, label = label })
        end
    end

    local input = lib.inputDialog('GiveCar', {
        { type = 'input',    label = locale('givecar_menu1'), required = true },
        { type = 'input',    label = locale('givecar_menu9'), description = locale('givecar_menu10'), required = false },
        { type = 'select',   label = locale('givecar_menu2'), icon = 'hashtag',                       options = options, disabled = disable },
        { type = 'checkbox', label = locale('givecar_menu3') },
    })


    if not input then return false end

    local vehiclehash = joaat(input[1])

    local isModelValid = IsModelValid(vehiclehash)

    if not isModelValid then return false, print('Vehicle model invalid') end

    input[9] = GetVehicleClassFromName(input[1])

    local GiveCar = {
        model = input[1],
        job = input[2],
        parking = input[3],
        isTemporary = input[4],
        vehicleClass = input[9]
    }

    if input[4] then
        local date = lib.inputDialog(locale('givecar_menu11'), {
            { type = 'date', label = locale('givecar_menu4'), icon = { 'far', 'calendar' }, format = "DD/MM/YYYY", required = true },
            { type = 'time', label = locale('givecar_menu5'), icon = { 'far', 'calendar' }, format = "24",         required = true },
        })
        if not date then return false, print('Invalid') end

        GiveCar.date = date[1]
        GiveCar.hour = date[2]
    end



    return GiveCar
end)


if not is_ox_fuel then
    AddStateBagChangeHandler('fuel', nil, function(bagName, key, value)
        if not value then return end
        local entity = GetEntityFromStateBagName(bagName)
        if NetworkGetEntityOwner(entity) ~= PlayerId() then return end
        Config.SetFuel(entity, value)
    end)
end



RegisterSafeEvent('mVehicle:FadeEntity', function(netId, action)
    if NetworkDoesEntityExistWithNetworkId(netId) then
        local entity = NetToVeh(netId)
        if action == 'spawn' then
            NetworkFadeInEntity(entity, true)
        elseif action == 'delete' then
            NetworkFadeOutEntity(entity, true, true)
            Citizen.Wait(1500)
            DeleteEntity(entity)
        end
    end
end)

--- Save Vehicle Coords And Props
local playerPos
local seat = nil
local saveKHM = false
lib.onCache('seat', function(value)
    local Player = cache.ped
    local vehicle = cache.vehicle
    local oldPos = nil
    seat = value

    if seat == -1 and DoesEntityExist(vehicle) then
        local data = {}

        -- local State = Entity(vehicle).state

        saveKHM = true

        data.plate = GetVehicleNumberPlateText(vehicle)

        local vehicleDb = lib.callback.await('mVehicle:VehicleState', false, 'getVeh', data)

        if vehicleDb and vehicleDb.vehicle then
            data.mileage = vehicleDb.mileage / 100
            while true do
                if seat == -1 and saveKHM then
                    if IsVehicleOnAllWheels(vehicle) then
                        playerPos = GetEntityCoords(Player).xy
                        if oldPos then
                            local distance = #(oldPos - playerPos)
                            if distance >= 10 then
                                data.mileage = data.mileage + distance / 1000
                                data.mileage = Utils.Round(data.mileage)
                                oldPos = playerPos
                            end
                        else
                            oldPos = playerPos
                        end
                    end
                    Citizen.Wait(100)
                else
                    data.coords = Utils.GetVector4(vehicle, false)
                    data.props = lib.getVehicleProperties(vehicle)

                    saveKHM = false
                    seat = nil
                    if type(data.props) == 'table' then
                        lib.callback.await('mVehicle:VehicleState', false, 'update', data)
                    end
                    local IsTrailer, trailerEntity = GetVehicleTrailerVehicle(vehicle)
                    if IsTrailer and trailerEntity then
                        local State = Entity(trailerEntity).state
                        if State and State.Spawned then
                            local Trailer = {}
                            Trailer.plate = GetVehicleNumberPlateText(trailerEntity)
                            Trailer.coords = Utils.GetVector4(trailerEntity, true)
                            Trailer.props = lib.getVehicleProperties(trailerEntity)
                            if type(Trailer.props) == 'table' then
                                local saved = lib.callback.await('mVehicle:VehicleState', false, 'savetrailer', Trailer)
                            end
                        end
                    end
                    break
                end
            end
        end
    end
end)



function ShowNui(action, shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendNUIMessage({ action = action, data = shouldShow })
end

function SendNUI(action, data)
    SendNUIMessage({ action = action, data = data })
end

AddEventHandler('ox_lib:setLocale', function(locale)
    SendNUIMessage({ action = 'ui:Lang', data = lib.getLocales() })
end)

RegisterNuiCallback('ui:Lang', function(data, cb)
    cb(lib.getLocales())
end)
