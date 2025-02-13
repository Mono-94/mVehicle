if GetResourceState('xsound') ~= 'started' then return end

local xSound = exports.xsound
local radioOpen = false

local test = {
    [1] = {
        name = 'FOYONE - EL DUEÑO DEL ATICO',
        link = 'https://youtu.be/Qn0HrsH7D7I',
    },
    [2] = {
        name = 'FOYONE - PSICOTICO',
        link = 'https://youtu.be/18fbPU_4rbQ',
    },
    [3] = {
        name = 'SFDK - PHANTOM',
        link = 'https://youtu.be/NFFYQTjjaD4',
    },

}


RegisterNetEvent("mVehicle:VehicleRadio", function(action, data)
    local exist = xSound:soundExists(data.plate)

    if action == "play" then
        local Vehicle = NetToVeh(data.networkId)
        local coords = GetEntityCoords(Vehicle)
        xSound:PlayUrlPos(data.plate, data.link, data.volume, coords)
        xSound:Distance(data.plate, data.distance)
        xSound:destroyOnFinish(data.plate, true)
        xSound:onPlayStart(data.plate, function()
            Citizen.CreateThread(function()
                while true do
                    if xSound:soundExists(data.plate) then
                        coords = GetEntityCoords(Vehicle)
                        xSound:Position(data.plate, vec3(coords.xyz))
                    end
                    if not DoesEntityExist(Vehicle) then
                        xSound:Destroy(data.plate)
                        break
                    end
                    Citizen.Wait(0)
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

    if haveRadio and haveRadio.install then
        Utils.Debug('info', json.encode(metadata.radio.install))

        if Config.Debug then
            Utils.Debug('info', 'Open Radio with debug')
        end

        data.playlist = test

        data.id = data.plate

        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'radio', data = data })
        SendNUIMessage({ action = 'radioData', data = data, })
        radioOpen = true

        RadioOpen(data.plate)
    end
end

function RadioOpen(plate)
    local current = xSound:getInfo(plate)

    current.entity = GetVehiclePedIsIn(cache.ped, false)

    while current do
        current = xSound:getInfo(plate)
        current.playlist = test
        SendNUIMessage({ action = 'radioData', data = current })
        Citizen.Wait(500)
        if not radioOpen then
            break
        end
    end
end

RegisterNuiCallback('radioNui', function(data, cb)

    if data.action == 'saveSong' or data.action == 'deleteSong' then
        if data.entity then
           
        end
        local song = lib.callback.await('mVehicle:radio:PlayList', nil, data.action, data)
        cb(song)
        return
    end

    if data.action == 'play' then
        data.volume = data.volume / 100.0

        data.distance = Config.Radio.distance

        data.entity = GetVehiclePedIsIn(cache.ped, false)

        if not DoesEntityExist(entity) then
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
        radioOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'radio', data = false })
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
end
