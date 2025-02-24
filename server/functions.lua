Vehicles = {}
Vehicles.Vehicles = {}
Vehicles.Save = false
Vehicles.Config = Config

function Vehicles.save()
    return Vehicles.Save
end

---@return number
function Vehicles.GetVehicleCount()
    local count = 0
    for _ in pairs(Vehicles.Vehicles) do
        count = count + 1
    end
    return count
end

---DeleteFromTable
---@param entity any
---@param deleteVehicle? boolean
function Vehicles.DeleteFromTable(entity, deleteVehicle)
    Vehicles.Vehicles[entity] = nil
    if deleteVehicle and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end

---@param data table
---@param cb? function
function Vehicles.CreateVehicle(data, cb)
    if type(data.vehicle) ~= 'table' then
        data.vehicle = json.decode(data.vehicle)
    end

    if type(data.metadata) ~= 'table' then
        data.metadata = json.decode(data.metadata) or {}
    end

    if data.metadata.coords and not data.coords then
        data.coords = data.metadata.coords
    end

    if not data.vehicle or not data.plate or not data.coords then
        Utils.Debug('warn', 'CreateVehicle vehicle plate or coords are NIL value [ coords: %s , plate: %s,  ]',
            data.coords, data.plate, data.vehicle)
        return false
    end

    if not data.plate then
        data.plate = data.vehicle.plate
    end

    if Vehicles.GetVehicleByPlate(data.plate) then
        Utils.Debug('warn', 'CreateVehicle plate duplicated [ "%s" ]', data.plate)
        return false
    end

    if Config.VehicleTypes[data.type] or not data.type then
        data.type = Utils.VehicleType(data.vehicle.model)
    end


    if not data.onlyData then
        data.entity = Utils.CreateVehicleServer(data.type, data.vehicle.model, data.coords)

        if not data.entity then
            Utils.Debug("error", "CreateVehicleServer Entity is NIL")
            return false
        end
    end

    local State                    = Entity(data.entity).state

    Vehicles.Vehicles[data.entity] = {}

    data.EntityOwner               = NetworkGetEntityOwner(data.entity)

    data.NetId                     = NetworkGetNetworkIdFromEntity(data.entity)

    data.mileage                   = data.mileage or 0

    if data.temporary then
        data.metadata.temporary = data.temporary
    end

    if CheckTemporary(data) then
        return false
    end

    if data.metadata.DoorStatus then
        SetVehicleDoorsLocked(data.entity, data.metadata.DoorStatus)
    end

    if data.metadata.fakeplate then
        data.vehicle.plate = data.metadata.fakeplate
    end

    if data.metadata.RoutingBucket then
        SetEntityRoutingBucket(data.entity, data.metadata.RoutingBucket)
    end

    if data.metadata.engineSound then
        State:set('engineSound', data.metadata.engineSound, true)
    end

    lib.setVehicleProperties(data.entity, data.vehicle)

    State:set('plate', data.plate, true)

    State:set('fuel', data.vehicle.fuelLevel or 100, true)

    State:set('type', data.type, true)

    State:set('Spawned', true, true)

    if data.job then
        State:set('job', data.job, true)
    end

    if data.mileage then
        State:set('mileage', data.mileage, true)
    end

    if data.setOwner then
        data.owner = Identifier(data.source)
        if not data.owner then
            return false, Utils.Debug('error', 'Error CreateVehicle No Player Identifier by source!')
        end

        data.metadata.firstSpawn = os.date("%Y/%m/%d %H:%M:%S")
        data.metadata.fisrtOwner = GetName(data.source)

        data.id = Vehicles.SetVehicleOwner(data)
    end

    if data.id then
        State:set('id', data.id, true)
    end

    if data.metadata then
        State:set('metadata', data.metadata, true)
    end

    if data.owner then
        State:set('owner', data.owner, true)
    end

    Vehicles.Vehicles[data.entity] = data

    if data.intocar then
        local plyPed = GetPlayerPed(data.source)

        while GetVehiclePedIsIn(plyPed, false) == 0 do
            SetPedIntoVehicle(plyPed, data.entity, -1)
            Citizen.Wait(0)
        end
    end

    SetEntityDistanceCullingRadius(data.entity, 99999.0)

    SetVehicleNumberPlateText(data.entity, data.plate)


    if cb then
        cb(data, Vehicles.GetVehicle(data.entity))
    else
        return data, Vehicles.GetVehicle(data.entity)
    end
