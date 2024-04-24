ESX, Ox, QBCore = nil, nil, nil

if Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()

    RegisterNetEvent('esx:playerLoaded', function(src, xPlayer, isNew) end)
    RegisterNetEvent('esx:playerDropped', function(src, reason) end)
elseif Config.Framework == "ox" then
    Ox = require '@ox_core.lib.init'
    AddEventHandler('ox:playerLoaded', function(src, userid, charid) end)
    AddEventHandler('ox:playerLogout', function(src, userid, charid) end)
elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

function Notification(src, data)
    TriggerClientEvent('ox_lib:notify', src, {
        title = data.title,
        description = data.description,
        position = data.position or 'center-left',
        icon = data.icon or 'ban',
        type = data.type or 'warning',
        iconAnimation = data.iconAnimation or 'beat',
        iconColor = data.iconColor or '#C53030',
        duration = data.duration or 2000,
        showDuration = true,
    })
end


function Identifier(src)
    if Config.Framework == "esx" then
        local Player = ESX.GetPlayerFromId(src)
        if Player then
            return Player.identifier
        end
    elseif Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            return Player.PlayerData.citizenid
        end
    elseif Config.Framework == "standalone" then
        return GetPlayerIdentifierByType(src, 'license')
    elseif Config.Framework == "ox" then
        local player = Ox.GetPlayer(src)
        if player then
            return player.charId
        end
    end
end

function GetName(src)
    if Config.Framework == "esx" then
        local Player = ESX.GetPlayerFromId(src)
        if Player then
            return Player.getName()
        end
    elseif Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local firstname = Player.PlayerData.charinfo.firstname
            local lastname = Player.PlayerData.charinfo.lastname
            return firstname .. ' ' .. lastname
        end
    elseif Config.Framework == "standalone" then
        return GetPlayerName(src)
    elseif Config.Framework == "ox" then
        local Player = Ox.GetPlayer(src)
        if Player then
            return Player.get('name')
        end
    end
end

function OnlinePlayers()
    if Config.Framework == "esx" then
        return ESX.GetPlayers()
    elseif Config.Framework == "qb" then
        return QBCore.Functions.GetPlayers()
    elseif Config.Framework == "standalone" then
        return GetPlayers()
    elseif Config.Framework == "ox" then
        return Ox.GetPlayers()
    end
end

function GetCoords(src, veh)
    local entity = src and GetPlayerPed(src) or veh
    if not entity then return end
    local coords, heading = GetEntityCoords(entity), GetEntityHeading(entity)
    return { x = coords.x, y = coords.y, z = coords.z, w = heading }
end

