-- Get label from vehicle model like 'Karin Sulta'
function VehicleLabel(model)
    if not IsModelValid(model) then
        lib.print.error(model .. ' - Model invalid')
        return model
    end
    local makeName = GetMakeNameFromVehicleModel(model)
    makeName = makeName:sub(1, 1):upper() .. makeName:sub(2):lower()
    local displayName = GetDisplayNameFromVehicleModel(model)
    displayName = displayName:sub(1, 1):upper() .. displayName:sub(2):lower()
    return makeName .. ' ' .. displayName
end

--Get Player keys
function KeyItem(plate)
    if not Config.ItemKeys then return true end
    local havekey = false
    if Config.Inventory == 'ox' then
        local carkeys = exports.ox_inventory:Search('slots', Config.CarKeyItem)
        for _, v in pairs(carkeys) do
            if v.metadata.plate:gsub("%s+", "") == plate:gsub("%s+", "") then
                havekey = true
                break
            end
        end

        if havekey then
            return true
        else
            return false
        end
    elseif Config.Inventory == 'qs' then
        local items = exports['qs-inventory']:getUserInventory()
        for item, meta in pairs(items) do
            if meta.info.plate:gsub("%s+", "") == plate:gsub("%s+", "") then
                havekey = true
                break
            end
        end
        if havekey then
            return true
        else
            return false
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
