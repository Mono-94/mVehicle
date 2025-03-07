--[[

Handle Resource Events
This utility function is designed to manage and intercept exported functions
from other resources in a FiveM server. It listens for events triggered by
exported functions and redirects their execution to a custom callback, allowing
developers to override or extend the behavior of existing functions from other resources.

Example Usage:
HandleFunctionResource('my_resource', 'MyExportedFunction', function(...)
    print("Intercepted MyExportedFunction:", ...)
end)

This would listen for calls to the exported function 'MyExportedFunction' from 'my_resource'
and execute the provided callback instead.

-Notes:
-- This works by attaching an event listener to the internal `__cfx_export_<resource>_<function>` event.
-- The callback should have the same parameters and expected return values as the original function.
]]

--- HandleFunctionResource
--- Registers a handler for an exported function from another resource.
--- This function listens for exported function calls and safely executes a callback,
--- ensuring that errors do not crash the script.

--- @param resourceName string The name of the resource exporting the function.
--- @param functionName string The name of the exported function.
--- @param callBack function The function that will handle calls to the exported function.
local function HandleFunctionResource(resourceName, functionName, callBack)
    AddEventHandler(('__cfx_export_%s_%s'):format(resourceName, functionName), function(...)
        local success, result = pcall(callBack, ...)
        if not success then
            print(("[ERROR] HandleFunctionResource: Failed to execute callback for %s:%s - %s"):format(resourceName,
                functionName, result))
        end
    end)
end

--------------------------------------------------------------------------------------------

if not IsDuplicityVersion() then
    if FrameWork == 'qbx' then
        -- qbx_vehiclekeys has keys Client
        HandleFunctionResource('qbx_vehiclekeys', 'HasKeys', function(entity)
            return Vehicles.HasKeyClient(entity)
        end)
    end
else
    if FrameWork == 'qbx' then
        -- qbx_vehiclekeys has keys Server
        HandleFunctionResource('qbx_vehiclekeys', 'HasKeys', function(src, entity)
            return Vehicles.HasKey(src, entity)
        end)

        -- qbx_vehiclekeys give keys? best thing to do is to give temporary access
        HandleFunctionResource('qbx_vehiclekeys', 'GiveKeys', function(src, entity)
            return Vehicles.AddTemporalVehicle(src, entity)
        end)
    end
end