-- StandAlone uses the same table as ESX
local query = {
    ['esx'] = {
        getVehicleById = 'SELECT * FROM `owned_vehicles` WHERE `id` = ? LIMIT 1',
        getVehicleByPlate = 'SELECT * FROM `owned_vehicles` WHERE `plate` = ? LIMIT 1',
        setOwner = 'INSERT INTO `owned_vehicles` (owner, plate, vehicle, type, job, coords, metadata) VALUES (?, ?, ?, ?, ?, ?, ?)',
        deleteByPlate = 'DELETE FROM owned_vehicles WHERE plate = ?',
        deleteById = 'DELETE FROM owned_vehicles WHERE id = ?',
        saveMetadata = 'UPDATE owned_vehicles SET metadata = ? WHERE plate = ?',
        saveProps = 'UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?',
        storeGarage ='UPDATE `owned_vehicles` SET `parking` = ?, `stored` = 1,  `coords` = NULL, `vehicle` = ?, metadata = ?  WHERE `plate` = ?',
        retryGarage = 'UPDATE `owned_vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0 WHERE `plate` = ?',
        setImpound = 'UPDATE `owned_vehicles` SET `parking` = ?, `stored` = 0, `pound` = 1, `coords` = NULL, metadata = ? WHERE `plate` = ?',
        retryImpound ='UPDATE `owned_vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0, `parking` = ?, pound = NULL WHERE `plate` = ?',
        getMileage = 'SELECT `mileage` FROM owned_vehicles WHERE plate = ? LIMIT 1',
        saveLeftVehicle = 'UPDATE owned_vehicles SET mileage = ?, coords = ?, vehicle = ? WHERE plate = ?',
        updateTrailer = 'UPDATE owned_vehicles SET coords = ?, vehicle = ? WHERE plate = ?',
        plateExist = 'SELECT 1 FROM `owned_vehicles` WHERE `plate` = ?',
        saveAllPropsCoords = 'UPDATE owned_vehicles SET coords = ?, vehicle = ?, metadata = ? WHERE plate = ?',
        saveAllCoords = 'UPDATE owned_vehicles SET coords = ?, metadata = ? WHERE plate = ?',
        saveKeys = 'UPDATE owned_vehicles SET `keys` = ? WHERE plate = ?',
    },
    -- type, coords, vehicle, keys, lastparking, pound, mileage
    ['ox'] = {
        getVehicleById = 'SELECT * FROM `vehicles` WHERE `id` = ? LIMIT 1',
        setOwner = 'INSERT INTO `vehicles` (owner, plate, vehicle, type, `group`, coords, data, vin) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        deleteByPlate = 'DELETE FROM vehicles WHERE plate = ?',
        deleteById = 'DELETE FROM vehicles WHERE id = ?',
        saveMetadata = 'UPDATE vehicles SET data = ? WHERE plate = ?',
        saveProps = 'UPDATE vehicles SET vehicle = ? WHERE plate = ?',
        storeGarage = 'UPDATE `vehicles` SET `parking` = ?, `stored` = 1,  `coords` = NULL, `vehicle` = ?, data = ?  WHERE `plate` = ?',
        retryGarage = 'UPDATE `vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0 WHERE `plate` = ?',
        setImpound = 'UPDATE `vehicles` SET `parking` = ?, `stored` = 0, `pound` = 1, `coords` = NULL, data = ? WHERE `plate` = ?',
        retryImpound = 'UPDATE `vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0, `parking` = ?, pound = NULL WHERE `plate` = ?',
        getMileage = 'SELECT `mileage` FROM vehicles WHERE plate = ? LIMIT 1',
        saveLeftVehicle = 'UPDATE vehicles SET mileage = ?, coords = ?, vehicle = ? WHERE plate = ?',
        updateTrailer = 'UPDATE vehicles SET coords = ?, vehicle = ? WHERE plate = ?',
        plateExist = 'SELECT 1 FROM `vehicles` WHERE `plate` = ?',
        vinExist = 'SELECT 1 FROM `vehicles` WHERE `vin` = ?',
        saveAllPropsCoords = 'UPDATE `vehicles` SET coords = ?, vehicle = ?, data = ? WHERE plate = ?',
        saveAllCoords = 'UPDATE `vehicles` SET coords = ?, data = ? WHERE plate = ?',
        saveAllMetada = 'UPDATE `vehicles` SET data = ? WHERE plate = ?',
        saveKeys = 'UPDATE `vehicles` SET `keys` = ? WHERE plate = ?',
    },

    ['qb'] = {

        

    }
}

-- Función para generar un VIN
function generateVin(make, name)
    if not name then
        error("generateVin recibió datos de vehículo inválidos (modelo inválido)")
    end

    local arr = {
        getRandomInt(),
        make and string.upper(make:sub(1, 2)) or "OX",
        string.upper(name:sub(1, 2)),
        nil,
        nil,
        os.time()
    }

    while true do
        arr[4] = getRandomAlphanumeric()
        arr[5] = getRandomChar()
        local vin = table.concat(arr, "")

        if IsVinAvailable(vin) then
            return vin
        end
    end
end


Querys = query[Config.Framework] or query['esx']
