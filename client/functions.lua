-- Get label from vehicle model like 'Karin Sulta'

function VehicleLabel(model)
    local makeName = GetMakeNameFromVehicleModel(model)
    makeName = makeName:sub(1, 1):upper() .. makeName:sub(2):lower()
    local displayName = GetDisplayNameFromVehicleModel(model)
    displayName = displayName:sub(1, 1):upper() .. displayName:sub(2):lower()
    return makeName .. ' ' .. displayName
end

--Get Player keys
function KeyItem(plate)
    if not Config.ItemKeys then return true end
    if Config.Inventory == 'ox' then
        local key = exports.ox_inventory:Search('count', Config.CarKeyItem, { plate = plate })
        if key >= 1 then
            return true
        else
            return false
        end
    elseif Config.Inventory == 'qs' then
        local items = exports['qs-inventory']:getUserInventory()
        for item, meta in pairs(items) do
            if meta.info.plate == plate then
                return true
            else
                return false
            end
        end
    end
end

-- Get Vector4 from entity
function GetVector4(entity)
    local c, h = GetEntityCoords(entity), GetEntityHeading(entity)
    return vec4(c.x, c.y, c.z, h)
end

-- Notifications
function Notification(data)
    lib.notify({
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

RegisterNetEvent('mVehicle:Notification', Notification)

