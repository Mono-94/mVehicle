local FrameWorks = {
    esx = (GetResourceState("es_extended") == "started" and 'esx'),
    ox = (GetResourceState("ox_core") == "started" and 'ox')
}

local FrameWork = FrameWorks.esx or FrameWorks.ox or 'standalone'


ESX, OX = nil, nil

if FrameWork == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
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
    if FrameWork == "esx" then
        local Player = ESX.GetPlayerFromId(src)
        if Player then
            return Player.identifier
        end
    elseif FrameWork == "standalone" then
        return GetPlayerIdentifier(src, 'identifier')
    end
end

function GetName(src)
    if FrameWork == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            return xPlayer.getName()
        end
    elseif FrameWork == "standalone" then
        return GetPlayerName(src)
    end
end

function OnlinePlayers()
    if FrameWork == "esx" then
        return ESX.GetPlayers()
    elseif FrameWork == "standalone" then
        return GetPlayers()
    end
end

function GetCoords(src, veh)
    local entity = src and GetPlayerPed(src) or veh
    if not DoesEntityExist(entity) then return end
    local coords, heading = GetEntityCoords(entity), GetEntityHeading(entity)
    return { x = coords.x, y = coords.y, z = coords.z, w = heading }
end

-- StandAlone uses the same table as esx
local db = {
    ['esx'] = {
        getVehicleById = 'SELECT * FROM `owned_vehicles` WHERE `id` = ? LIMIT 1',
        getVehicleByPlate = 'SELECT * FROM `owned_vehicles` WHERE TRIM(`plate`) = TRIM(?) LIMIT 1',
        getVehicleByPlateOrFakeplate =
        "SELECT * FROM `owned_vehicles` WHERE TRIM(`plate`) = TRIM(?) OR JSON_UNQUOTE(JSON_EXTRACT(`metadata`, '$.fakeplate')) = TRIM(?) LIMIT 1",
        setOwner =
        'INSERT INTO `owned_vehicles` (owner, plate, vehicle, type, job, coords, metadata) VALUES (?, ?, ?, ?, ?, ?, ?)',
        setOwnerParking =
        'INSERT INTO `owned_vehicles` (owner, plate, vehicle, type, job, coords, metadata, parking) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        deleteByPlate = 'DELETE FROM `owned_vehicles` WHERE TRIM(`plate`) = TRIM(?)',
        deleteById = 'DELETE FROM `owned_vehicles` WHERE `id` = ?',
        saveMetadata = 'UPDATE `owned_vehicles` SET `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        saveProps = 'UPDATE `owned_vehicles` SET `vehicle` = ? WHERE TRIM(`plate`) = TRIM(?)',
        storeGarage =
        'UPDATE `owned_vehicles` SET `parking` = ?, `stored` = 1, `coords` = NULL, `vehicle` = ?, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        storeGarageNoProps =
        'UPDATE `owned_vehicles` SET `parking` = ?, `stored` = 1, `coords` = NULL, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        retryGarage =
        'UPDATE `owned_vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0 WHERE TRIM(`plate`) = TRIM(?)',
        setImpound =
        'UPDATE `owned_vehicles` SET `parking` = ?, `stored` = 0, `pound` = 1, `coords` = NULL, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        retryImpound =
        'UPDATE `owned_vehicles` SET `lastparking` = ?, `coords` = ?, `stored` = 0, `parking` = ?, `pound` = NULL WHERE TRIM(`plate`) = TRIM(?)',
        getMileage = 'SELECT `mileage` FROM `owned_vehicles` WHERE TRIM(`plate`) = TRIM(?) LIMIT 1',
        saveLeftVehicle =
        'UPDATE `owned_vehicles` SET `mileage` = ?, `coords` = ?, `vehicle` = ? WHERE TRIM(`plate`) = TRIM(?)',
        updateTrailer = 'UPDATE `owned_vehicles` SET `coords` = ?, `vehicle` = ? WHERE TRIM(`plate`) = TRIM(?)',
        plateExist = 'SELECT 1 FROM `owned_vehicles` WHERE TRIM(`plate`) = TRIM(?)',
        saveAllPropsCoords =
        'UPDATE `owned_vehicles` SET `coords` = ?, `vehicle` = ?, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        saveAllCoords = 'UPDATE `owned_vehicles` SET `coords` = ?, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        saveKeys = 'UPDATE `owned_vehicles` SET `keys` = ? WHERE TRIM(`plate`) = TRIM(?)',
        getVehiclesbyOwner = "SELECT * FROM `owned_vehicles` WHERE `owner` = ?",
        getVehiclesbyOwnerAndhaveKeys = "SELECT * FROM `owned_vehicles` WHERE `owner` = ? OR JSON_KEYS(`keys`) LIKE ?",
        selectAll = 'SELECT * FROM `owned_vehicles`',
        getKeys = 'SELECT * FROM `owned_vehicles` WHERE `owner` = ?',
        selectMetadataPlata = 'SELECT `metadata` FROM `owned_vehicles` WHERE TRIM(`plate`) = TRIM(?) LIMIT 1',
        setVehicleJob = 'UPDATE `owned_vehicles` SET `job` = ? WHERE TRIM(`plate`) = TRIM(?)',
    },
}


Querys = db[FrameWork]
