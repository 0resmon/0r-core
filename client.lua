R = {}
R.PlayerData = {}

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
