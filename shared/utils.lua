Utils = {}

---@param type "debug"|"error"|"info"|"verbose"|"warn"
---@param text string
---@param ... any
function Utils.Debug(type, text, ...)
    if not Config.Debug then return end
    lib.print[type](text:format(...))
end

-- Notifications
function Utils.Notification(data)
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

RegisterNetEvent('mVehicle:Notification', Utils.Notification)

-- Get Vector4 from entity
---@param entity any
---@param encode? boolean return json string
function Utils.GetVector4(entity, encode)
    local c, h = GetEntityCoords(entity), GetEntityHeading(entity)
    local coords = vec4(c.x, c.y, c.z, h)
    if encode then return json.encode(coords) end
    return coords
end

---CreateVehicleServer
function Utils.CreateVehicleServer(type, model, coords)
    if not IsDuplicityVersion() then
        return Utils.Debug('error', 'This function only works on server side')
    end

    local entity = CreateVehicleServerSetter(model, type, coords.x, coords.y, coords.z, coords.w)
    -- https://docs.fivem.net/natives/?_0x489E9162
    SetEntityOrphanMode(entity, 2)

    local validEntity = lib.waitFor(function()
        if DoesEntityExist(entity) then
            return entity
        end
    end, 'Invalid entity', 5000)

    return validEntity
end

---Get Vehicle Type
function Utils.VehicleType(value)
    if not IsDuplicityVersion() then
        return Utils.Debug('error', 'This function only works on server side')
    end

    if DoesEntityExist(value) then
        return GetVehicleType(value)
    end

    local tempVehicle = CreateVehicle(value, 0, 0, 0, 0, true, true)

    local validEntity = lib.waitFor(function()
        if DoesEntityExist(tempVehicle) then return tempVehicle end
    end, 'Invalid entity', 5000)

    local vehicleType = GetVehicleType(validEntity)

    DeleteEntity(validEntity)

    return vehicleType
end

--Get Player keys
function Utils.KeyItem(plate)
    local havekey = false

    plate = plate:gsub("%s+", "")

    if Config.Inventory == 'ox' then
        local item = exports.ox_inventory:Search('slots', Config.CarKeyItem)
        for _, v in pairs(item) do
            if v.metadata and v.metadata.plate and v.metadata.plate:gsub("%s+", "") == plate then
                havekey = true
                break
            end
        end
    elseif Config.Inventory == 'qs' then
        local items = exports['qs-inventory']:getUserInventory()
        for _, v in pairs(items) do
            if v.info and v.info.plate and v.info.plate:gsub("%s+", "") == plate then
                havekey = true
                break
            end
        end
    end

    return havekey
end

function Utils.Round(value)
    local mult = 10 ^ (2 or 0)
    return math.floor(value * mult + 0.5) / mult
end

---@param eventName string
---@param funct function
function RegisterSafeEvent(eventName, funct)
    RegisterNetEvent(eventName, function(...)
        if GetInvokingResource() ~= nil then return end
        funct(...)
    end)
end
