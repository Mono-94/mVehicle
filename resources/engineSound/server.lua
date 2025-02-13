-- Set Engine Sound
RegisterServerEvent('mVehicle:SetEngineSound', function(NetworkId, soundName)
    local entity = NetworkGetEntityFromNetworkId(NetworkId)
    local vehicle = Vehicles.GetVehicle(entity)

    if vehicle then
        vehicle.SetEngineSound(soundName)
    else
        Entity(entity).state:set('engineSound', soundName)
    end
end)
