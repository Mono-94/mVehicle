--Lock Pick
exports('lockpick', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local player = GetPlayerPed(inventory.id)
        local coords = GetEntityCoords(player)
        local vehicles = lib.getClosestVehicle(coords, 5.0, true)
        local vehicle = Vehicles.GetVehicle(vehicles)
        local doorStatus = GetVehicleDoorLockStatus(vehicles)
        local Noty = function()
            Notification(source, {
                title = 'Vehiculo',
                description = (doorStatus == 2 and locale('open_door') or locale('close_door')),
                icon = (doorStatus == 2 and 'lock-open' or 'lock'),
                iconColor = (doorStatus == 2 and '#77e362' or '#e36462'),
            })
        end
        local skillCheck = lib.callback.await('mVehicle:PlayerItems', inventory.id, 'lockpick',
            NetworkGetNetworkIdFromEntity(vehicles))
        if skillCheck then
            if doorStatus == 2 then
                if vehicle then
                    vehicle.SetMetadata('DoorStatus', 0)
                end
                SetVehicleDoorsLocked(vehicles, 0)
                Noty()
                return false
            else
                if vehicle then
                    vehicle.SetMetadata('DoorStatus', 2)
                end
                SetVehicleDoorsLocked(vehicles, 2)
                Noty()
                return false
            end
        else

        end
        return false
    end
end)

--HotWire
exports('hotwire', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        lib.callback.await('mVehicle:PlayerItems', inventory.id, 'hotwire')
        return false
    end
end)



-- Fake Plate
exports('fakeplate', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local player = GetPlayerPed(inventory.id)
        local coords = GetEntityCoords(player)
        local identifier = Identifier(inventory.id)
        local vehicles = lib.getClosestVehicle(coords, 5.0, true)
        local vehicle = Vehicles.GetVehicle(vehicles)
        local itemSlot = exports.ox_inventory:GetSlot(inventory.id, slot)
        if vehicle then
            if vehicle.owner == identifier then
                local metadata = vehicle.GetMetadata('fakeplate')
                if not metadata and not itemSlot.metadata.plate then
                    local anim = lib.callback.await('mVehicle:PlayerItems', inventory.id, 'changeplate')
                    if anim then
                        exports.ox_inventory:SetMetadata(inventory.id, slot,
                            {
                                label = locale('fakeplate3'),
                                plate = vehicle.plate,
                                description = vehicle.plate,
                                fakeplate = itemSlot.metadata.fakeplate
                            })
                        SetVehicleNumberPlateText(vehicles, itemSlot.metadata.fakeplate)
                        vehicle.FakePlate(itemSlot.metadata.fakeplate)
                        return false
                    end
                elseif vehicle.plate == itemSlot.metadata.plate then
                    local anim = lib.callback.await('mVehicle:PlayerItems', inventory.id, 'changeplate')
                    if anim then
                        SetVehicleNumberPlateText(vehicles, vehicle.plate)
                        vehicle.FakePlate()
                        exports.ox_inventory:SetMetadata(inventory.id, slot,
                            {
                                description = itemSlot.metadata.fakeplate,
                                fakeplate = itemSlot.metadata.fakeplate
                            })
                    end
                end
            else
                Notification(inventory.id, {
                    title = locale('fakeplate1'),
                    description = locale('fakeplate2'),
                    icon = 'user',
                })
            end
        else
            local plate = GetVehicleNumberPlateText(vehicles)

        end

        return
    end
end)

if Config.Inventory == 'ox' and GetResourceState('ox_inventory') == 'started' then
    exports.ox_inventory:registerHook('createItem', function(payload)
        local plate = Vehicles.GeneratePlate()
        local metadata = payload.metadata
        metadata.description = plate
        metadata.fakeplate = plate
        return metadata
    end, {
        itemFilter = {
            [Config.FakePlateItem.item] = true
        }
    })
end