end

---Get Vehicle DB from ID
---@param id number
---@return table
function Vehicles.GetVehicleByID(id)
    local vehicle = MySQL.single.await(Querys.getVehicleById, { id })
    if FrameWork == 'qbx' and vehicle then
        vehicle.parking = vehicle.garage
        vehicle.vehicle = vehicle.mods
        vehicle.owner = vehicle.license
    end
    return vehicle
end

---Set Car owner
---@param PlayerId integer
---@param entity? integer
function Vehicles.SetCurrentVehicleOwner(PlayerId, entity)
    local data       = {}
    local playerped  = GetPlayerPed(PlayerId)
    local identifier = Identifier(PlayerId)


    if not entity then
        data.entity = GetVehiclePedIsIn(playerped, false)
    end

    if not DoesEntityExist(data.entity) or not identifier or not playerped then
        return false, Utils.Debug('error', 'SetCurrentVehicleOwner Missing data')
    end

    if Vehicles.Vehicles[data.entity] then
        return false, Utils.Debug('error', 'SetCurrentVehicleOwner This vehicle already has an owner')
    end

    local props   = Vehicles.GetClientProps(PlayerId, NetworkGetNetworkIdFromEntity(data.entity))
    data.metadata = {
        coords = GetCoords(PlayerId),
        keys = {}
    }
    data.plate    = props.plate
    data.vehicle  = props
    data.owner    = identifier
    data.setOwner = true
    data.onlyData = true
    data.source   = PlayerId

    if Config.ItemKeys then
        Vehicles.ItemCarKeys(PlayerId, 'add', props.plate)
    end

    return Vehicles.CreateVehicle(data)
end

function Vehicles.SetVehicleOwner(data)
    if not data.job then data.job = nil end

    local insert = {
        data.owner,
        data.plate,
        json.encode(data.vehicle),
        data.type,
        data.job,
        json.encode(data.metadata),
        data.parking
    }

    local query = ''

    if not data.parking then
        query = Querys.setOwner
        table.remove(insert, 7)
    else
        query = Querys.setOwnerParking
    end

    return MySQL.insert.await(query, insert)
end

