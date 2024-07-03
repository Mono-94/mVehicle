Vehicles = {}

Vehicles.Vehicles = {}


local ox_inv = exports.ox_inventory

local PlateCron = {}

local function DeleteTemporary(plate, hour, min)
    if PlateCron[plate] then return end

    local expression = ('%s %s * * *'):format(min, hour)

    lib.cron.new(expression, function(task, date)
        local vehicle = Vehicles.GetVehicleByPlate(plate)

        if DoesEntityExist(vehicle.entity) then
            DeleteEntity(vehicle.entity)
        end

        PlateCron[plate] = false

        MySQL.execute(Querys.deleteByPlate, { plate })

        if Vehicles.Vehicles[vehicle.entity] then
            Vehicles.Vehicles[vehicle.entity] = nil
        end
        task:stop()
    end, { debug = Config.Debug })

    PlateCron[plate] = true
end

local function VehicleType(model)
    local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, true, true)

    local gametime = GetGameTimer()
    local ms = 10000

    while not DoesEntityExist(tempVehicle) do
        Citizen.Wait(100)
        if GetGameTimer() - gametime > ms then
            break
        end
    end

    local vehicleType = GetVehicleType(tempVehicle)

    DeleteEntity(tempVehicle)

    return vehicleType
end


---@param data table
---@param cb function
function Vehicles.CreateVehicle(data, cb)
    if not data.vehicle.plate then return false, lib.print.error('Error CreateVehicle vehicle plate is NIL') end

    if Vehicles.Vehicles then
        for entity, vehicle in pairs(Vehicles.Vehicles) do
            if vehicle.plate == data.vehicle.plate then
                return false, lib.print.error('Error CreateVehicle plate duplicated')
            end
        end
    end

    if data.data then
        data.metadata = data.data
    end

    data.metadata = json.decode(data.metadata) or {}

    if not data.plate then
        data.plate = data.vehicle.plate
    end

    data.mileage = data.mileage or 0

    if data.identifier then
        data.owner = data.identifier
    end
    if data.license then
        data.owner = data.license
    end

    if data.source then
        data.owner = Identifier(data.source)
        if not data.owner then return false, lib.print.error('Error CreateVehicle No Player Identifier by source!') end
    end

    if type(data.keys) == 'string' then
        data.keys = json.decode(data.keys)
    end

    if Config.VehicleTypes[data.type] then
        data.type = VehicleType(data.vehicle.model)
    end

    if not data.type then
        data.type = VehicleType(data.vehicle.model)
    end


    if not data.spawn then
        if data.coords == nil then return false end
        data.entity = CreateVehicleServerSetter(data.vehicle.model, data.type, data.coords.x, data.coords.y,
            data.coords.z,
            data.coords.w)

        local startTime = GetGameTimer()
        local ms = 20000

        while not DoesEntityExist(data.entity) do
            Citizen.Wait(100)
            if GetGameTimer() - startTime > ms then
                return false
            end
        end
    end

    if data.temporary then
        data.metadata.temporary = data.temporary
    end

    if data.metadata.DoorStatus then
        if DoesEntityExist(data.entity) then
            SetVehicleDoorsLocked(data.entity, tonumber(data.metadata.DoorStatus))
        end
    end

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

                return
            else
                DeleteTemporary(data.plate, metadata_hour, metadata_minute)
            end
        end
    end


    local State                    = Entity(data.entity).state

    Vehicles.Vehicles[data.entity] = {}

    Citizen.Wait(100)

    data.EntityOwner = NetworkGetEntityOwner(data.entity)
    data.NetId       = NetworkGetNetworkIdFromEntity(data.entity)


    if data.id then
        State:set('id', data.id, true)
    end

    if data.setOwner then
        data.metadata.firstSpawn = os.date("%Y/%m/%d %H:%M:%S")
        if data.temporary then
            data.metadata.temporary = data.temporary
        end
        local setowner = Vehicles.SetVehicleOwner(data)
        data.id = State.id
        State:set('id', setowner, true)
    end

    if data.vin then
        State:set('vin', data.vin, true)
    end

    if data.metadata.fakeplate then
        data.vehicle.plate = data.metadata.fakeplate
    else
        data.vehicle.plate = data.plate
    end

    if data.metadata.RoutingBucket then
        SetEntityRoutingBucket(data.entity, data.metadata.RoutingBucket)
    end

    if data.group then
        data.job = data.group
    end

    if Config.Debug then
        if data.metadata.engineSound then
            State:set('engineSound', data.metadata.engineSound, true)
        end
    end

    State:set('plate', data.plate, true)
    State:set('setVehicleProperties', data.vehicle, true)
    State:set('fuel', data.vehicle.fuelLevel or 100, true)
    State:set('metadata', data.metadata, true)
    State:set('type', data.type, true)
    State:set('Spawned', true, true)
    State:set('Owner', data.owner, true)
    State:set('job', data.job, true)
    State:set('props', data.vehicle, true)
    State:set('mileage', data.mileage, true)

    Vehicles.Vehicles[data.entity] = data

    

    if data.intocar then
        local ped = GetPlayerPed(data.intocar)
        TaskWarpPedIntoVehicle(ped, data.entity, -1)
    end


    SetVehicleNumberPlateText(data.entity, data.vehicle.plate)

    if cb then
        cb(data, Vehicles.GetVehicle(data.entity))
    else
        return data, Vehicles.GetVehicle(data.entity)
    end
