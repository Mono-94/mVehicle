local GetPlayers = GetPlayers

Persistent = {
    Debug = true,
    -- Refresh CoordsAvailable
    WaitRefresh = 10000,
    --- Player ped/vehicle culling. No entities will be created on
    --- clients outside a ‘focus zone’, which currently is hardcoded to 424 units around a player.
    --- (https://docs.fivem.net/docs/scripting-reference/onesync/)
    DistanceCooords = 400,
    -- Store Avaible zones for spawn
    CoordsAvailable = {},
    --- Store vehicles awaiting for client focus zone
    VehicleAwaiting = {}
}

local msg = function(msg, ...)
    return Persistent.Debug and print((msg):format(...))
end

local blip = function(id, coords, action, bucket)
    return Persistent.Debug and
        TriggerClientEvent('mvehicle:persistent:area:debug', -1, id, coords, Persistent.DistanceCooords, action, bucket)
end

local function check_coord(c1, c2)
    return #(vec3(c1.x, c1.y, c1.z) - vec3(c2.x, c2.y, c2.z)) < Persistent.DistanceCooords
end

function Persistent:SetNew(coords, id, bucket)
    Persistent.VehicleAwaiting[id] = { coords = coords, bucket = bucket }
    msg('Vehicle id [%s] waiting for client available ', id)
    blip(id, coords, 'add', bucket)
end

function Persistent:DeletVehicle(id)
    if Persistent.VehicleAwaiting[id] then
        Persistent.VehicleAwaiting[id] = nil
    end
end

function Persistent:DeleteCoordAvaible(id)
    Persistent.CoordsAvaible[id] = nil
end

function Persistent:CreateVehicle(id, coords)
    Vehicles.CreateVehicleId({ id = id, coords = coords })
    msg('Vehicle id [%s] spawning correct', id)
    blip(id)
    Persistent:DeletVehicle(id)
end

function Persistent:Refresh()
    local allPlayers = GetPlayers()
    local newCoordsAvaible = {}
    for _, src in ipairs(allPlayers) do
        local coords = GetEntityCoords(GetPlayerPed(src))
        local bucket = GetPlayerRoutingBucket(src)
        newCoordsAvaible[src] = { coords = coords, bucket = bucket }
    end

    local toRemove = {}
    local referenceSet = false
    for src1, data1 in pairs(newCoordsAvaible) do
        for src2, data2 in pairs(newCoordsAvaible) do
            if src1 ~= src2 and data1.bucket == data2.bucket and check_coord(data1.coords, data2.coords) then
                if not referenceSet then
                    referenceSet = true
                else
                    toRemove[src2] = true
                end
            end
        end
    end

    for src in pairs(toRemove) do
        newCoordsAvaible[src] = nil
    end

    Persistent.CoordsAvaible = newCoordsAvaible

    if next(Persistent.VehicleAwaiting) ~= nil then
        Persistent:VehiclesAwaiting()
    end
end

function Persistent:Set(coords, id, bucket)
    local tooClose = false
    if not coords then
        msg('[ERROR] Vehicle ID:%s, invalid COORDS', id)
    end

    if next(Persistent.CoordsAvaible) then
        for _, data in pairs(Persistent.CoordsAvaible) do
            if data.bucket == bucket and check_coord(coords, data.coords) then
                tooClose = true
                break
            end
        end
    end

    if not tooClose then
        Persistent:SetNew(coords, id, bucket)
    else
        Persistent:CreateVehicle(id, coords)
    end

    return tooClose
end

function Persistent:VehiclesAwaiting()
    for id, data in pairs(Persistent.VehicleAwaiting) do
        local canSpawn = false
        for _, playerData in pairs(Persistent.CoordsAvaible) do
            if data.bucket == playerData.bucket and check_coord(data.coords, playerData.coords) then
                canSpawn = true
                break
            end
        end

        if canSpawn then
            Persistent:CreateVehicle(id, data.coords)
        end
    end
end

exports('RefreshAwait', function()
    Citizen.CreateThread(function(threadId)
        Wait(2000)
        Persistent:Refresh()
    end)
end)

Citizen.CreateThread(function()
    while true do
        Persistent:Refresh()
        Citizen.Wait(Persistent.WaitRefresh)
    end
end)

AddEventHandler('playerDropped', function(playerId)
    Persistent:DeleteCoordAvaible(playerId)
end)
