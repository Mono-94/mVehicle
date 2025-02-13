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

exports('ItemCarKeysClient', Vehicles.ItemCarKeysClient)


local ToggleVehicleDoors = function()
    local data = {}
    local ped = cache.ped

    data.entity = lib.getClosestVehicle(GetEntityCoords(ped), Config.KeyDistance, true)

    if not DoesEntityExist(data.entity) then return end

    data.modelName = Vehicles.GetVehicleLabel(GetEntityModel(data.entity))
    data.Status = GetVehicleDoorLockStatus(data.entity)
    data.NetId = VehToNet(data.entity)
    data.plate = GetVehicleNumberPlateText(data.entity)

    local HaveKey = Utils.KeyItem(data.plate)
    local inCar = IsPedInAnyVehicle(ped, false)

    if data.entity and HaveKey or not Config.ItemKeys then
        local owner = lib.callback.await('mVehicle:VehicleDoors', Config.KeyDelay, data)

        if not owner then return end

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