end

---GetVehicleId
---@param id number
---@return table|boolean
function Vehicles.GetVehicleId(id)
    local vehicle = MySQL.single.await(Querys.getVehicleById, { id })
    if not vehicle then
        lib.print.error('No Vehicle by ID [ ' .. id .. ' ] in Vehicles Table')
        return false
    end
    return vehicle
end

function Vehicles.SetCarOwner(src, entity)
    local data       = {}
    local playerped  = GetPlayerPed(src)
    local identifier = Identifier(src)
    if not entity then
        data.entity = GetVehiclePedIsIn(playerped, false)
    end
    if not data.entity or not identifier or not playerped then
        return false, lib.print.error('SetCarOwner Missing data')
    end

    if Vehicles.Vehicles[data.entity] then
        return false, lib.print.error('SetCarOwner This vehicle already has an owner')
    end

    local props   = Vehicles.GetClientProps(src)
    props.plate   = Vehicles.GeneratePlate()
    data.coords   = GetCoords(src)
    data.parking  = Config.GarageNames[1]
    data.plate    = props.plate
    data.vehicle  = props
    data.owner    = identifier
    data.setOwner = true
    data.spawn    = true

    if Config.ItemKeys then
        Vehicles.ItemCarKeys(src, 'add', data.plate)
    end

    Vehicles.CreateVehicle(data)
end

function Vehicles.GetControlVehicle(src, entity, identifier)
    if not DoesEntityExist(entity) then
        entity = NetworkGetEntityFromNetworkId(entity)
        if not DoesEntityExist(entity) then
            return lib.print.error('Entity Does not exist')
        end
    end
    local data = {}
    if not identifier then
        identifier = Identifier(src)
    end
    data.entity      = entity
    data.EntityOwner = NetworkGetEntityOwner(data.entity)
    data.NetId       = NetworkGetNetworkIdFromEntity(data.entity)
    local props      = Vehicles.GetClientProps(src, data.NetId)
    props            = props
    data.plate       = props.plate
    data.vehicle     = props
    data.owner       = identifier
    data.keys        = { [identifier] = GetName() }
    data.setOwner    = false
    data.spawn       = true

    if Config.ItemKeys then
        Vehicles.ItemCarKeys(src, 'add', data.plate)
    end

    Vehicles.CreateVehicle(data)
end

RegisterServerEvent('mVehicle:OnBuyVehicle', Vehicles.GetControlVehicle)
RegisterServerEvent('mVehicle:GetVehicleControl', Vehicles.GetControlVehicle)


