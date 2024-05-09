local data = {}
local playerPos
local seat = nil
local saveKHM = false
local ServerVehicles = {}
Vehicles = {}

RegisterNetEvent('mVehicle:ClientData', function(VehiclesData)
    ServerVehicles = VehiclesData
end)

local AtRound = function(valor, decimal)
    local start = 10 ^ (decimal or 0)
    return math.floor(valor * start + 0.5) / start
end

local VehicleState = function(action, data, delay)
    return lib.callback.await('mVehicle:VehicleState', delay or false, action, data)
end



lib.onCache('seat', function(value)
    local Player = cache.ped
    local vehicle = cache.vehicle
    local oldPos = nil
    seat = value
    if seat == -1 then
        saveKHM = true
        data.plate = GetVehicleNumberPlateText(vehicle)
        if ServerVehicles[data.plate] then
            data.updatekmh = ServerVehicles[data.plate].mileage / 100
            while true do
                if seat == -1 and saveKHM then
                    if IsVehicleOnAllWheels(vehicle) then
                        playerPos = GetEntityCoords(Player).xy
                        if oldPos then
                            local distance = #(oldPos - playerPos)
                            if distance >= 10 then
                                data.updatekmh = data.updatekmh + distance / 1000
                                data.updatekmh = AtRound(data.updatekmh, 2)
                                oldPos = playerPos
                            end
                        else
                            oldPos = playerPos
                        end
                    end
                    Citizen.Wait(100)
                else
                    data.coords = json.encode(GetVector4(vehicle))
                    data.props = lib.getVehicleProperties(vehicle)
                    saveKHM = false
                    seat = nil
                    VehicleState('update', data)
                    local IsTrailer, trailerEntity = GetVehicleTrailerVehicle(vehicle)
                    if IsTrailer and trailerEntity then
                        local State = Entity(trailerEntity).state
                        if State and State.Spawned then
                            local Trailer = {}
                            Trailer.plate = GetVehicleNumberPlateText(trailerEntity)
                            Trailer.coords = json.encode(GetVector4(trailerEntity))
                            Trailer.props = lib.getVehicleProperties(trailerEntity)
                            local saved = VehicleState('savetrailer', Trailer)
                            if saved then
                                lib.print.info(('[ TRAILER ] - Trailer save, Plate: %s, Owner ID : %s'):format(
                                Trailer.plate, State.Owner))
                            else
                                lib.print.error(('[ TRAILER ] - Error to save trailer Plate: %s, Owner ID : %s'):format(
                                Trailer.plate, State.Owner))
                            end
                        end
                    end
                    break
                end
            end
        end
    end
end)


AddStateBagChangeHandler('setVehicleProperties', nil, function(bagName, key, value)
    if not value or not GetEntityFromStateBagName(bagName) then return end

    local entity = GetEntityFromStateBagName(bagName)

    local networked = not bagName:find('localEntity')

    if networked and NetworkGetEntityOwner(entity) ~= PlayerId() then return end

    DeleteVehicleEntity({ action = 'spawn', entity = entity })

    if lib.setVehicleProperties(entity, value) then
        Entity(entity).state:set('setVehicleProperties', nil, true)
    end
end)

AddStateBagChangeHandler('FadeEntity', nil, function(bagName, key, value)
    if not value then return end
    local entity = GetEntityFromStateBagName(bagName)
    if NetworkGetEntityOwner(entity) ~= PlayerId() then return end
    value.entity = entity
    DeleteVehicleEntity(value)
    Entity(entity).state:set('FadeEntity', nil, true)
end)


function DeleteVehicleEntity(data)
    if data.action == 'spawn' then
        NetworkFadeInEntity(data.entity, true)
    elseif data.action == 'delete' then
        NetworkFadeOutEntity(data.entity, true, true)
        Citizen.Wait(1500)
        DeleteEntity(data.entity)
    end
end

