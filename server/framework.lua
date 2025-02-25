local FrameWorks = {
    esx = (GetResourceState("es_extended") == "started" and 'esx'),
    ox = (GetResourceState("ox_core") == "started" and 'ox'),
    qbx = (GetResourceState("qbx_core") == "started" and 'qbx')
}

FrameWork = FrameWorks.esx or FrameWorks.ox or FrameWorks.qbx or 'standalone'

ESX, Ox = nil, nil

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
    elseif FrameWork == "qbx" then
        local Player = exports.qbx_core:GetPlayer(src)
        if Player then
            return Player.PlayerData.citizenid, Player.PlayerData.license
        end
    elseif FrameWork == "standalone" then
        return GetPlayerIdentifier(src, 'license')
    end
end


function GetName(src)
    if FrameWork == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            return xPlayer.getName()
        end
    elseif FrameWork == "qbx" then
        local qbxPlayer = exports.qbx_core:GetPlayer(src)
        if qbxPlayer then
            return ('%s %s'):format(qbxPlayer.PlayerData.charinfo.firstname, qbxPlayer.PlayerData.charinfo.lastname)
        end
    elseif FrameWork == "standalone" then
        return GetPlayerName(src)
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
        getVehicleByPlateOrFakeplate ="SELECT * FROM `owned_vehicles` WHERE TRIM(`plate`) = TRIM(?) OR JSON_UNQUOTE(JSON_EXTRACT(`metadata`, '$.fakeplate')) = TRIM(?) LIMIT 1",
        setOwner = 'INSERT INTO `owned_vehicles` (owner, plate, vehicle, type, job, metadata) VALUES (?, ?, ?, ?, ?, ?)',
        setOwnerParking ='INSERT INTO `owned_vehicles` (owner, plate, vehicle, type, job, metadata, parking) VALUES (?, ?, ?, ?, ?, ?, ?)',
        deleteByPlate = 'DELETE FROM `owned_vehicles` WHERE TRIM(`plate`) = TRIM(?)',
        deleteById = 'DELETE FROM `owned_vehicles` WHERE `id` = ?',
        saveMetadata = 'UPDATE `owned_vehicles` SET `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        saveMetadataId = 'UPDATE `player_vehicles` SET `metadata` = ? WHERE `id` = ?',
        saveProps = 'UPDATE `owned_vehicles` SET `vehicle` = ? WHERE TRIM(`plate`) = TRIM(?)',
        storeGarage ='UPDATE `owned_vehicles` SET `parking` = ?, `stored` = 1, `vehicle` = ?, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        retryGarage = 'UPDATE `owned_vehicles` SET `stored` = 0 WHERE TRIM(`plate`) = TRIM(?)',
        setImpound = 'UPDATE `owned_vehicles` SET `parking` = ?, `stored` = 0, `pound` = 1 WHERE TRIM(`plate`) = TRIM(?)',
        retryImpound ='UPDATE `owned_vehicles` SET  `stored` = 0, `parking` = ?, `pound` = NULL WHERE TRIM(`plate`) = TRIM(?)',
        saveLeftVehicle = 'UPDATE `owned_vehicles` SET `mileage` = ?, `vehicle` = ? WHERE TRIM(`plate`) = TRIM(?)',
        saveLeftVehicleMeta ='UPDATE `owned_vehicles` SET `mileage` = ?, `vehicle` = ?, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        plateExist = 'SELECT 1 FROM `owned_vehicles` WHERE TRIM(`plate`) = TRIM(?)',
        saveAllPropsCoords = 'UPDATE `owned_vehicles` SET  `vehicle` = ?, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        getVehiclesbyOwner = "SELECT * FROM `owned_vehicles` WHERE `owner` = ?",
        getVehiclesbyOwnerAndhaveKeys ="SELECT * FROM `owned_vehicles` WHERE `owner` = ? OR JSON_KEYS(metadata, '$.keys') LIKE ?",
        selectAll = 'SELECT * FROM `owned_vehicles`',
        setVehicleJob = 'UPDATE `owned_vehicles` SET `job` = ? WHERE TRIM(`plate`) = TRIM(?)',
    },

    ['qbx'] = {
        getVehicleById = 'SELECT * FROM `player_vehicles` WHERE `id` = ? LIMIT 1',
        getVehicleByPlate = 'SELECT * FROM `player_vehicles` WHERE TRIM(`plate`) = TRIM(?) LIMIT 1',
        getVehicleByPlateOrFakeplate ="SELECT * FROM `player_vehicles` WHERE TRIM(`plate`) = TRIM(?) OR JSON_UNQUOTE(JSON_EXTRACT(`metadata`, '$.fakeplate')) = TRIM(?) LIMIT 1",
        setOwner = 'INSERT INTO `player_vehicles` (citizenid, plate, mods, type, job, metadata, license) VALUES (?, ?, ?, ?, ?, ?, ?)',
        setOwnerParking ='INSERT INTO `player_vehicles` (citizenid, plate, mods, type, job, metadata, garage, license) VALUES (?, ?, ?, ?, ?, ?, ?,?)',
        deleteByPlate = 'DELETE FROM `player_vehicles` WHERE TRIM(`plate`) = TRIM(?)',
        deleteById = 'DELETE FROM `player_vehicles` WHERE `id` = ?',
        saveMetadata = 'UPDATE `player_vehicles` SET `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        saveMetadataId = 'UPDATE `player_vehicles` SET `metadata` = ? WHERE `id` = ?',
        saveProps = 'UPDATE `player_vehicles` SET `mods` = ? WHERE TRIM(`plate`) = TRIM(?)',
        storeGarage ='UPDATE `player_vehicles` SET `garage` = ?, `stored` = 1, `mods` = ?, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        retryGarage = 'UPDATE `player_vehicles` SET `stored` = 0 WHERE TRIM(`plate`) = TRIM(?)',
        setImpound ='UPDATE `player_vehicles` SET `garage` = ?, `stored` = 0, `pound` = 1 WHERE TRIM(`plate`) = TRIM(?)',
        retryImpound ='UPDATE `player_vehicles` SET  `stored` = 0, `garage` = ?, `pound` = NULL WHERE TRIM(`plate`) = TRIM(?)',
        saveLeftVehicle = 'UPDATE `player_vehicles` SET `mileage` = ?, `mods` = ? WHERE TRIM(`plate`) = TRIM(?)',
        saveLeftVehicleMeta = 'UPDATE `player_vehicles` SET `mileage` = ?, `mods` = ?, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        plateExist = 'SELECT 1 FROM `player_vehicles` WHERE TRIM(`plate`) = TRIM(?)',
        saveAllPropsCoords = 'UPDATE `player_vehicles` SET  `mods` = ?, `metadata` = ? WHERE TRIM(`plate`) = TRIM(?)',
        getVehiclesbyOwner = "SELECT * FROM `player_vehicles` WHERE `citizenid` = ?",
        getVehiclesbyOwnerAndhaveKeys = "SELECT * FROM `player_vehicles` WHERE `citizenid` = ? OR JSON_KEYS(metadata, '$.keys') LIKE ?",
        selectAll = 'SELECT * FROM `player_vehicles`',
        setVehicleJob = 'UPDATE `player_vehicles` SET `job` = ? WHERE TRIM(`plate`) = TRIM(?)',
    },
}


Querys = db[FrameWork]
