local KeyAnim <const> = {
    dict = "anim@mp_player_intmenu@key_fob@",
    anim = "fob_click_fp",
    PropKey = "p_car_keys_01"
}

--- Give Car Keys (client)
---@param action  string
---@param plate string
function Vehicles.ItemCarKeysClient(action, plate)
    return lib.callback.await('mVehicle:GiveKey', false, action, plate)
end

function Vehicles.HasKeyClient(entity)
    if not DoesEntityExist(entity) then return false end
    if Config.ItemKeys then
        local havekey = false
        local plate = GetVehicleNumberPlateText(entity):gsub("%s+", "")
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
    else
        return lib.callback.await('mVehicle:HasKeys', Config.KeyDelay, VehToNet(entity))
    end
end

local ToggleVehicleDoors = function()
    local data = {}
    local ped = cache.ped

    data.entity = lib.getClosestVehicle(GetEntityCoords(ped), Config.KeyDistance, true)

    if not DoesEntityExist(data.entity) then return end

    data.Status = GetVehicleDoorLockStatus(data.entity)

    local HaveKey = Vehicles.HasKeyClient(data.entity)

    local inCar = IsPedInAnyVehicle(ped, false)

    if HaveKey then
        TriggerServerEvent('mVehicle:VehicleDoors', VehToNet(data.entity))

        Utils.Notification({
            title = Vehicles.GetVehicleLabel(GetEntityModel(data.entity)),
            description = (data.Status == 2 and locale('open_door') or locale('close_door')),
            icon = (data.Status == 2 and 'lock-open' or 'lock'),
            iconColor = (data.Status == 2 and '#77e362' or '#e36462'),
        })

        PlayVehicleDoorCloseSound(data.entity, 1)

        local soundEvent = data.Status == 2 and "Remote_Control_Close" or "Remote_Control_Fob"

        PlaySoundFromEntity(-1, soundEvent, data.entity, "PI_Menu_Sounds", 1, 0)

        if not inCar then
            local pedbone = GetPedBoneIndex(ped, 57005)

            lib.requestModel(KeyAnim.PropKey)

            local prop = CreateObject(KeyAnim.PropKey, 1.0, 1.0, 1.0, true, true, 0)

            AttachEntityToEntity(prop, ped, pedbone, 0.08, 0.039, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

            TaskPlayAnim(ped, KeyAnim.dict, KeyAnim.anim, 8.0, 8.0, -1, 48, 0, false, false, false)

            Citizen.Wait(1000)

            DeleteObject(prop)
        end
    end
end


lib.addKeybind({
    name = 'Vehicle_doors_control',
    description = 'Carkeys',
    defaultKey = Config.DoorKeyBind,
    onPressed = ToggleVehicleDoors,
})



lib.requestAnimDict(KeyAnim.dict)


exports('ItemCarKeysClient', Vehicles.ItemCarKeysClient)
exports('HasKeyClient', Vehicles.HasKeyClient)
