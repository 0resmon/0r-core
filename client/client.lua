R = {}
R.PlayerData = {}
R.CurrentRequestId = 0
R.ServerCallbacks = {}

if GetResourceState(Config.CoreName["ESX"]) ~= 'missing' then
    Config.Framework = 'ESX'
    ESX = exports[Config.CoreName["ESX"]].getSharedObject()
    if Config.OldFramework then
        ESX = nil
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
        end)
    end
end

exports("Get0RCore", function()
	return R
end)

if GetResourceState(Config.CoreName["QBCore"]) ~= 'missing' then
    Config.Framework = 'QBCore'
    QBCore = exports[Config.CoreName['QBCore']]:GetCoreObject()
end

AddEventHandler('0r-core:getSharedObject', function(cb)
	cb(R)
end)

exports("GetFramework", function()
	return Config.Framework
end)

RegisterNetEvent('qb-spawn:client:openUI', function()
	TriggerServerEvent('0r-core:onPlayerJoined')
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	TriggerServerEvent('0r-core:onPlayerJoined')
end)

RegisterNetEvent("0r-core:setPlayerData")
AddEventHandler("0r-core:setPlayerData", function(PlayerData)
    R.PlayerData = PlayerData
end)

RegisterNetEvent('0r-core:serverCallback')
AddEventHandler('0r-core:serverCallback', function(requestId, ...)
	R.ServerCallbacks[requestId](...)
	R.ServerCallbacks[requestId] = nil
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    R.PlayerData.job = JobInfo
end)

RegisterNetEvent('esx:setJob', function(JobInfo)
    R.PlayerData.job = JobInfo
end)

R.GetPlayerData = function()
    local pData = {}
	if Config.Framework == "ESX" then
		pData = ESX.GetPlayerData()
	else
		pData = QBCore.Functions.GetPlayerData()
        pData.identifier = pData.citizenid 
	end
    return pData
end

R.GetVehicleInDirection = function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local inDirection = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(playerCoords, inDirection, 10, playerPed, 0)
    local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    if hit == 1 and GetEntityType(entityHit) == 2 then
        local entityCoords = GetEntityCoords(entityHit)
        return entityHit, entityCoords
    end

    return nil
end

R.GetPlayerMoney = function(type)
    local Money = 0
    if Config.Framework == 'ESX' then
        if type == 'cash' then type = 'money' end
        local PlayerData = ESX.GetPlayerData()
        for k,v in pairs(PlayerData.accounts) do
            if v.name == type then
                Money = v.money
            end
        end
    else
        local PlayerData = QBCore.Functions.GetPlayerData()
        Money = PlayerData.money[type]
    end

    return Money
end

R.GetVehicles = function() -- Leave the function for compatibility
    return GetGamePool('CVehicle')
end

R.GetVehiclesInArea = function(coords, maxDistance)
    return R.EnumerateEntitiesWithinDistance(R.GetVehicles(), false, coords, maxDistance)
end

R.EnumerateEntitiesWithinDistance = function(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = ESX.PlayerData.ped
        coords = GetEntityCoords(playerPed)
    end

    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end

    return nearbyEntities
end

R.DrawText3D = function(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 245)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 410
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 133)
end

R.GetIdentifier = function()
    if Config.Framework == "ESX" then
        return ESX.GetPlayerData().identifier
    else
        return QBCore.Functions.GetPlayerData().citizenid
    end
end

R.TriggerServerCallback = function(name, cb, ...)
	R.ServerCallbacks[R.CurrentRequestId] = cb

	TriggerServerEvent('0r-core:triggerServerCallback', name, R.CurrentRequestId, ...)

	if R.CurrentRequestId < 65535 then
		R.CurrentRequestId = R.CurrentRequestId + 1
	else
		R.CurrentRequestId = 0
	end
end

