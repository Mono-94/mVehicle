local GetEntityType = GetEntityType
local GetIsVehicleEngineRunning = GetIsVehicleEngineRunning
local DoesEntityExist = DoesEntityExist

local PlateCron = {}

function DeleteTemporary(plate, hour, min)
    if PlateCron[plate] then return end

    local expression = ('%s %s * * *'):format(min, hour)

    lib.cron.new(expression, function(task, date)
        PlateCron[plate] = false

        MySQL.execute(Querys.deleteByPlate, { plate })

        local vehicle = Vehicles.GetVehicleByPlate(plate)

        if vehicle then vehicle.DeleteVehicle(false) end

        task:stop()
    end, { debug = Config.Debug })

    PlateCron[plate] = true
end

function CheckTemporary(data)
    if data.metadata.temporary then
        local datetime = data.metadata.temporary
        local date = datetime:sub(1, 8)
        local time = datetime:sub(10)
        local actualtime = os.time()

        local current_date = os.date('%Y%m%d', actualtime)
        local current_hour = os.date('%H', actualtime)
        local current_minute = os.date('%M', actualtime)

        local metadata_hour = tonumber(time:sub(1, 2))
        local metadata_minute = tonumber(time:sub(4))

        if current_date == date then
            if tonumber(current_hour) > metadata_hour or tonumber(current_minute) > metadata_minute then
                MySQL.execute(Querys.deleteByPlate, { data.plate })
                if DoesEntityExist(data.entity) then
                    DeleteEntity(data.entity)
                end
                Vehicles.Vehicles[data.entity] = nil
                return true
            else
                DeleteTemporary(data.plate, metadata_hour, metadata_minute)
                return false
            end
        end
    end
    return false
end

lib.callback.register('mVehicle:VehicleState', function(source, action, data)
    local vehicle = nil

    if data and data.plate then
        vehicle = Vehicles.GetVehicleByPlate(data.plate)
    end

    if action == 'update' then
        if vehicle then
            vehicle.SaveLeftVehicle(data.coords, data.props, data.mileage)
        else
            local current = Vehicles.GetVehicleByPlate(data.plate, true)

            if not current then return end
            local metadata = json.decode(current.metadata) or { keys = {} }

            metadata.coords = json.decode(data.coords)
            metadata.mileage = math.floor(data.mileage * 100)
            MySQL.update(Querys.saveLeftVehicleMeta, { json.encode(data.props), json.encode(metadata), data.plate })
        end
    elseif action == 'savetrailer' then
        return vehicle and vehicle.CoordsAndProps(data.coords, data.props)
    elseif action == 'getkeys' then
        return Vehicles.GetAllPlayerVehicles(source, false, false)
    elseif action == 'getVeh' then
        local veh = Vehicles.GetVehicleByPlate(data.plate)

        if not veh then
            veh = Vehicles.GetVehicleByPlate(data.plate, true)
        end

        if veh then
            if type(veh.metadata) ~= "table" then
                veh.metadata = json.decode(veh.metadata)
            end
            return { vehicle = true, mileage = veh.metadata.mileage or 0 }
        else
            return false
        end
    end
end)

lib.versionCheck('Mono-94/mVehicle')

if not Config.VehicleDensity.CloseAllVehicles then return end

-- Close doors on entityCreated
AddEventHandler('entityCreated', function(entity)
    if DoesEntityExist(entity) and GetEntityType(entity) == 2 and not GetIsVehicleEngineRunning(entity) then
        SetVehicleDoorsLocked(entity, 2)
    end
end)