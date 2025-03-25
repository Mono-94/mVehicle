while not FrameWork do
    Wait(100)
end

if FrameWork ~= 'esx' then return end




MySQL.ready(function()
    MySQL.query("SHOW COLUMNS FROM owned_vehicles LIKE 'keys'", {}, function(result)
        if result and #result > 0 then
            MySQL.query(
                "SELECT plate, metadata, `keys` FROM owned_vehicles WHERE `keys` IS NOT NULL AND TRIM(`keys`) <> ''",
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
                                        if pendingUpdates == 0 and true then
                                            MySQL.query("ALTER TABLE owned_vehicles DROP COLUMN `keys`")
                                        end
                                    end
                                )
                            end
                        end
                    else
                        if true then
                            MySQL.query("ALTER TABLE owned_vehicles DROP COLUMN `keys`")
                        end
                    end
                end)
        end
    end)

    MySQL.query("SHOW COLUMNS FROM owned_vehicles LIKE 'coords'", {}, function(result)
        if result and #result > 0 then
            MySQL.query(
                "SELECT plate, metadata, coords FROM owned_vehicles WHERE coords IS NOT NULL AND TRIM(coords) <> ''",
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
                                        if pendingUpdates == 0 and true then
                                            MySQL.query("ALTER TABLE owned_vehicles DROP COLUMN `coords`")
                                        end
                                    end
                                )
                            end
                        end
                    else
                        if true then
                            MySQL.query("ALTER TABLE owned_vehicles DROP COLUMN `coords`")
                        end
                    end
                end)
        end
    end)
end)
