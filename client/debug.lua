local RadiusVehicleCoordsAwaitingClient = {}

RegisterNetEvent('mvehicle:persistent:area:debug', function(id, coords, dist, action, bucket)
    if action == 'add' then
        if RadiusVehicleCoordsAwaitingClient[id] then return end
        RadiusVehicleCoordsAwaitingClient[id] = {}
        RadiusVehicleCoordsAwaitingClient[id].radius = AddBlipForRadius(coords.x, coords.y, coords.z, dist)
        SetBlipAlpha(RadiusVehicleCoordsAwaitingClient[id].radius, 50)
        SetBlipColour(RadiusVehicleCoordsAwaitingClient[id].radius, bucket == 0 and 11 or 14)
        RadiusVehicleCoordsAwaitingClient[id].blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(RadiusVehicleCoordsAwaitingClient[id].blip, 11)
        SetBlipDisplay(RadiusVehicleCoordsAwaitingClient[id].blip, 4)
        SetBlipScale(RadiusVehicleCoordsAwaitingClient[id].blip, 1.0)
        SetBlipColour(RadiusVehicleCoordsAwaitingClient[id].blip, bucket == 0 and 11 or 14)
        SetBlipAsShortRange(RadiusVehicleCoordsAwaitingClient[id].blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(('Vehicle ID [ %s ] | Bucket [ %s ] - Awaiting client in Scope'):format(id, bucket))
        EndTextCommandSetBlipName(RadiusVehicleCoordsAwaitingClient[id].blip)
    else
        if RadiusVehicleCoordsAwaitingClient[id] then
            RemoveBlip(RadiusVehicleCoordsAwaitingClient[id].blip)
            RemoveBlip(RadiusVehicleCoordsAwaitingClient[id].radius)
            RadiusVehicleCoordsAwaitingClient[id] = nil
        end
    end
end)

if not Config.Debug then return end

local EngineSound = {

    --- Vehicle engine sounds from https://www.gta5-mods.com/vehicles/brabus-inspired-custom-engine-sound-add-on-sound
    --- only for debugging

    Engines = {
        { value = 'brabus850',  label = 'Brabus 850 6.0L V8-TT v1.3 (brabus850)' },
        { value = 'toysupmk4',  label = 'Toyota 2JZ-GTE 3.0L I6-T v1.3 (toysupmk4)' },
        { value = 'lambov10',   label = 'Audi/Lamborghini 5.2L V10 v1.0 (lambov10)' },
        { value = 'rb26dett',   label = 'Nissan RB26DETT 2.6L I6-TT v1.2 (rb26dett)' },
        { value = 'rotary7',    label = 'Mazda 13B-REW 1.3L Twin-Rotor v1.0 (rotary7)' },
        { value = 'musv8',      label = 'Dragster Twin-Charged V8SCT v1.0 (musv8)' },
        { value = 'm297zonda',  label = 'Pagani-AMG M297 7.3L V12 v1.0 (m297zonda)' },
        { value = 'm158huayra', label = 'Pagani-AMG M158 6.0L V12TT v1.0 (m158huayra)' },
        { value = 'k20a',       label = 'Honda K20A 2.0L I4 v1.0 (k20a)' },
        { value = 'gt3flat6',   label = 'Porsche RS 4.0L Flat-6 v1.0 (gt3flat6)' },
        { value = 'predatorv8', label = 'Ford-Shelby Predator 5.2L V8SC v1.0 (predatorv8)' }
    },

}


exports.ox_target:addGlobalVehicle({
    {
        distance = 10.0,
        label = 'Vehicle type',
        onSelect = function(data)
            print(GetVehicleType(data.entity))
        end
    },
    {
        distance = 10.0,
        label = 'Change Sound',
        onSelect = function(data)
            local input = lib.inputDialog('Vehicle Sound', {
                { type = 'select', label = 'Select sound', options = EngineSound.Engines }
            })

            if not input then return end

            Vehicles.SetEnGineSound(data.entity, input[1])
        end
    },
    {
        distance = 10.0,
        label = 'Toggle Doords',
        onSelect = function(data)
            TriggerServerEvent('mVehicle:VehicleDoors', VehToNet(data.entity))
        end
    },
    {
        distance = 4,
        label = 'Set on Ground',
        icon = 'fa-solid fa-car',
        onSelect = function(data)
            local carCoords = GetEntityRotation(data.entity, 2)
            SetEntityRotation(data.entity, carCoords[1], 0, carCoords[3], 2, true)
            SetVehicleOnGroundProperly(data.entity)
        end
    },
    {
        distance = 10.0,
        label = 'Vehicle data',
        onSelect = function(data)
            local VehicleState = Entity(data.entity).state
            if VehicleState then
                if VehicleState.id then
                    print(("ID: %s"):format(VehicleState.id))
                end
                print(("Type: %s"):format(VehicleState.type))
                print(("Plate: %s"):format(VehicleState.plate))
                print(("Fuel Level: %s"):format(VehicleState.fuel))
                if VehicleState.mileage then
                    print(("Mileage: %s"):format(VehicleState.mileage))
                end

                if VehicleState.owner then
                    print(("Owner: %s"):format(VehicleState.owner))
                end

                if VehicleState.job then
                    print(("Job: %s"):format(VehicleState.job))
                end

                if VehicleState.metadata then
                    print(("Metadata: %s"):format(json.encode(VehicleState.metadata, { indent = true })))
                end
            end
        end
    },
})