function Vehicles.SetVehicleOwner(data)
    local insert = {}
    if Config.Framework == 'standalone' or 'esx' or 'LG' then
        insert = { data.owner, data.plate, json.encode(data.vehicle), data.type, data.job, json.encode(data.coords),
            json.encode(data.metadata), data.parking }
    elseif Config.Framework == 'ox' then
        insert = { data.owner, data.plate, json.encode(data.vehicle), data.type, data.job, json.encode(data.coords),
            json.encode(data.metadata), Vehicles.RandomVin(), data.parking }
    elseif Config.Framework == 'qbox' then
        insert = { data.owner, data.plate, json.encode(data.vehicle), data.type, data.job, json.encode(data.coords),
            json.encode(data.metadata), Vehicles.RandomVin(), data.parking }
    end
    local await = MySQL.insert.await(Querys.setOwner, insert)
    return await
end

function Vehicles.GetVehicle(EntityId)
    if not Vehicles.Vehicles[EntityId] then return false end

    if not DoesEntityExist(EntityId) then return lib.print.error('GetVehicle No Entity') end

    local State = Entity(EntityId).state
    local self  = Vehicles.Vehicles[EntityId]


    ---Save Metadata
    self.SaveMetaData = function()
        MySQL.update(Querys.saveMetadata, { json.encode(self.metadata), self.plate })
        State:set("metadata", self.metadata, true)
        --  SendClientVehicles()
    end

    --- SetMetadata
    ---@param key string
    ---@param value any
    self.SetMetadata = function(key, value)
        self.metadata[key] = value
        self.SaveMetaData()
    end

    --- DeleteMetadata
    ---@param key string
    ---@param value string|nil
    self.DeleteMetadata = function(key, value)
        if not self.metadata[key] then
            lib.print.error(('No key %s in metadata'):format(key))
            return
        end
        if value then
            if type(self.metadata[key]) ~= "table" or not self.metadata[key][value] then
                lib.print.error(('No data "%s" in %s'):format(value, key))
                return
            end
            self.metadata[key][value] = nil
            if next(self.metadata[key]) == nil then
                self.metadata[key] = nil
            end
        else
            self.metadata[key] = nil
        end

        self.SaveMetaData()
    end

    --- GetMetadata
    ---@param key string|nil
    ---@return any
    self.GetMetadata = function(key)
        if key == nil then
            return self.metadata
        else
            return self.metadata[key]
        end
    end

    ---AddKeys
    ---comment
    ---@param src number
    self.AddKey = function(src)
        local identifier = Identifier(src)
        if not self.keys then
            self.keys = {}
        end
        if identifier then
            self.keys[identifier] = GetName(src)
            State:set("Keys", self.keys, true)
            MySQL.update(Querys.saveKeys, { json.encode(self.keys), self.plate })
        end
    end

    ---RemoveKey
    self.RemoveKey = function(identifier)
        -- local identifier = Identifier(src)
        if self.keys[identifier] then
            self.keys[identifier] = nil
            State:set("Keys", self.keys, true)
            MySQL.update(Querys.saveKeys, { json.encode(self.keys), self.plate })
        end
    end

    self.GetKeys = function()
        return self.keys
    end

    ---SaveVehiclePrps
    ---@param props table
    self.SaveProps = function(props)
        self.vehicle = props
        State:set('props', props, true)
        MySQL.update(Querys.saveProps, { json.encode(props), self.plate })
    end

    self.DeleteVehicle = function(fromDatabase)
        if DoesEntityExist(EntityId) then
            Entity(EntityId).state.FadeEntity = { action = 'delete' }
        end
        if fromDatabase then
            MySQL.execute(Querys.deleteByPlate, { self.plate })
        end
        Vehicles.Vehicles[EntityId] = nil
        
        self = nil
        return self
    end

    ---StoreVehicle
    ---@param parking string
    ---@return boolean
    self.StoreVehicle = function(parking, mods)
        local store = false
        if not mods then
            mods = Vehicles.GetClientProps(self.EntityOwner, self.NetId)
            mods = json.encode(mods)
            print(2, mods)
        end
        if not mods then
            local affectedRows = MySQL.update.await(Querys.storeGarageNoProps,
                { parking, json.encode(self.metadata), self.plate })
            if affectedRows > 0 then
                Entity(EntityId).state.FadeEntity = { action = 'delete' }
                Vehicles.Vehicles[EntityId] = nil
                self = nil
                store = true
            end
        else
            local affectedRows = MySQL.update.await(Querys.storeGarage,
                { parking, mods, json.encode(self.metadata), self.plate })
            if affectedRows > 0 then
                Entity(EntityId).state.FadeEntity = { action = 'delete' }
                Vehicles.Vehicles[EntityId] = nil
                self = nil
                store = true
            end
        end
        return store
    end

    ---ImpoundVehicle
    self.ImpoundVehicle = function(impound, price, note, date, endpound)
        self.SetMetadata('pound', {
            price = price or Config.DefaultImpound.price,
            reason = note or Config.DefaultImpound.note,
            date = date or os.date("%Y/%m/%d %H:%M"),
            endPound = endpound
        })

        MySQL.update(Querys.setImpound, { impound, json.encode(self.metadata), self.plate })

        if DoesEntityExist(EntityId) then
            Entity(EntityId).state.FadeEntity = { action = 'delete' }
        end

        --  SendClientVehicles()
        Vehicles.Vehicles[EntityId] = nil
        self = nil
    end

    ---RetryVehicle
    ---@param coords vector4
    ---@return boolean
    self.RetryVehicle = function(coords)
        MySQL.update(Querys.retryGarage, { self.parking, json.encode(coords), self.plate })
        
    end

    ---RetryVehicle
    ---@param ToGarage string Garage name
    ---@param coords vector4
    ---@return boolean
    self.RetryImpound = function(ToGarage, coords)
        local affectedRows = MySQL.update.await(Querys.retryImpound,
            { self.parking, json.encode(coords), ToGarage, self.plate })
        if affectedRows then
            self.DeleteMetadata('pound')
        end
    end

    --- Set Fake plate
    ---@param fakeplate string
    self.FakePlate = function(fakeplate)
        if type(fakeplate) == 'string' then
            self.SetMetadata('fakeplate', fakeplate)
        else
            self.DeleteMetadata('fakeplate')
        end
    end

    --- Set Vehicle in Routing Bucket
    ---@param bucket number
    self.Private = function(bucket, coords, parking)
        if bucket then
            SetEntityRoutingBucket(self.entity, bucket)
            self.SetMetadata('RoutingBucket', bucket)
            self.private = 1
            MySQL.update('UPDATE owned_vehicles SET private = 1, coords = ?, parking = ?  WHERE plate = ?',
                { json.encode(coords), parking, self.plate })
        else
            SetEntityRoutingBucket(self.entity, 0)
            self.DeleteMetadata('RoutingBucket')
            self.private = nil
            MySQL.update('UPDATE owned_vehicles SET private = 0 WHERE plate = ?', { self.plate })
        end
    end

    -- Save Coords
    self.SaveLeftVehicle = function(coords, props, mileages)
        local inBucket = self.GetMetadata('RoutingBucket')
        State:set('props', props, true)
        if inBucket then return end
        self.coords = coords
        self.mileage = math.floor(mileages * 100)
        print(mileages)
        MySQL.update(Querys.saveLeftVehicle, { self.mileage, self.coords, json.encode(props), self.plate })
    end

    self.CoordsAndProps = function(coords, props)
        State:set('props', props, true)
        self.coords = coords
        --  SendClientVehicles()
        return MySQL.update.await(Querys.updateTrailer, { self.coords, json.encode(props), self.plate })
    end

    if Config.Debug then
        -- Engine Sound | Not finish
        self.SetEngineSound = function(name)
            self.SetMetadata('engineSound', name)
            State:set('engineSound', name, true)
        end
    end
    return self
