R = {}
R.PlayerData = {}
R.CurrentRequestId = 0
R.ServerCallbacks = {}

AddEventHandler('0r-core:getSharedObject', function(cb)
	cb(R)
end)

function getSharedObject()
	return R
end

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

R.TriggerServerCallback = function(name, cb, ...)
	R.ServerCallbacks[R.CurrentRequestId] = cb

	TriggerServerEvent('0r-core:triggerServerCallback', name, R.CurrentRequestId, ...)

	if R.CurrentRequestId < 65535 then
		R.CurrentRequestId = R.CurrentRequestId + 1
	else
		R.CurrentRequestId = 0
	end
end