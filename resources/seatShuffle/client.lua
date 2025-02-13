local PlayerSeat
local Vehicle

lib.onCache('vehicle', function(entity)
	Vehicle = entity
end)

lib.onCache('seat', function(seat)
	PlayerSeat = seat
	if Config.SeatShuffle then
		if seat == 0 then
			SetPedIntoVehicle(cache.ped, Vehicle, 0)
			SetPedConfigFlag(cache.ped, 184, true)
		else
			SetPedConfigFlag(cache.ped, 184, false)
		end
		
		while true do
			if not PlayerSeat then break end
			if IsControlPressed(0, 21) and IsControlJustPressed(0, 38) then
				if PlayerSeat == 0 or PlayerSeat == -1 then
					TaskShuffleToNextVehicleSeat(cache.ped, Vehicle)
				elseif PlayerSeat == 1 then
					TaskWarpPedIntoVehicle(cache.ped, Vehicle, 2)
				elseif PlayerSeat == 2 then
					TaskWarpPedIntoVehicle(cache.ped, Vehicle, 1)
				end
			end
			Citizen.Wait(0)
		end
	end
end)

lib.onCache('TryEnterVehicle', function(veh)
	-- Prevents a player from entering a locked vehicle
	local lock = GetVehicleDoorLockStatus(veh)
	if lock == 2 then
		ClearPedTasks(cache.ped)
		return
	end

	local PlayerPed = cache.ped
	local coords = GetEntityCoords(PlayerPed)
	local doorIndex = nil


	for i = 0, GetNumberOfVehicleDoors(veh) do
		local doorCoords = GetEntryPositionOfDoor(veh, i)
		local dist = #(coords - doorCoords)
		if (doorIndex == nil or dist < #(coords - GetEntryPositionOfDoor(veh, doorIndex))) then
			doorIndex = i
		end
	end

	if doorIndex then
		TaskEnterVehicle(PlayerPed, veh, -1, doorIndex - 1, 1.0, 1, 0)

		local startTime = GetGameTimer()

		while true do
			Citizen.Wait(0)
			local currentTime = GetGameTimer()

			if currentTime - startTime >= 3000 then
				break
			end

			if IsControlPressed(0, 32) or -- W
				IsControlPressed(0, 33) or -- S
				IsControlPressed(0, 34) or -- A
				IsControlPressed(0, 35) or -- D
				IsControlPressed(0, 22) then -- Space
				Citizen.Wait(200)
				if IsControlPressed(0, 32) or -- W
					IsControlPressed(0, 33) or -- S
					IsControlPressed(0, 34) or -- A
					IsControlPressed(0, 35) or -- D
					IsControlPressed(0, 22) then -- Space
					ClearPedTasks(PlayerPed)
				end

				break
			end
		end
	end
end)
