Core = nil

if Config.Framework == "esx" then
    Core = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "ox" then
    Core = require '@ox_core.lib.init'
elseif Config.FrameWork == "qb" then
    Core = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "LG" then
    Core = exports.LegacyFramework:ReturnFramework()
end

function Notification(src, data)
    TriggerClientEvent('mVehicle:Notification', src, {
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
        local Player = Core.GetPlayerFromId(src)
        if Player then
            return Player.identifier
        end
    elseif Config.Framework == "qbox" then
        local Player = exports.qbx_core:GetPlayer(src)
        if Player then
            return Player.PlayerData.license
        end
    elseif Config.Framework == "qb" then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            return Player.PlayerData.citizenid
        end
    elseif Config.Framework == "standalone" then
        return GetPlayerIdentifierByType(src, 'license')
    elseif Config.Framework == "ox" then
        local player = Core.GetPlayer(src)
        if player then
            return player.charId
        end
    elseif Config.Framework == "LG" then
        local playerData = Core.SvPlayerFunctions.GetPlayerData(src)[1]
        return playerData?.charName
    end
    return false
end

function GetName(src)
    if Config.Framework == "esx" then
        local Player = Core.GetPlayerFromId(src)
        if Player then
            return Player.getName()
        end
    elseif Config.Framework == "qbox" then
        local Player = exports.qbx_core:GetPlayer(src)
        if Player then
            local firstname = Player.PlayerData.charinfo.firstname
            local lastname = Player.PlayerData.charinfo.lastname
            return firstname .. ' ' .. lastname
        end
    elseif Config.Framework == "qb" then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            local firstname = Player.PlayerData.charinfo.firstname
            local lastname = Player.PlayerData.charinfo.lastname
            return firstname .. ' ' .. lastname
        end
    elseif Config.Framework == "standalone" then
        return GetPlayerName(src)
    elseif Config.Framework == "ox" then
        local Player = Core.GetPlayer(src)
        if Player then
            return Player.get('name')
        end
    elseif Config.Framework == "LG" then
        local Data = Core.SvPlayerFunctions.GetPlayerData(src)
        local PlayerData = Data[1]
        if Data and PlayerData then
            local firstname = PlayerData.firstName
            local lastname = PlayerData.lastName
            return firstname .. ' ' .. lastname
        end
    end
    return false
end

function OnlinePlayers()
    if Config.Framework == "esx" then
        return Core.GetPlayers()
    elseif Config.Framework == "qb" then
        return Core.Functions.GetPlayers()
    elseif Config.Framework == "standalone" then
        return GetPlayers()
    elseif Config.Framework == "qbox" then
        return GetPlayers()
    elseif Config.Framework == "ox" then
        return Core.GetPlayers()
    elseif Config.Framework == "LG" then
        return Core.SvPlayerFunctions.GetAllPlayers()
    end
end

function GetCoords(src, veh)
    local entity = src and GetPlayerPed(src) or veh
    if not entity then return end
    local coords, heading = GetEntityCoords(entity), GetEntityHeading(entity)
    return { x = coords.x, y = coords.y, z = coords.z, w = heading }
end

-- StandAlone uses the same table as Core

local query = {
    ['esx'] = {
        getVehicleById = 'SELECT * FROM `owned_vehicles` WHERE `id` = ? LIMIT 1',
        getVehicleByPlate = 'SELECT * FROM `owned_vehicles` WHERE `plate` = ? LIMIT 1',
        getVehicleByPlateOrFakeplate = "SELECT * FROM `owned_vehicles` WHERE `plate` = ? OR JSON_UNQUOTE(JSON_EXTRACT(`metadata`, '$.fakeplate')) = ? LIMIT 1",
        setOwner ='INSERT INTO `owned_vehicles` (owner, plate, vehicle, type, job, coords, metadata, parking) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        deleteByPlate = 'DELETE FROM owned_vehicles WHERE plate = ?',
        deleteById = 'DELETE FROM owned_vehicles WHERE id = ?',
        saveMetadata = 'UPDATE owned_vehicles SET metadata = ? WHERE plate = ?',
        saveProps = 'UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?',
        storeGarage = 'UPDATE `owned_vehicles` SET `parking` = ?, `stored` = 1,  `coords` = NULL, `vehicle` = ?, metadata = ?  WHERE `plate` = ?',
        retryGarage = 'UPDATE `owned_vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0 WHERE `plate` = ?',
        setImpound ='UPDATE `owned_vehicles` SET `parking` = ?, `stored` = 0, `pound` = 1, `coords` = NULL, metadata = ? WHERE `plate` = ?',
        retryImpound = 'UPDATE `owned_vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0, `parking` = ?, pound = NULL WHERE `plate` = ?',
        getMileage = 'SELECT `mileage` FROM owned_vehicles WHERE plate = ? LIMIT 1',
        saveLeftVehicle = 'UPDATE owned_vehicles SET mileage = ?, coords = ?, vehicle = ? WHERE plate = ?',
        updateTrailer = 'UPDATE owned_vehicles SET coords = ?, vehicle = ? WHERE plate = ?',
        plateExist = 'SELECT 1 FROM `owned_vehicles` WHERE `plate` = ?',
        saveAllPropsCoords = 'UPDATE owned_vehicles SET coords = ?, vehicle = ?, metadata = ? WHERE plate = ?',
        saveAllCoords = 'UPDATE owned_vehicles SET coords = ?, metadata = ? WHERE plate = ?',
        saveKeys = 'UPDATE owned_vehicles SET `keys` = ? WHERE plate = ?',
        getVehiclesbyOwner = "SELECT * FROM `owned_vehicles` WHERE `owner` = ?",
        getVehiclesbyOwnerAndhaveKeys = "SELECT * FROM `owned_vehicles` WHERE `owner` = ? OR JSON_KEYS(`keys`) LIKE ?",
        selectAll = 'SELECT * FROM `owned_vehicles`',
        getKeys = 'SELECT * FROM `owned_vehicles` WHERE `owner` = ?',
    },
    -- type, coords, vehicle, keys, lastparking, pound, mileage
    ['ox'] = {
        getVehicleById = 'SELECT * FROM `vehicles` WHERE `id` = ? LIMIT 1',
        setOwner =
        'INSERT INTO `vehicles` (owner, plate, vehicle, type, `group`, coords, data, vin, parking) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        deleteByPlate = 'DELETE FROM vehicles WHERE plate = ?',
        deleteById = 'DELETE FROM vehicles WHERE id = ?',
        saveMetadata = 'UPDATE vehicles SET data = ? WHERE plate = ?',
        saveProps = 'UPDATE vehicles SET vehicle = ? WHERE plate = ?',
        storeGarage =
        'UPDATE `vehicles` SET `parking` = ?, `stored` = 1,  `coords` = NULL, `vehicle` = ?, data = ?  WHERE `plate` = ?',
        retryGarage = 'UPDATE `vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0 WHERE `plate` = ?',
        setImpound =
        'UPDATE `vehicles` SET `parking` = ?, `stored` = 0, `pound` = 1, `coords` = NULL, data = ? WHERE `plate` = ?',
        retryImpound =
        'UPDATE `vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0, `parking` = ?, pound = NULL WHERE `plate` = ?',
        getMileage = 'SELECT `mileage` FROM vehicles WHERE plate = ? LIMIT 1',
        saveLeftVehicle = 'UPDATE vehicles SET mileage = ?, coords = ?, vehicle = ? WHERE plate = ?',
        updateTrailer = 'UPDATE vehicles SET coords = ?, vehicle = ? WHERE plate = ?',
        plateExist = 'SELECT 1 FROM `vehicles` WHERE `plate` = ?',
        vinExist = 'SELECT 1 FROM `vehicles` WHERE `vin` = ?',
        saveAllPropsCoords = 'UPDATE `vehicles` SET coords = ?, vehicle = ?, data = ? WHERE plate = ?',
        saveAllCoords = 'UPDATE `vehicles` SET coords = ?, data = ? WHERE plate = ?',
        saveAllMetada = 'UPDATE `vehicles` SET data = ? WHERE plate = ?',
        saveKeys = 'UPDATE `vehicles` SET `keys` = ? WHERE plate = ?',
        getVehiclesbyOwner = "SELECT * FROM `vehicles` WHERE `owner` = ?",
        getVehiclesbyOwnerAndhaveKeys = "SELECT * FROM `vehicles` WHERE `owner` = ? OR JSON_KEYS(`keys`) LIKE ?"
    },

    -- type, job, coords, metadata, lastparking, pound, stored, mileage
    ['qbox'] = {
        getVehicleById = 'SELECT * FROM `player_vehicles` WHERE `id` = ? LIMIT 1',
        getVehicleByPlate = 'SELECT * FROM `player_vehicles` WHERE `plate` = ? LIMIT 1',
        getVehicleByPlateOrFakeplate = "SELECT * FROM `player_vehicles` WHERE `plate` = ? OR JSON_UNQUOTE(JSON_EXTRACT(`metadata`, '$.fakeplate')) = ? LIMIT 1",
        setOwner = 'INSERT INTO `player_vehicles` (license, plate, vehicle, type, job, coords, metadata, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        deleteByPlate = 'DELETE FROM player_vehicles WHERE plate = ?',
        deleteById = 'DELETE FROM player_vehicles WHERE id = ?',
        saveMetadata = 'UPDATE player_vehicles SET metadata = ? WHERE plate = ?',
        saveProps = 'UPDATE player_vehicles SET vehicle = ? WHERE plate = ?',
        storeGarage = 'UPDATE `player_vehicles` SET `parking` = ?, `stored` = 1,  `coords` = NULL, `vehicle` = ?, metadata = ?  WHERE `plate` = ?',
        retryGarage = 'UPDATE `player_vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0 WHERE `plate` = ?',
        setImpound = 'UPDATE `player_vehicles` SET `parking` = ?, `stored` = 0, `pound` = 1, `coords` = NULL, metadata = ? WHERE `plate` = ?',
        retryImpound = 'UPDATE `player_vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0, `parking` = ?, pound = NULL WHERE `plate` = ?',
        getMileage = 'SELECT `mileage` FROM player_vehicles WHERE plate = ? LIMIT 1',
        saveLeftVehicle = 'UPDATE player_vehicles SET mileage = ?, coords = ?, vehicle = ? WHERE plate = ?',
        updateTrailer = 'UPDATE player_vehicles SET coords = ?, vehicle = ? WHERE plate = ?',
        plateExist = 'SELECT 1 FROM `player_vehicles` WHERE `plate` = ?',
        saveAllPropsCoords = 'UPDATE player_vehicles SET coords = ?, vehicle = ?, metadata = ? WHERE plate = ?',
        saveAllCoords = 'UPDATE player_vehicles SET coords = ?, metadata = ? WHERE plate = ?',
        saveKeys = 'UPDATE player_vehicles SET `keys` = ? WHERE plate = ?',
        getVehiclesbyOwner = "SELECT * FROM `player_vehicles` WHERE `license` = ?",
        getVehiclesbyOwnerAndhaveKeys = "SELECT * FROM `player_vehicles` WHERE `license` = ? OR JSON_KEYS(`keys`) LIKE ?",
        selectAll = 'SELECT * FROM `player_vehicles`',
        getKeys = 'SELECT * FROM `player_vehicles` WHERE `license` = ?',
    },
}


Querys = query[Config.Framework]
