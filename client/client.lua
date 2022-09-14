R = {}
R.PlayerData = {}
R.CurrentRequestId = 0
R.ServerCallbacks = {}

if Config.Framework == "ESX" then
	ESX = exports['es_extended']:getSharedObject()
else
	QBCore = exports['qb-core']:GetCoreObject()
end

AddEventHandler('0r-core:getSharedObject', function(cb)
	cb(R)
end)

exports("Get0RCore", function()
	return R
end)

exports("GetFramework", function()
	return Config.Framework
end)

function getSharedObject()
	return R
end

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

RegisterNetEvent(Config.events["playerLoaded"][Config.Framework])
AddEventHandler(Config.events["playerLoaded"][Config.Framework], function()
   TriggerServerEvent('0r-core:onPlayerJoined')
end)

RegisterNetEvent(Config.events["updateJob"][Config.Framework])
AddEventHandler(Config.events["updateJob"][Config.Framework], function(job)
    R.PlayerData.job = job
    TriggerServerEvent("0r-core:setJob", job)
end)

RegisterNetEvent('0r-core:serverCallback')
AddEventHandler('0r-core:serverCallback', function(requestId, ...)
	R.ServerCallbacks[requestId](...)
	R.ServerCallbacks[requestId] = nil
end)

R.GetPlayerData = function()
	if Config.Framework == "ESX" then
		return ESX.GetPlayerData()
	else
		return QBCore.Functions.GetPlayerData()
	end
end


R.Menu = function()
	return ESX.UI.Menu
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
 
RegisterNetEvent("0r-core:notif")
AddEventHandler("0r-core:notif", R.Notif)
