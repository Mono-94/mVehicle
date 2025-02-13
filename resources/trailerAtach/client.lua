if not Config.TargetTrailer then return end

local trailer = nil
local dist <const> = 10.0
local trailerModel <const> = 2078290630     -- spawn name 'tr2'

local canInteract = function(entity, distance, coords, name, bone)
    if GetVehicleClass(entity) == 11 and GetEntityModel(entity) == trailerModel then
        return true
    end
end

exports.ox_target:addGlobalVehicle({
    {
        distance = dist,
        canInteract = canInteract,
        label = locale('flip_trailer'),
        icon = 'fa-solid fa-trailer',
        onSelect = function(data)
            local carCoords = GetEntityRotation(data.entity, 2)
            SetEntityRotation(data.entity, carCoords[1], 0, carCoords[3], 2, true)
            SetVehicleOnGroundProperly(data.entity)
        end
    },
    {
        distance = dist,
        icon = 'fa-solid fa-up-down',
        canInteract = canInteract,
        label = locale('up_dow_ramp'),
        onSelect = function(data)
            if GetVehicleDoorAngleRatio(data.entity, 5) > 0.0 then
                SetVehicleDoorShut(data.entity, 5, true)
            else
                SetVehicleDoorOpen(data.entity, 5, false, false)
            end
        end
    },

    {
        distance = dist,
        icon = 'fa-solid fa-up-down',
        canInteract = canInteract,
        label = locale('up_dow_platform'),
        onSelect = function(data)
            if GetVehicleDoorAngleRatio(data.entity, 4) > 0.2 then
                SetVehicleDoorShut(data.entity, 4, false)
            else
                SetVehicleDoorOpen(data.entity, 4, false, false)
            end
        end
    },

    {
        distance = dist,
        label = locale('attach_vehicle'),
        icon = 'fa-solid fa-lock',
        canInteract = function(entity, distance, coords, name, bone)
            local retval = IsEntityAttachedToAnyVehicle(entity)
            if retval then return false end
            local vehicles = lib.getNearbyVehicles(coords, 10, true)
            for i, vehicle in ipairs(vehicles) do
                if vehicle.vehicle ~= entity then
                    local model = GetEntityModel(vehicle.vehicle)
                    if model == trailerModel then
                        trailer = vehicle.vehicle
                        return true
                    end
                end
            end
        end,
        onSelect = function(data)
            local vehCoords = GetEntityCoords(data.entity)
            local vehRotation = GetEntityRotation(data.entity)
            local OffSetTrailer = GetOffsetFromEntityGivenWorldCoords(trailer, vehCoords)
            AttachVehicleOnToTrailer(data.entity, trailer, 0.0, 0.0, 0.0, OffSetTrailer, vehRotation.x, vehRotation.y, 0.0, false)
        end
    },

    {
        distance = dist,
        label = locale('dettach_vehicle'),
        icon = 'fa-solid fa-lock-open',
        canInteract = function(entity, distance, coords, name, bone)
            if GetVehicleClass(entity) == 11 and GetEntityModel(entity) == trailerModel then return false end
            local retval = IsEntityAttachedToAnyVehicle(entity)
            if retval then return true end
        end,
        onSelect = function(data)
            DetachEntity(data.entity, true, false)
        end
    },

})