local KeyDoors = function(entity)
    if not entity then
        entity = lib.getClosestVehicle(GetEntityCoords(cache.ped), Config.KeyDistance, true)
    end
    if not DoesEntityExist(entity) then return end
    local doorstatus = GetVehicleDoorLockStatus(entity)
    local vehtonet = VehToNet(entity)
    local plate = GetVehicleNumberPlateText(entity)
    local HaveKey = KeyItem(plate)
    local ped = cache.ped
    local inCar = IsPedInAnyVehicle(ped, false)

    if entity and HaveKey then
        lib.callback('mVehicle:VehicleControl', Config.KeyDelay, function(owner)
            if not owner then return end

            local pedbone = GetPedBoneIndex(ped, 57005)

            PlayVehicleDoorCloseSound(entity, 1)
            local soundEvent = doorstatus == 2 and "Remote_Control_Close" or "Remote_Control_Fob"

            PlaySoundFromEntity(-1, soundEvent, entity, "PI_Menu_Sounds", 1, 0)

            if not inCar then
                lib.requestModel("p_car_keys_01")
                while not HasModelLoaded("p_car_keys_01") do Wait(1) end

                local prop = CreateObject("p_car_keys_01", 1.0, 1.0, 1.0, true, true, 0)
                lib.requestAnimDict("anim@mp_player_intmenu@key_fob@")
                AttachEntityToEntity(prop, ped, pedbone, 0.08, 0.039, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1,
                    true)

                TaskPlayAnim(ped, "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false,
                    false)
                Citizen.Wait(1000)
                DeleteObject(prop)
            end
        end, 'doors', vehtonet, doorstatus)
    end
end

if Config.TargetOrKeyBind == 'target' then
    exports.ox_target:addGlobalVehicle({
        {
            distance = Config.KeyDistance,
            canInteract = function(entity, distance, coords, name, bone)
                if Config.ItemKeys then
                    return KeyItem(GetVehicleNumberPlateText(entity))
                else
                    return Entity(entity).state.Spawned
                end
            end,
            label = Config.Locales.key_targetdoors,
            icon = 'fa-solid fa-trailer',
            onSelect = function(veh)
                KeyDoors(veh.entity)
            end
        },
    })
else
    lib.addKeybind({
        name = 'Vehicle_doors_control',
        description = 'Carkeys',
        defaultKey = Config.DoorKeyBind,
        onPressed = function()
            KeyDoors(false)
        end,
    })
end


if Config.VehicleEngine.active then
    Citizen.CreateThread(function()
        local wait = 100
        while true do
            local vehicle = cache.vehicle
            if vehicle then
                local isEngineRunning = GetIsVehicleEngineRunning(vehicle)
                if isEngineRunning then
                    if IsControlPressed(0, 75) and isEngineRunning then
                        Citizen.Wait(300)
                        if IsControlPressed(0, 75) and isEngineRunning then
                            SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
                        else
                            SetVehicleEngineOn(vehicle, false, true, false)
                            SetVehicleKeepEngineOnWhenAbandoned(vehicle, false)
                        end
                    end
                    wait = 100
                else
                    wait = 10
                    SetVehicleEngineOn(vehicle, false, true, true)
                    DisableControlAction(0, 71, true)
                end
            else
                wait = 100
            end
            Citizen.Wait(wait)
        end
    end)

    lib.addKeybind({
        name = 'mVehice_toggle_engine',
        description = 'Keybin engine',
        defaultKey = Config.VehicleEngine.KeyBind,
        onPressed = function()
            local vehicle = cache.vehicle
            if vehicle then
                local isDriver = (GetPedInVehicleSeat(vehicle, -1) == cache.ped)
                if not isDriver then return end

                if not Config.ItemKeys then
                    local key = lib.callback.await('mVehicle:VehicleControl', 500, 'engine', VehToNet(vehicle))
                    if not key then return end
                else
                    local plate = GetVehicleNumberPlateText(vehicle)
                    local key = KeyItem(plate)
                    if not key then return end
                end

                local engineStatus = GetIsVehicleEngineRunning(vehicle)
                if engineStatus then
                    SetVehicleEngineOn(vehicle, false, true, true)
                else
                    SetVehicleEngineOn(vehicle, true, true, true)
                end
            end
        end

    })