function Vehicles.GetVehicle(entity)
    if not Vehicles.Vehicles[entity] then
        return false
    end

    if not DoesEntityExist(entity) then
        Utils.Debug('error', 'GetVehicle No Entity')
        return
    end

    local State       = Entity(entity).state

    local self        = Vehicles.Vehicles[entity]

    self.GetCoords    = function()
        local c, h = GetEntityCoords(self.entity), GetEntityHeading(self.entity)
        return { x = c.x, y = c.y, z = c.z, w = h }
    end

    ---Save Metadata
    self.SaveMetaData = function()
        MySQL.update(Querys.saveMetadata, { json.encode(self.metadata), self.plate })
        State:set("metadata", self.metadata, true)
    end

    --- SetMetadata
    --- value:'delete_meta' = nil / remove table
    ---@param key string|table
    ---@param value any
    self.SetMetadata  = function(key, value)
        if type(key) == "table" then
            for k, v in pairs(key) do
                if v == 'delete_meta' and self.metadata[k] then
                    self.metadata[k] = nil
                else
                    self.metadata[k] = v
                end
            end
        else
            self.metadata[key] = value == 'delete_meta' and nil or value
        end
        self.SaveMetaData()
        return self.metadata
    end


    --- DeleteMetadata
    ---@param key string|table
    ---@param value string|nil
    self.DeleteMetadata = function(key, value)
        local function deleteKey(k)
            if not self.metadata[k] then
                return false
            end
            if value then
                if type(self.metadata[k]) ~= "table" or not self.metadata[k][value] then
                    return false
                end
                self.metadata[k][value] = nil
                if next(self.metadata[k]) == nil then
                    self.metadata[k] = nil
                end
            else
                self.metadata[k] = nil
            end
            return true
        end

        if type(key) == "table" then
            for _, k in ipairs(key) do
                deleteKey(k)
            end
        else
            deleteKey(key)
        end

        self.SaveMetaData()

        return self.metadata
    end


    --- GetMetadata
    ---@param key? string
    self.GetMetadata    = function(key)
        if not key then
            return self.metadata
        else
            return self.metadata[key]
        end
    end

    --- SetJob
    self.SetJob         = function(job)
        self.SetMetadata('job', job)
        if Framework == 'esx' or Framework == 'qbx' then
            MySQL.update(Querys.setVehicleJob, { job, self.plate })
        end
    end

    ---AddKeys
    ---@param src number
    self.AddKey         = function(src)
        local identifier = Identifier(src)
        if not self.metadata.keys then self.metadata.keys = {} end
        if identifier then
            self.metadata.keys[identifier] = GetName(src)

            self.SetMetadata('keys', self.metadata.keys)

            return true
        end
        return false
    end

    ---RemoveKey
    self.RemoveKey      = function(identifier)
        if self.metadata.keys[identifier] then
            self.metadata.keys[identifier] = nil
            State:set('keys', self.metadata.keys, true)

            self.SetMetadata('keys', self.metadata.keys)
            return true
        end
        return false
    end

    self.GetKeys        = self.metadata.keys

    ---SaveVehiclePrps
    ---@param props table
    self.SaveProps      = function(props)
        self.vehicle = props
        MySQL.update(Querys.saveProps, { json.encode(props), self.plate })
    end

    self.DeleteVehicle  = function(fromDatabase)
        if DoesEntityExist(entity) then
            State:set('FadeEntity', { action = 'delete' }, true)
            State:set('Spawned', false, true)
        end

        if fromDatabase then
            MySQL.execute(Querys.deleteByPlate, { self.plate })
        end

        Vehicles.Vehicles[entity] = nil
        self = nil
    end

    ---StoreVehicle
    ---@param parking string
    ---@param props string|nil
    ---@return boolean
    self.StoreVehicle   = function(parking, props)
        local store = false

        local affectedRows = MySQL.update.await(Querys.storeGarage,
            { parking, props, json.encode(self.metadata), self.plate })

        if affectedRows > 0 then
            State:set('FadeEntity', { action = 'delete' }, true)
            Vehicles.Vehicles[entity] = nil
            self = nil
            store = true
        end

        return store
    end

    ---RetryVehicle
    self.RetryVehicle   = function()
        local coords = self.GetCoords()
        MySQL.update(Querys.retryGarage, { self.plate })
        self.SetMetadata({ coords = coords, lastParking = self.parking })
    end

    ---ImpoundVehicle
    ---@param impound string
    ---@param price number
    ---@param note string
    ---@param date string
    ---@param endpound string
    self.ImpoundVehicle = function(impound, price, note, date, endpound)
        self.SetMetadata('pound', {
            price = price,
            reason = note,
            date = date,
            endPound = endpound
        })

        MySQL.update(Querys.setImpound, { impound, self.plate })

        if DoesEntityExist(entity) then
            State:set('FadeEntity', { action = 'delete' }, true)
        end

        Vehicles.Vehicles[entity] = nil
        self = nil
    end

    ---RetryVehicle
    ---@param ToGarage string Garage name
    self.RetryImpound   = function(ToGarage)
        MySQL.update(Querys.retryImpound, { ToGarage, self.plate })

        self.SetMetadata({
            pound = 'delete_meta',
            lastParking = self.parking,
            coords = self.GetCoords()
        })
    end

    --- Set Fake plate or delete
    ---@param fakeplate? string
    self.FakePlate      = function(fakeplate)
        if fakeplate and type(fakeplate) == 'string' then
            self.SetMetadata('fakeplate', fakeplate)
        else
            self.DeleteMetadata('fakeplate')
        end
    end

    self.RoutingBucket  = function(id)
        SetEntityRoutingBucket(self.entity, id)
    end


    self.Private = function(bucket, coords, parking)
        if bucket then
            self.RoutingBucket(bucket)
            self.SetMetadata({ RoutingBucket = bucket, private = true })
            self.private = 1
            MySQL.update('UPDATE owned_vehicles SET private = 1, coords = ?, parking = ?  WHERE plate = ?',
                { json.encode(coords), parking, self.plate })
        else
            self.RoutingBucket(0)
            self.DeleteMetadata({ 'RoutingBucket', 'private' })
            self.private = nil
            MySQL.update('UPDATE owned_vehicles SET private = 0 WHERE plate = ?', { self.plate })
        end
    end


    -- Save Coords
    self.SaveLeftVehicle = function(coords, props, mileages)
        local inBucket = self.GetMetadata('RoutingBucket')
        if inBucket then return end
        self.coords = coords
        self.mileage = math.floor(mileages * 100)
        State:set('mileage', Utils.Round(self.mileage), true)

        MySQL.update(Querys.saveProps, { json.encode(props), self.plate })

        self.SetMetadata({
            mileages = self.mileage,
            coords = coords
        })
    end


    self.CoordsAndProps = function(coords, props)
        self.coords = coords

        self.SetMetadata({
            coords = coords
        })

        return MySQL.update.await(Querys.saveProps, { json.encode(props), self.plate })
    end

    self.setName = function(name)
        self.SetMetadata('vehname', name)
    end

    self.SetEngineSound = function(name)
        self.SetMetadata('engineSound', name)
        State:set('engineSound', name, true)
    end

    return self
