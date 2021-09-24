ESX = nil
local isLoggedIn = false

Citizen.CreateThread(function()
	while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Citizen.Wait(500) end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent("dz-admin:client:openMenu")
AddEventHandler("dz-admin:client:openMenu", function()
    if isLoggedIn then
        SendNUIMessage { mode = "toggle", players = FetchPlayers() }
        SetNuiFocus(true, true)
    end
end)

RegisterNetEvent("dz-admin:client:updatePlayers")
AddEventHandler("dz-admin:client:updatePlayers", function()
    if isLoggedIn then
		SendNUIMessage { mode = "playerUpdate", players = FetchPlayers() }
    end
end)

RegisterNetEvent("dz-admin:client:goto")
AddEventHandler("dz-admin:client:goto", function(Target)
    local Ped = PlayerPedId()
    local Target = GetPlayerPed(GetPlayerFromServerId(Target))
    local Position = GetEntityCoords(Ped, true)
    SetEntityCoords(Ped, GetEntityCoords(Target))
end)

RegisterNetEvent("dz-admin:client:bring")
AddEventHandler("dz-admin:client:bring", function(Position)
    local Ped = PlayerPedId()
	SetEntityCoords(Ped, Position["x"], Position["y"], Position["z"])
end)

local freeze = false
RegisterNetEvent("dz-admin:client:freeze")
AddEventHandler("dz-admin:client:freeze", function()
    local Ped = PlayerPedId()
    freeze = not freeze
    if freeze then FreezeEntityPosition(Ped, true) else FreezeEntityPosition(Ped, false) end
end)

local noclip = false
RegisterNetEvent("dz-admin:client:noclip")
AddEventHandler("dz-admin:client:noclip", function()
    noclip = not noclip
    if noclip then
        print("trigger not noclip")
        SetAllCollition(false)
    else
        print("trigger noclip")
        SetAllCollition(true)
    end
end)

RegisterNetEvent("dz-admin:client:slay")
AddEventHandler("dz-admin:client:slay", function()
    local Ped = PlayerPedId()
    SetEntityHealth(Ped, 0)
end)

RegisterNetEvent("dz-admin:client:revive")
AddEventHandler("dz-admin:client:revive", function()
    local Ped = PlayerPedId()
    local Position = GetEntityCoords(Ped, true)
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do Citizen.Wait(0) end
	SetEntityCoordsNoOffset(Ped, Position, false, false, false, true)
	NetworkResurrectLocalPlayer(Position, 0, true, false)
	SetPlayerInvincible(Ped, false)
    TriggerEvent('playerSpawned', Position, 0)
	ClearPedBloodDamage(Ped)
    DoScreenFadeIn(800)
end)

RegisterNetEvent("dz-admin:client:kickAll")
AddEventHandler("dz-admin:client:kickAll", function()
    TriggerServerEvent("dz-admin:server:kickAll")
end)


-- Noclip credits: https://github.com/TanguyOrtegat/es_admin2
local gtimer = GetGameTimer()
local speed = 10
Citizen.CreateThread(function()
    local time = 500
	while true do
		if noclip then
            time = 1
			local multiplier = GetGameTimer() - gtimer
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			local camRot = GetGameplayCamRot(0)
			local camHeading = map(camRot.z, -180.0, 180.0, 0.0, 360.0)
			local ax, ay = math.sin(math.rad(camHeading)), -math.cos(math.rad(camHeading))
			local newX, newY, newZ = pos.x, pos.y, pos.z
			if IsControlJustPressed(2, 174) then speed = speed - 2 end
			if IsControlJustPressed(2, 175) then speed = speed + 2 end
			if speed < 1 then speed = 1 end 
			if IsControlPressed(2, 87) then newX, newY = newX + ax*(multiplier*(speed/100)), newY + ay*(multiplier*(speed/100)) end
			if IsControlPressed(2, 88) then newX, newY = newX - ax*(multiplier*(speed/100)), newY - ay*(multiplier*(speed/100)) end
			if IsControlPressed(2, 172) then newZ = newZ + multiplier*(speed/100) end
			if IsControlPressed(2, 173) then newZ = newZ - multiplier*(speed/100) end
			if IsControlPressed(2, 89) then
				local newcamHeading = (camHeading + 90) % 360
				ax, ay = math.sin(math.rad(newcamHeading)), -math.cos(math.rad(newcamHeading))
				newX, newY = newX + ax*(multiplier*(speed/100)), newY + ay*(multiplier*(speed/100))
			end
			if IsControlPressed(2, 90) then
				local newcamHeading = (camHeading - 90) % 360
				ax, ay = math.sin(math.rad(newcamHeading)), -math.cos(math.rad(newcamHeading))
				newX, newY = newX + ax*(multiplier*(speed/100)), newY + ay*(multiplier*(speed/100))
			end
			SetAllCollition(false)
			SetAllCoordsNoOffset(newX, newY, newZ, ax, ay, 0.0)
			gtimer = GetGameTimer()
		end
        Citizen.Wait(time)
	end
end)

function map(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function SetAllCoordsNoOffset(x, y, z, zx, zy, zz)
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped, false) then
		local veh = GetVehiclePedIsUsing(ped)
		SetEntityCoordsNoOffset(veh, x, y, z, zx, zy, zz)
	else
		SetEntityCoordsNoOffset(ped, x, y, z, zx, zy, zz)
	end
end

function SetAllCollition(mode)
	local ped = PlayerPedId()
	SetEntityCollision(ped, mode, true)
	if IsPedInAnyVehicle(ped, false) then
		local veh = GetVehiclePedIsUsing(ped)
		SetEntityCollision(veh, mode, true)
	end
end