end

-- Engine Sound | Not finish
if Config.Debug then
    RegisterServerEvent('mVehicle:SetEngineSound', function(NetId, soundName)
        local entity = NetworkGetEntityFromNetworkId(NetId)
        local vehicle = Vehicles.GetVehicle(entity)
        vehicle.SetEngineSound(soundName)

        lib.print.warn('Engine Sounds BETA')
    end)
end

function Vehicles.GetVehicleByPlate(plate)
    for k, v in pairs(Vehicles.Vehicles) do
        if v.plate == plate then
            return Vehicles.GetVehicle(v.entity)
        end
    end
end

function Vehicles.GetVehicleByPlateDB(plate)
    return MySQL.single.await(Querys.getVehicleByPlate, { plate })
end

---GetAllVehicles
function Vehicles.GetAllVehicles(src, VehicleTable, haveKeys)
    local identifier = Identifier(src)
    if VehicleTable then
        if identifier then
            local veh = {}
            for k, v in pairs(Vehicles.Vehicles) do
                if v.owner == identifier or v.license == identifier then
                    if haveKeys then
                        veh[v.entity] = v
                        return veh
                    else
                        return veh
                    end
                end
            end
        end
        return Vehicles.Vehicles
    else
        if identifier then
            local rows = {}
            if haveKeys then
                rows = MySQL.query.await(Querys.getVehiclesbyOwnerAndhaveKeys, { identifier, '%"' .. identifier .. '"%' })
            else
                rows = MySQL.query.await(Querys.getVehiclesbyOwner, { identifier, })
            end
            return rows
        end
    end