end

---Get Vehicle By Plate, db true
---@param plate string
---@param db? boolean
function Vehicles.GetVehicleByPlate(plate, db)
    if not db then
        local isVehicle = false
        plate = plate:match("^%s*(.-)%s*$")
        plate = plate:gsub("%s+", " ")
        for k, v in pairs(Vehicles.Vehicles) do
            v.plate = v.plate:match("^%s*(.-)%s*$")
            v.plate = v.plate:gsub("%s+", " ")
            if v.plate == plate then
                isVehicle = true
                return Vehicles.GetVehicle(v.entity)
            end
        end

        if not isVehicle then
            return false
        end
    else
        local vehicle = MySQL.single.await(Querys.getVehicleByPlate, { plate })
        if FrameWork == 'qbx' and vehicle then
            vehicle.parking = vehicle.garage
            vehicle.vehicle = vehicle.mods
            vehicle.owner = vehicle.license
        end
        return vehicle
    end
end


---GetAllPlayerVehicles
---@param PlayerSource number Player Source
---@param VehicleTable boolean  true = internal mVehicle Table || false = DataBase
---@param haveKeys boolean Returns vehicles to which it has a key
function Vehicles.GetAllPlayerVehicles(PlayerSource, VehicleTable, haveKeys)
    local identifier = Identifier(PlayerSource)
    if VehicleTable then
        if identifier then
            local veh = {}
            for k, v in pairs(Vehicles.Vehicles) do
                if v.owner == identifier then
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
            local AllVehicles = nil
            if haveKeys then
                AllVehicles = MySQL.query.await(Querys.getVehiclesbyOwnerAndhaveKeys,
                    { identifier, '%"' .. identifier .. '"%' })
            else
                AllVehicles = MySQL.query.await(Querys.getVehiclesbyOwner, { identifier, })
            end


            if FrameWork == 'qbx' and AllVehicles then
                lib.array.forEach(AllVehicles, function(veh)
                    veh.parking = veh.garage
                    veh.vehicle = veh.mods
                    veh.owner = veh.license
                end)
            end

            return AllVehicles
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

---SpawnVehicles
-- - Spawn all vehicles from DB
function Vehicles.SpawnVehicles()
    local dbvehicles = MySQL.query.await(Querys.selectAll)
    lib.array.forEach(dbvehicles, function(vehicle)
        if vehicle.stored == 0 and vehicle.pound == nil then
            if FrameWork == 'qbx' and vehicle then
                vehicle.parking = vehicle.garage
                vehicle.vehicle = vehicle.mods
                vehicle.owner = vehicle.license
            end
            Vehicles.CreateVehicle(vehicle)
            Citizen.Wait(200)
        end
    end)
end

--- Spawn specific id
---@param callback? function
function Vehicles.SpawnVehicleId(data, callback)
    local dbvehicles = Vehicles.GetVehicleByID(data.id)

    if not dbvehicles then
        if callback then
            callback(false, false)
            return
        else
            return false, false
        end
    end

    if dbvehicles.intocar then
        dbvehicles.source = data.source
    end

    dbvehicles.coords = data.coords

    local vehicleData, vehicle = Vehicles.CreateVehicle(dbvehicles)

    if callback then
        callback(vehicleData, vehicle)
    else
        return vehicleData, vehicle
    end
