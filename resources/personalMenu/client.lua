if not Config.PersonalVehicleMenu then return end

local getVehicles = function()
    local cars = {}

    local data = lib.callback.await('mVehicle:VehicleState', false, 'getkeys')

    if #data == 0 then
        return Utils.Notification({
            title = locale('carkey_menu1'),
            description = locale('carkey_menu2'),

        })
    end

    for i = 1, #data do
        local row = data[i]
        local props = json.decode(row.vehicle)

        row.metadata = json.decode(row.metadata)
        row.vehlabel = Vehicles.GetVehicleLabel(props.model)
        row.model = GetDisplayNameFromVehicleModel(props.model)

        row.mileage = row.mileage / 100

        if props.bodyHealth and props.engineHealth then
            row.engineHealth = props.bodyHealth / 10
            row.bodyHealth = props.engineHealth / 10
        else
            row.engineHealth = 100
            row.bodyHealth = 100
        end

        cars[row.plate] = row
    end

    return cars
end


--- Personal vehicles menu
local menuPromise = nil
local keysmenu = false
---@param plate? string
---@param cb? function
function Vehicles.VehicleKeysMenu(plate, cb)
    keysmenu = false

    local cars = getVehicles()

    if not cars then return false end


    if plate then
        OpenKeyModal(cars[plate])


        if cb then
            menuPromise = promise:new()
            Citizen.Await(menuPromise)
            cb()
        end
    else
        keysmenu = true
        SendNUI('vehicleKeys', cars)
        ShowNui('setVisibleMenu', true)
    end
end

RegisterNuiCallback('ui:Close', function(data, cb)
    ShowNui(data.name, false)
    if data.name == 'setVisibleMenu' then
        keysmenu = false
    elseif data.name == 'setVisibleModal' then
        if keysmenu then Vehicles.VehicleKeysMenu() end
        if menuPromise then
            menuPromise:resolve()
        end
    end
    cb(true)
end)

function OpenKeyModal(vehicle)
    SendNUI('manageKey', vehicle)
    ShowNui('setVisibleModal', true)
end

RegisterNuiCallback('show:VehicleKeys', function(data, cb)
    OpenKeyModal(data)
    cb(true)
end)

RegisterNuiCallback('mVehicle:VehicleMenu_ui', function(data, cb)
    local ret = lib.callback.await('mVehicle:VehicleMenu', false, data.action, data.data, data.key)
    cb(ret)
end)

RegisterNuiCallback('mVehicle:VehicleMenu_ui:setGPS', function(plate, cb)
    local ret = Vehicles.BlipOwnerCar(plate)
    cb(ret)
end)


exports('VehicleKeysMenu', Vehicles.VehicleKeysMenu)

if Config.PersonalVehicleMenu then
    lib.addRadialItem({
        {
            id = 'vehicle_keys_menu',
            label = 'Your Vehicles',
            icon = 'car',
            onSelect = Vehicles.VehicleKeysMenu
        }
    })
end

local blip = nil
local timer

function Vehicles.BlipOwnerCar(plate)
    local vehicle = lib.callback.await('mVehicle:VehicleMenu', false, 'setBlip', { plate = plate })

    if not vehicle then return false end

    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
        SetBlipRoute(blip, false)
        timer:forceEnd(false)
    end

    local vehLabel = Vehicles.GetVehicleLabel(vehicle.model)

    blip = AddBlipForCoord(vehicle.coords.x, vehicle.coords.y, vehicle.coords.z)

    SetBlipSprite(blip, 523)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 49)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(('%s - %s'):format(vehLabel, plate))
    EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, true)

    timer = lib.timer(60000 * 2, function()
        SetBlipRoute(blip, false)
        RemoveBlip(blip)
    end, true)

    if blip then
        Utils.Notification({
            title = 'Vehicles',
            description = locale('setBlip'),
            type = 'success'
        })
        return true
    end
end