end

lib.callback.register('mVehicle:GetVehicleProps', function(entity)
    if entity then
        if NetworkDoesNetworkIdExist(entity) then
            entity = NetToVeh(entity)
            local props = lib.getVehicleProperties(entity)
            return json.encode(props)
        else
            return false
        end
    else
        local props = lib.getVehicleProperties(cache.vehicle)
        return props
    end
end)

local StopBreakinCar = function(entity)
    if not entity then
        entity = GetVehiclePedIsTryingToEnter(cache.ped)
    end
    if DoesEntityExist(entity) then
        local lock = GetVehicleDoorLockStatus(entity)
        if lock == 2 then
            ClearPedTasks(cache.ped)
            return
        end
    end
end

if Config.FrameWork == 'esx' then
    AddEventHandler('esx:enteringVehicle', function(entity, plate, seat, netId)
        StopBreakinCar(entity)
    end)
else
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            StopBreakinCar()
        end
    end)
end

lib.callback.register('mVehicle:GivecarData', function()
    local options = {}
    for _, garage in ipairs(Config.GarageNames) do
        table.insert(options, { value = garage, label = garage })
    end

    local yesno = {
        { value = true,  label = Config.Locales.givecar_yes },
        { value = false, label = Config.Locales.givecar_no }
    }

    local input = lib.inputDialog('GiveCar', {
        { type = 'input',  label = Config.Locales.givecar_menu1, required = true },
        { type = 'select', label = Config.Locales.givecar_menu2, default = Config.GarageNames[1], icon = 'hashtag',           options = options },
        { type = 'select', label = Config.Locales.givecar_menu3, default = false,                 icon = 'hashtag',           options = yesno },
        { type = 'date',   label = Config.Locales.givecar_menu4, icon = { 'far', 'calendar' },    default = true,             format = "DD/MM/YYYY" },
        { type = 'number', label = Config.Locales.givecar_menu5, icon = 'clock',                  default = 0,                max = 23,             min = 0 },
        { type = 'number', label = Config.Locales.givecar_menu6, icon = 'clock',                  default = 0,                max = 59,             min = 0 },
        { type = 'color',  label = Config.Locales.givecar_menu7, format = 'rgb',                  default = 'rgb(77, 77, 77)' },
        { type = 'color',  label = Config.Locales.givecar_menu8, format = 'rgb',                  default = 'rgb(77, 77, 77)' },
    })

    if not input then return false end

    local color1 = lib.math.torgba(input[7])
    local color2 = lib.math.torgba(input[8])

    input[7] = { color1.r, color1.g, color1.b }
    input[8] = { color2.r, color2.g, color2.b }


    local vehiclehash = GetHashKey(input[1])
    local isModelValid = IsModelValid(vehiclehash)

    if not isModelValid then return false, lib.print.error('Vehicle model invalid') end

    input[9] = GetVehicleClassFromName(input[1])

    return input
end)



function Vehicles.ItemCarKeysClient(action, plate)
    lib.callback('mVehicle:GiveKey', false, nil, action, plate)
end

if Config.KeyMenu then
    lib.addRadialItem({
        {
            id = 'vehicle_keys',
            label = Config.Locales.carkey_menu1,
            icon = 'key',
            onSelect = function()
                Vehicles.VehickeKeysMenu()
            end
        }
    })
end