end

---SaveAllVehicles
---@param delete? boolean
function Vehicles.SaveAllVehicles(delete)
    Vehicles.Save = true

    local savedCount = 0

    for entity, veh in pairs(Vehicles.Vehicles) do
        if DoesEntityExist(entity) and not veh.private then
            local coords = GetCoords(false, entity)

            local props = Vehicles.GetClientProps(veh.EntityOwner, veh.NetId)

            if not props then props = veh.vehicle end

            veh.metadata.DoorStatus = GetVehicleDoorLockStatus(entity)
            veh.metadata.coords = coords

            MySQL.update(Querys.saveAllPropsCoords, { json.encode(props), json.encode(veh.metadata), veh.plate })

            savedCount = savedCount + 1

            if delete then
                DeleteEntity(entity)
                Vehicles.Vehicles[entity] = nil
            end

            Wait(50)
        end
    end

    Utils.Debug("info", "Total vehicles saved [ %s ]", savedCount)

    Wait(500)

    Vehicles.Save = false
end

---ItemCarKeys
---@param src number
---@param action string
---@param plate string
function Vehicles.ItemCarKeys(src, action, plate)
    local metadata = { description = locale('key_string', plate), plate = plate }

    if action == 'add' then
        if Config.Inventory == 'ox' then
            local havekey = exports.ox_inventory:GetItem(src, Config.CarKeyItem, metadata, true)
            if havekey == 0 then
                exports.ox_inventory:AddItem(src, Config.CarKeyItem, 1, metadata)
            end
        elseif Config.Inventory == 'qs' then
            exports['qs-inventory']:AddItem(src, Config.CarKeyItem, 1, nil, metadata)
        end
    elseif action == 'delete' then
        if Config.Inventory == 'ox' then
            local Count = exports.ox_inventory:GetItem(src, Config.CarKeyItem, metadata, true)
            exports.ox_inventory:RemoveItem(src, Config.CarKeyItem, Count, metadata)
        elseif Config.Inventory == 'qs' then
            exports['qs-inventory']:RemoveItem(src, Config.CarKeyItem, 1, nil, metadata)
        end
    end
end

local Properties = {}

RegisterNetEvent('mVehicle:ReceiveProps', function(id, data)
    local props = json.decode(data)
    if Properties[id] then
        Properties[id](props)
        Properties[id] = nil
    end
end)

---Get Client props from server
---@param src number
---@param NetID number
---@return table
function Vehicles.GetClientProps(src, NetID)
    local entity = NetworkGetEntityFromNetworkId(NetID)

    SetEntityDistanceCullingRadius(entity, 99999.0)

    Citizen.Wait(50)

    local promise = promise.new()

    Properties[entity] = function(props)
        promise:resolve(props)
    end

    TriggerClientEvent('mVehicles:RequestProps', src, entity, NetID)

    local result = Citizen.Await(promise)

    Properties[entity] = nil

    return result
end

AddEventHandler("onResourceStart", function(Resource)
    if Resource == 'mVehicle' then
        if Config.Persistent then
            Wait(1000)
            Vehicles.SpawnVehicles()
        end
    end
end)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for k, v in pairs(Vehicles.Vehicles) do
            DeleteEntity(v.entity)

            if Config.Persistent then
                local coords = GetEntityCoords(v.entity)
                local w = GetEntityHeading(v.entity)

                v.metadata.coords = { x = coords.x, y = coords.y, z = coords.z, w = w }
                MySQL.update(Querys.saveMetadata, { json.encode(v.metadata), v.plate })
            end
        end
    end
end)


exports('PlateExist', Vehicles.PlateExist)
exports('GeneratePlate', Vehicles.GeneratePlate)
exports('ItemCarKeys', Vehicles.ItemCarKeys)
exports('GetClientProps', Vehicles.GetClientProps)

lib.callback.register('mVehicle:GiveKey', Vehicles.ItemCarKeys)

exports('vehicle', function()
    return Vehicles
end)
