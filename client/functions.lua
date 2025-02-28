Vehicles = {}
Vehicles.Config = Config

--Vehicle Label
function Vehicles.GetVehicleLabel(model)
    if type(model) == 'string' then
        model = model:match("^%s*(.-)%s*$")
        model = model:gsub("%s+", " ")
        model = GetHashKey(model)
    end

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

function Vehicles.AddTemporalVehicleClient(entity)
    return lib.callback.await('mVehicle:ControlTemporal', 1000, VehToNet(entity))
end



--Exports

exports('vehicle', function()
    return Vehicles
end)