R.DrawText2D = function(msg, thisFrame, beep, duration)
	AddTextEntry('esxHelpNotification', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('esxHelpNotification', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('esxHelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end

R.NotifPos = function(pos) 
	SendNUIMessage({ action = "showNotify", data = { type = "setDefaultPos", pos = pos }  })
end

R.Notif = function(data)
	SendNUIMessage({action = "showNotify", data = data })
end

R.Notification = function(NotifyType, Message, Length)
    if not Length then Length = 3000 end
    if Config.Framework == 'ESX' then
        ESX.ShowNotification(NotifyType, Length, Message)
    else
        QBCore.Functions.Notify(Message, NotifyType, Length)
    end
end

RegisterNetEvent('0R:Core:Notify', R.Notification)

R.GetClosestPlayer = function(coords)
    local ped = PlayerPedId()
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    local closestPlayers = R.GetPlayersFromCoords(coords)
    local closestDistance = -1
    local closestPlayer = -1
    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() and closestPlayers[i] ~= -1 then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

R.GetPlayersFromCoords = function(coords, distance)
    local players = GetActivePlayers()
    local ped = PlayerPedId()
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    distance = distance or 5
    local closePlayers = {}
    for _, player in pairs(players) do
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = #(targetCoords - coords)
        if targetdistance <= distance then
            closePlayers[#closePlayers + 1] = player
        end
    end
    return closePlayers
end

R.DumpTable = function(table, nb)
	if nb == nil then
		nb = 0
	end
	if type(table) == 'table' then
		local s = ''
		for i = 1, nb + 1, 1 do
			s = s .. "    "
		end
		s = '{\n'
		for k,v in pairs(table) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			for i = 1, nb, 1 do
				s = s .. "    "
			end
			s = s .. '['..k..'] = ' .. R.DumpTable(v, nb + 1) .. ',\n'
		end
		for i = 1, nb, 1 do
			s = s .. "    "
		end
		return s .. '}'
	else
		return tostring(table)
	end
end

function R.GetPlate(vehicle)
    if vehicle == 0 then return end
    return R.Trim(GetVehicleNumberPlateText(vehicle))
end

function R.Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function R.Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

R.GetVehicleProperties = function(vehicle)
    if DoesEntityExist(vehicle) then
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        if GetIsVehiclePrimaryColourCustom(vehicle) then
            local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
            colorPrimary = {r, g, b}
        end

        if GetIsVehicleSecondaryColourCustom(vehicle) then
            local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
            colorSecondary = {r, g, b}
        end

        local extras = {}
        for extraId = 0, 12 do
            if DoesExtraExist(vehicle, extraId) then
                local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
                extras[tostring(extraId)] = state
            end
        end

        local modLivery = GetVehicleMod(vehicle, 48)
        if GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) ~= 0 then
            modLivery = GetVehicleLivery(vehicle)
        end

        local tireHealth = {}
        for i = 0, 3 do
            tireHealth[i] = GetVehicleWheelHealth(vehicle, i)
        end

        local tireBurstState = {}
        for i = 0, 5 do
           tireBurstState[i] = IsVehicleTyreBurst(vehicle, i, false)
        end

        local tireBurstCompletely = {}
        for i = 0, 5 do
            tireBurstCompletely[i] = IsVehicleTyreBurst(vehicle, i, true)
        end

        local windowStatus = {}
        for i = 0, 7 do
            windowStatus[i] = IsVehicleWindowIntact(vehicle, i) == 1
        end

        local doorStatus = {}
        for i = 0, 5 do
            doorStatus[i] = IsVehicleDoorDamaged(vehicle, i) == 1
        end

        return {
            model = GetEntityModel(vehicle),
            plate = R.GetPlate(vehicle),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
            bodyHealth = R.Round(GetVehicleBodyHealth(vehicle), 0.1),
            engineHealth = R.Round(GetVehicleEngineHealth(vehicle), 0.1),
            tankHealth = R.Round(GetVehiclePetrolTankHealth(vehicle), 0.1),
            fuelLevel = R.Round(GetVehicleFuelLevel(vehicle), 0.1),
            dirtLevel = R.Round(GetVehicleDirtLevel(vehicle), 0.1),
            oilLevel = R.Round(GetVehicleOilLevel(vehicle), 0.1),
            color1 = colorPrimary,
            color2 = colorSecondary,
            pearlescentColor = pearlescentColor,
            dashboardColor = GetVehicleDashboardColour(vehicle),
            wheelColor = wheelColor,
            wheels = GetVehicleWheelType(vehicle),
            wheelSize = GetVehicleWheelSize(vehicle),
            wheelWidth = GetVehicleWheelWidth(vehicle),
            tireHealth = tireHealth,
            tireBurstState = tireBurstState,
            tireBurstCompletely = tireBurstCompletely,
            windowTint = GetVehicleWindowTint(vehicle),
            windowStatus = windowStatus,
            doorStatus = doorStatus,
            xenonColor = GetVehicleXenonLightsColour(vehicle),
            neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0),
                IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },
            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            headlightColor = GetVehicleHeadlightsColour(vehicle),
            interiorColor = GetVehicleInteriorColour(vehicle),
            extras = extras,
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
            modKit17 = GetVehicleMod(vehicle, 17),
            modTurbo = IsToggleModOn(vehicle, 18),
            modKit19 = GetVehicleMod(vehicle, 19),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modKit21 = GetVehicleMod(vehicle, 21),
            modXenon = IsToggleModOn(vehicle, 22),
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modCustomTiresF = GetVehicleModVariation(vehicle, 23),
            modCustomTiresR = GetVehicleModVariation(vehicle, 24),
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modKit47 = GetVehicleMod(vehicle, 47),
            modLivery = modLivery,
            modKit49 = GetVehicleMod(vehicle, 49),
            liveryRoof = GetVehicleRoofLivery(vehicle),
        }
    else
        return
    end
end

R.SetVehicleProperties = function(vehicle, props)
    	if Config.Framework == 'ESX' then
		ESX.Game.SetVehicleProperties(vehicle, props)
	else
		QBCore.Functions.SetVehicleProperties(vehicle, props)
	end
end
 
RegisterNetEvent("0r-core:notif")
AddEventHandler("0r-core:notif", R.Notif)
