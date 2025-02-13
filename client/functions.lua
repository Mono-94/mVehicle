Vehicles = {}
Vehicles.Config = Config

--Vehicle Label
function Vehicles.GetVehicleLabel(model)
    if not IsModelValid(model) then
        lib.print.warn(model .. ' - Model invalid')
        return 'Unknown'
    end

    local makeName = GetMakeNameFromVehicleModel(model)

    if not makeName then
        lib.print.warn(model .. ' - No Make Name')
        return 'Unknown'
    end

    makeName = makeName:sub(1, 1):upper() .. makeName:sub(2):lower()

    local displayName = GetDisplayNameFromVehicleModel(model)

    displayName = displayName:sub(1, 1):upper() .. displayName:sub(2):lower()
    return makeName .. ' ' .. displayName
end

--Exports

exports('vehicle', function()
    return Vehicles
end)
