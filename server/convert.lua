while not FrameWork do
    Wait(100)
end

if FrameWork ~= 'esx' then return end


local deleteColumnKeys = true
local deleteColumnCoords = true

local keysMigrated = false
local coordsMigrated = false
local keysDeleted = false
local coordsDeleted = false

MySQL.query("SHOW COLUMNS FROM owned_vehicles LIKE 'keys'", {}, function(result)
    if result and #result > 0 then
        MySQL.query("SELECT plate, metadata, `keys` FROM owned_vehicles WHERE `keys` IS NOT NULL AND TRIM(`keys`) <> ''",
            {}, function(vehicles)
                if vehicles and #vehicles > 0 then
                    local pendingUpdates = #vehicles

                    for _, vehicle in ipairs(vehicles) do
                        local plate = vehicle.plate
                        local metadata = vehicle.metadata and json.decode(vehicle.metadata) or {}
                        local keys = json.decode(vehicle.keys)

                        if keys then
                            metadata.keys = keys

                            MySQL.update(
                                "UPDATE owned_vehicles SET metadata = ? WHERE plate = ?",
                                { json.encode(metadata), plate },
                                function(affectedRows)
                                    pendingUpdates = pendingUpdates - 1
                                    keysMigrated = true

                                    if pendingUpdates == 0 and deleteColumnKeys then
                                        MySQL.query("ALTER TABLE owned_vehicles DROP COLUMN `keys`", {}, function()
                                            keysDeleted = true
                                        end)
                                    end
                                end
                            )
                        end
                    end
                else
                    if deleteColumnKeys then
                        MySQL.query("ALTER TABLE owned_vehicles DROP COLUMN `keys`", {}, function()
                            keysDeleted = true
                        end)
                    end
                end
            end)
    end
end)

MySQL.query("SHOW COLUMNS FROM owned_vehicles LIKE 'coords'", {}, function(result)
    if result and #result > 0 then
        MySQL.query("SELECT plate, metadata, coords FROM owned_vehicles WHERE coords IS NOT NULL AND TRIM(coords) <> ''",
            {}, function(vehicles)
                if vehicles and #vehicles > 0 then
                    local pendingUpdates = #vehicles

                    for _, vehicle in ipairs(vehicles) do
                        local plate = vehicle.plate
                        local metadata = vehicle.metadata and json.decode(vehicle.metadata) or {}
                        local coords = json.decode(vehicle.coords)

                        if coords then
                            metadata.coords = coords

                            MySQL.update(
                                "UPDATE owned_vehicles SET metadata = ? WHERE plate = ?",
                                { json.encode(metadata), plate },
                                function(affectedRows)
                                    pendingUpdates = pendingUpdates - 1
                                    coordsMigrated = true

                                    if pendingUpdates == 0 and deleteColumnCoords then
                                        MySQL.query("ALTER TABLE owned_vehicles DROP COLUMN `coords`", {}, function()
                                            coordsDeleted = true
                                        end)
                                    end
                                end
                            )
                        end
                    end
                else
                    if deleteColumnCoords then
                        MySQL.query("ALTER TABLE owned_vehicles DROP COLUMN `coords`", {}, function()
                            coordsDeleted = true
                        end)
                    end
                end
            end)
    end
end)

Citizen.SetTimeout(5000, function()
    local message = "^2[Migration]^0 "
    local changesMade = false

    if keysMigrated then
        message = message .. "| ^3 'keys' data migrated to metadata.keys^0 "
        changesMade = true
    end

    if keysDeleted then
        message = message .. "| ^3 'keys' column deleted^0 "
        changesMade = true
    end

    if coordsMigrated then
        message = message .. "| ^3 'coords' data migrated to metadata.coords^0 "
        changesMade = true
    end

    if coordsDeleted then
        message = message .. "| ^3 'coords' column deleted^0 "
        changesMade = true
    end

    if changesMade then print(message) end
end)