end

--- PlateExist
---@param plate any
---@return boolean
function Vehicles.PlateExist(plate)
    return not MySQL.scalar.await(Querys.plateExist, { plate })
end

--- GeneratePlate
-- - Return a plate
---@return string
function Vehicles.GeneratePlate()
    local plate
    local pattern = Config.PlateGenerate

    if #pattern < 8 then
        pattern = pattern .. string.rep(" ", 8 - #pattern)
    end

    repeat
        plate = ""
        for i = 1, #pattern do
            local char = pattern:sub(i, i)
            if char == "A" then
                plate = plate .. string.char(math.random(65, 90))
            elseif char == "1" then
                plate = plate .. tostring(math.random(0, 9))
            elseif char == "." then
                if math.random(2) == 1 then
                    plate = plate .. string.char(math.random(65, 90))
                else
                    plate = plate .. tostring(math.random(0, 9))
                end
            else
                plate = plate .. char
            end
        end
    until Vehicles.PlateExist(plate)

    return plate
end

function Vehicles.RandomVin()
    local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    local random = math.random
    repeat
        result = ""
        for i = 1, 17 do
            local randomIndex = random(1, #characters)
            result = result .. characters:sub(randomIndex, randomIndex)
        end
    until not MySQL.scalar.await(Querys.vinExist, { result })

    return result
end

---SpawnVehicles
-- - Spawn all vehicles from DB
function Vehicles.SpawnVehicles()
    local dbvehicles = MySQL.query.await(Querys.selectAll)
    for i = 1, #dbvehicles do
        local row = dbvehicles[i]
        local metadata = json.decode(row.metadata)

        if Config.VehicleTypes[row.type] then
            row.type = 'automobile'
        end

        if metadata and metadata.temporary then
            local datetime = metadata.temporary
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
                    MySQL.execute(Querys.deleteByPlate, { row.plate })
                    row.coords = nil
                else
                    DeleteTemporary(row.plate, metadata_hour, metadata_minute)
                end
            end
        end

        if row.coords and row.stored == 0 or row.stored == nil and row.pound == nil then
            row.vehicle = json.decode(row.vehicle)
            row.coords  = json.decode(row.coords)
            Vehicles.CreateVehicle(row)

            Citizen.Wait(200)
        end
    end
end

local GetVehicleProps = {}

RegisterNetEvent('mVehicle:ReceiveProps', function(id, data)
    local props = json.decode(data)
    if GetVehicleProps[id] then
        GetVehicleProps[id](props)
        GetVehicleProps[id] = nil
    end
end)

function Vehicles.GetClientProps(PlayerID, NetworkID)
    local entity = NetworkGetEntityFromNetworkId(NetworkID)
    SetEntityDistanceCullingRadius(entity, 99999.0)

    Wait(100)

    local promise = promise.new()

    GetVehicleProps[entity] = function(props)
        promise:resolve(props)
    end

    TriggerClientEvent('mVehicles:RequestProps', PlayerID, entity, NetworkID)

    local result = Citizen.Await(promise)

    SetEntityDistanceCullingRadius(entity, 0.0)

    return result
end

---SaveAllVehicles
---@param delete boolean Delete Entitys?
function Vehicles.SaveAllVehicles(delete)
    for entity, veh in pairs(Vehicles.Vehicles) do
        if DoesEntityExist(entity) and not veh.private then
            local coords = json.encode(GetCoords(false, entity))

            local props = Vehicles.GetClientProps(veh.EntityOwner, veh.NetId)

            local doors = GetVehicleDoorLockStatus(entity)
            veh.metadata.DoorStatus = doors

            if not props then
                MySQL.update(Querys.saveAllCoords, { coords, json.encode(veh.metadata), veh.plate })
            else
                MySQL.update(Querys.saveAllPropsCoords,
                    { coords, json.encode(props), json.encode(veh.metadata), veh.plate })
            end


            if delete then
                DeleteEntity(entity)
                Vehicles.Vehicles[entity] = nil
            end
            Wait(50)
        end
    end
end

---ItemCarKeys
---@param src number
---@param action string
---@param plate string
---@param vehicleid number
function Vehicles.ItemCarKeys(src, action, plate, vehicleid)
    local xPlayer  = ESX.GetPlayerFromId(src)
    local metadata = {}
    local cleanedPlate = plate:gsub("%s+", "")
    local items = GetMetadata(xPlayer)

    if Config.Inventory == 'ox' then
        metadata = {
            plate       = cleanedPlate,
            id          = vehicleid,
            description = vehicleid .. ' ' .. cleanedPlate,
        }
    elseif Config.Inventory == 'qs' then
        metadata = {
            plate       = cleanedPlate,
            description = vehicleid
        }
    end

    if action == 'add' then
        if Config.Inventory == 'ox' then
            ox_inv:AddItem(src, Config.CarKeyItem, 1, metadata)
        elseif Config.Inventory == 'qs' then
            exports['qs-inventory']:AddItem(src, Config.CarKeyItem, 1, nil, metadata)
        end
    elseif action == 'delete' then
        for _, object in pairs(items) do
            if object.name == Config.CarKeyItem then
                if Config.Inventory == 'ox' then
                    RemoveItemMetadata(xPlayer, Config.CarKeyItem, 1, metadata)
                else
                    if object.info.plate == cleanedPlate and object.info.description == vehicleid then
                        RemoveItemMetadata(xPlayer, object.name, object.slot, object)
                            if Config.Debug then
                                print('The vehicle key was deleted with plate: [' .. cleanedPlate.. ']')
                            end
                        return
                    end
                end
            end
        end
    end
end

exports('ItemCarKeys', Vehicles.ItemCarKeys)

function RemoveItemMetadata(player, item, slot, metadata)
    if not player then return end
    if Config.Inventory == 'qs' then
        exports['qs-inventory']:RemoveItem(player.source, item, 1, slot, metadata)
    elseif Config.Inventory == 'ox' then
        ox_inv:RemoveItem(player.source, item, 1, metadata, slot)
    else
        error('Inventory bad configured')
    end
end

function GetMetadata(player, item, slot, metadata)
    if not player then return end
    if Config.Inventory == 'qs' then
        return exports['qs-inventory']:GetInventory(player.source)
    elseif Config.Inventory == 'ox' then
        return ox_inv:GetInventoryItems(player.source)
    else
        error('Inventory bad configured')
    end
end

lib.callback.register('mVehicle:GiveKey', function(source, action, plate)
    Vehicles.ItemCarKeys(source, action, plate)
end)

lib.callback.register('mVehicle:VehicleState', function(source, action, data)
    local vehicle = nil
    if data then
        vehicle = Vehicles.GetVehicleByPlate(data.plate)
    end

    if action == 'update' then
        if vehicle then
            vehicle.SaveLeftVehicle(data.coords, data.props, data.mileage)
        else
            MySQL.update(Querys.saveLeftVehicle, { math.floor(data.mileage * 100), data.coords, json.encode(data.props), data.plate })
        end
    elseif action == 'savetrailer' then
        return vehicle.CoordsAndProps(data.coords, data.props)
    elseif action == 'addkey' then
        if data.serverid == source then return end
        local target = Identifier(data.serverid)
        if target then
            if not data.keys then data.keys = {} end
            if data.keys[target] then return end
            data.keys[target] = GetName(data.serverid)
            if vehicle then
                vehicle.AddKey(data.serverid)
            else
                MySQL.update(Querys.saveKeys, { json.encode(data.keys), data.plate })
            end
        end
    elseif action == 'deletekey' then
        if vehicle and data.identifier then
            vehicle.RemoveKey(data.identifier)
        else
            MySQL.update(Querys.saveKeys, { json.encode(data.keys), data.plate })
        end
    elseif action == 'getkeys' then
        local identifier = Identifier(source)
        return MySQL.query.await(Querys.getKeys, { identifier })
    elseif action == 'getVeh' then
        local vehicle = Vehicles.GetVehicleByPlateDB(data)
      
        if vehicle then
            return { vehicle = true, mileage = vehicle.mileage }
        else
            return false
        end
    end
end)

lib.callback.register('mVehicle:VehicleControl', function(source, action, NetId, Status, modelName)
    local identifier = Identifier(source)
    local entity = NetworkGetEntityFromNetworkId(NetId)
    local vehicle = Vehicles.GetVehicle(entity)
    local plate = GetVehicleNumberPlateText(entity)
    local function sendNotification()
        Notification(source, {
            title = modelName,
            description = (Status == 2 and locale('open_door') or locale('close_door')),
            icon = (Status == 2 and 'lock-open' or 'lock'),
            iconColor = (Status == 2 and '#77e362' or '#e36462'),
        })
    end

    if action == 'doors' or action == 'engine' then
        if not Config.ItemKeys then
            local vehicledb = MySQL.single.await(Querys.getVehicleByPlateOrFakeplate, { plate, plate })

            local vehicleKeys = {}

            if not vehicledb and vehicle then
                vehicledb = { keys = vehicle.GetKeys() }
                vehicleKeys = vehicle.GetKeys()
            elseif vehicledb then
                vehicleKeys = json.decode(vehicledb.keys) or {}
            else
                return false
            end

            if not vehicleKeys then
                return false
            end

            local hasKeys = (not Config.ItemKeys and identifier == vehicledb.owner) or vehicleKeys[identifier] ~= nil

            if hasKeys then
                if action == 'doors' then
                    if Status == 2 then
                        if vehicle then vehicle.SetMetadata('DoorStatus', 0) end
                        SetVehicleDoorsLocked(entity, 0)
                    else
                        if vehicle then vehicle.SetMetadata('DoorStatus', 2) end
                        SetVehicleDoorsLocked(entity, 2)
                    end
                    sendNotification()
                end
                return true
            else
                return false
            end
        else
            if action == 'doors' then
                if Status == 2 then
                    SetVehicleDoorsLocked(entity, 0)
                    if vehicle then vehicle.SetMetadata('DoorStatus', 0) end
                else
                    SetVehicleDoorsLocked(entity, 2)
                    if vehicle then vehicle.SetMetadata('DoorStatus', 2) end
                end

                sendNotification()
            end
            return true
        end
    end
    return false
end)


if Config.Inventory == 'ox' then
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




exports('vehicle', function()
    return Vehicles
end)