function Vehicles.VehickeKeysMenu(plate, cb)
    local VehicleList = {}
    local VehicleSelected = {}
    local data = VehicleState('getkeys')
    if #data == 0 then
        return Notification({
            title = Config.Locales.carkey_menu1,
            description = Config.Locales.carkey_menu2,

        })
    end
    for i = 1, #data do
        local row = data[i]
        local props = json.decode(row.vehicle)
        row.vehlabel = VehicleLabel(props.model)
        if plate and row.plate == plate then
            table.insert(VehicleSelected, {
                title = Config.Locales.carkey_menu3,
                description = Config.Locales.carkey_menu4,
                iconColor = '#86d975',
                icon = 'plus',
                onSelect = function()
                    local input = lib.inputDialog(Config.Locales.carkey_menu3, {
                        { type = 'number', label = 'ID', icon = 'user' },

                    })
                    if input then
                        VehicleState('addkey', { serverid = input[1], keys = row.keys, plate = row.plate })
                        if cb then cb() end
                    else
                        lib.print.error('Cancel givekey to player')
                        if cb then cb() end
                    end
                end
            })
            if type(row.keys) == 'string' then
                row.keys = json.decode(row.keys)
            end
            local notplayers = true

            if row.keys and next(row.keys) ~= nil then
                local keys = {}
                for k, v in pairs(row.keys) do
                    table.insert(VehicleSelected, {
                        title = v,
                        arrow = true,
                        icon = 'user',
                        description = Config.Locales.carkey_menu6,
                        iconColor = '#d97575',
                        onSelect = function()
                            keys[k] = nil
                            VehicleState('deletekey', { keys = keys, plate = row.plate })
                            if cb then cb() end
                        end
                    })
                end
            else
                notplayers = false
            end

            if not notplayers then
                table.insert(VehicleSelected, {
                    title = Config.Locales.carkey_menu5,
                    icon = 'ban',
                    iconColor = '#d97575',
                    disabled = true,
                })
            end
            VehhicleSelected(VehicleSelected, ('%s | %s'):format(row.plate, row.vehlabel), cb)
        else
            table.insert(VehicleList, {
                title = ('%s | %s'):format(row.plate, row.vehlabel),
                description = ('%s | %s \n Parking: %s'):format(row.plate, row.vehlabel, row.parking),
                icon = 'car',
                iconColor = row.stored == 1 and '#5bb060' or '#b0645b',
                arrow = true,
                onSelect = function()
                    VehicleSelected = {}
                    table.insert(VehicleSelected, {
                        title = Config.Locales.carkey_menu3,
                        description = Config.Locales.carkey_menu4,
                        iconColor = '#86d975',
                        icon = 'plus',
                        onSelect = function()
                            local input = lib.inputDialog(Config.Locales.carkey_menu3, {
                                { type = 'number', label = 'ID', icon = 'user' },

                            })
                            if input then
                                VehicleState('addkey', { serverid = input[1], keys = row.keys, plate = row.plate })
                                Vehicles.VehickeKeysMenu()
                            end
                        end
                    })

                    if type(row.keys) == 'string' then
                        row.keys = json.decode(row.keys)
                    end
                    local notplayers = true
                    if row.keys and next(row.keys) ~= nil then
                        local keys = {}
                        for k, v in pairs(row.keys) do
                            table.insert(VehicleSelected, {
                                title = v,
                                arrow = true,
                                description = Config.Locales.carkey_menu6,
                                icon = 'user',
                                iconColor = '#d97575',
                                onSelect = function()
                                    keys[k] = nil
                                    VehicleState('deletekey', { keys = keys, plate = row.plate })
                                    Vehicles.VehickeKeysMenu()
                                end
                            })
                        end
                    else
                        notplayers = false
                    end
                    if not notplayers then
                        table.insert(VehicleSelected, {
                            title = Config.Locales.carkey_menu5,
                            icon = 'ban',
                            iconColor = '#d97575',
                            disabled = true,
                        })
                    end
                    VehhicleSelected(VehicleSelected, ('%s | %s'):format(row.plate, row.vehlabel))
                end
            })
        end
    end

    if plate then return end

    lib.registerContext({
        id = 'mVehicle:menuKeys',
        title = Config.Locales.carkey_menu1,
        options = VehicleList
    })

    lib.showContext('mVehicle:menuKeys')
end

function VehhicleSelected(vehicle, vehlabel, cb)
    local menu = {
        id = 'mVehicle:selectedVeh',
        title = vehlabel,
        options = vehicle
    }
    if not cb then
        menu.menu = 'mVehicle:menuKeys'
    else
        menu.onExit = cb
    end

    lib.registerContext(menu)
    lib.showContext('mVehicle:selectedVeh')
end

exports('vehicle', function()
    return Vehicles
end)
