--- Set Engine Sound
---@param entity number | integer
---@param soundName string | integer
function Vehicles.SetEnGineSound(entity, soundName)
    if not DoesEntityExist(entity) then return end
    TriggerServerEvent('mVehicle:SetEngineSound', VehToNet(entity), soundName)
end


AddStateBagChangeHandler('engineSound', nil, function(bagName, key, value)
    if not value then return end
    local entity = GetEntityFromStateBagName(bagName)

    ForceUseAudioGameObject(entity, value)

    Entity(entity).state:set('engineSound', nil, true)
end)


exports('SetEngineSound', Vehicles.SetEnGineSound)
