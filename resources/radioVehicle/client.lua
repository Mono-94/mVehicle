if GetResourceState('xsound') ~= 'started' then return end

local xSound = exports.xsound
local radioOpen = false
local Radio = {}
local radios = {}


function Radio:PlayList(playlist)
    SendNUIMessage({ action = 'playList', data = playlist })
end

function Radio:Data(data)
    SendNUIMessage({ action = 'radioData', data = data })
end

function Radio:Visible(visible)
    SetNuiFocus(visible, visible)
    radioOpen = visible
    SendNUIMessage({ action = 'radio', data = visible })
end

function Radio:Vehicle(vehicle)
    SendNUIMessage({ action = 'radioVehicle', data = vehicle })
end

RegisterNetEvent("mVehicle:VehicleRadio", function(action, data)
    local exist = xSound:soundExists(data.plate)
    table.insert(radios, data.plate)
    if action == "play" then
        local Vehicle = NetToVeh(data.networkId)
        local coords = GetEntityCoords(Vehicle)
        xSound:PlayUrlPos(data.plate, data.link, data.volume, coords)
        xSound:Distance(data.plate, data.distance)
        xSound:destroyOnFinish(data.plate, true)
        xSound:onPlayStart(data.plate, function()
            Citizen.CreateThread(function()
                while true do
                    Citizen.Wait(0)
                    if xSound:soundExists(data.plate) then
                        coords = GetEntityCoords(Vehicle)
                        xSound:Position(data.plate, vec3(coords.xyz))
                    end
                    if not DoesEntityExist(Vehicle) then
                        xSound:Destroy(data.plate)
                        break
                    end
                end
            end)
        end)
    elseif action == "vol" and exist then
        xSound:setVolume(data.plate, data.volume)
    elseif action == "time" and exist then
        xSound:setTimeStamp(data.plate, data.timeStamp)
    elseif action == "pause" and exist then
        xSound:Pause(data.plate)
    elseif action == "resume" and exist then
        xSound:Resume(data.plate)
    elseif action == "destroy" and exist then
        xSound:Destroy(data.plate)
    end
end)


function OpenRadio()
    local data = {}

    data.entity = GetVehiclePedIsIn(cache.ped, false)

    if not DoesEntityExist(data.entity) then
        return Utils.Debug('info', 'no Vehicle Entity to play Sound')
    end

    data.networkId = VehToNet(data.entity)

    data.plate = GetVehicleNumberPlateText(data.entity)

    local metadata = Entity(data.entity).state.metadata

    local haveRadio = metadata.radio
    data.id = data.plate

    if haveRadio and haveRadio.install then
        Radio:Vehicle({ entity = data.entity, networkId = data.networkId, plate = data.plate })

        local current = xSound:getInfo(data.plate)

        if current then
            data.url = current.url
            data.timeStamp = current.timeStamp
            data.id = current.id
            data.soundExists = current.soundExists
            data.playing = current.playlist
            data.paused = current.paused
            data.maxDuration = current.maxDuration
            data.volume = current.volume
        end



        Radio:Data(data)
        Wait(200)
        Radio:PlayList(haveRadio.playlist)
        Radio:Visible(true)

        if current then
            RadioOpen(data.plate)
        end
    end
end

function RadioOpen(plate)
    local current = xSound:getInfo(plate)

    while current do
        current = xSound:getInfo(plate)
        Radio:Data(current)
        Citizen.Wait(999)
        if not radioOpen then
            Radio:Data(false)
            break
        end
    end
end

RegisterNuiCallback('radioNui', function(data, cb)
    if data.action == 'saveSong' or data.action == 'deleteSong' or data.action == 'favSong' then
        if data.entity then
            print(json.encode(data, { indent = true }))
        end
        local song = lib.callback.await('mVehicle:radio:PlayList', 500, data.action, data)
        if song then
            local metadata = Entity(data.entity).state.metadata
            Radio:PlayList(metadata.radio.playlist)
        end
        cb(song)
        return
    end

    if data.action == 'play' then
        data.volume = data.volume / 100.0

        data.distance = Config.Radio.distance

        data.entity = GetVehiclePedIsIn(cache.ped, false)

        if not DoesEntityExist(data.entity) then
            print("No entity to play sound.")
            return
        end

        local plate = GetVehicleNumberPlateText(data.entity)

        if plate == data.plate then
            data.networkId = VehToNet(data.entity)
            TriggerServerEvent("mVehicle:SoundStatus", data.action, data)
            Citizen.Wait(100)
            RadioOpen(plate)
        end
    elseif data.action == 'close' then
        Radio:Visible(false)
    else
        if xSound:soundExists(data.plate) then
            if data.volume then
                data.volume = data.volume / 100.0
            end
        end

        TriggerServerEvent("mVehicle:SoundStatus", data.action, data)
    end

    cb(':)')
end)


if Config.Debug then
    RegisterCommand('radio', function(source, args, raw)
        OpenRadio()
    end)

    lib.onCache('seat', function(value)
        if value == -1 then
            local metadata = Entity(cache.vehicle).state.metadata
            if not metadata then return end
            local haveRadio = metadata.radio

            if haveRadio and haveRadio.install then
                lib.addRadialItem({
                    {
                        id = 'vehicle_radio',
                        label = 'Radio',
                        icon = 'radio',
                        onSelect = OpenRadio
                    },

                })
            end
        else
            lib.removeRadialItem('vehicle_radio')
        end
    end)

    lib.addKeybind({
        name = 'mRadio',
        description = 'press X to open radio',
        defaultKey = 'X',
        onPressed = function(self)
            OpenRadio()
        end
    })
end
