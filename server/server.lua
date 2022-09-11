
RegisterNetEvent("0r-core:onPlayerJoined")
AddEventHandler('0r-core:onPlayerJoined', function()
    local source = source

    if not R.Players[source] then 
       info = {}
       identifier = R.GetIdentifier(source)
       query = "SELECT * FROM `users` WHERE identifier = '"..identifier.."' "
       if Config.Framework == "QBCore" then 
          query = ""
       end
       local data = {}
       if Config.Framework == "ESX" then data = R.ExecuteSql(query) end
       if #data ~= 0 then 
          info = R.xPlayer(source)
          if Config.Framework == "ESX" then 
             info["firstname"] = data[1].firstname
             info["lastname"] = data[1].lastname
          end
          R.Players[source] = info
       end
    end
    TriggerClientEvent('0r-core:onPlayerJoined', source, source)
end)


RegisterNetEvent("0r-core:playerDropped")
AddEventHandler('0r-core:playerDropped', function(source, reason)
    local source = source
    if R.Players[source] then 
       R.Players[source] = nil
    end
end)

RegisterNetEvent("0r-core:setJob")
AddEventHandler('0r-core:setJob', function(job)
    R.Players[source].job = job
end)

RegisterCommand("komut", function(source, args)
   
   print(R.xPlayer(source).Name())
end)


AddEventHandler('playerDropped', function(reason)
	local source = source
	TriggerEvent('0r-core:playerDropped', source, reason)
  TriggerClientEvent('0r-core:playerDropped', source, source, reason)
end)



R.PrimaryIdentifier = function(source)
    local identifier = Config.PrimaryIdentifier..':'
    for _, v in pairs(GetPlayerIdentifiers(source)) do
        if string.match(v, identifier) then
            identifier = string.gsub(v, identifier, '')
            return identifier
        end
    end
end

R.xPlayer = function(source)
  
  local source = source
 
  if Config.Framework == "ESX" then 
	   rPlayer = ESX.GetPlayerFromId(source)
  elseif Config.Framework == "QBCore" then 
	   rPlayer = QBCore.Functions.GetPlayer(source)
  end
 
  rPlayer = R.RemapPlayer(rPlayer)
  
  return rPlayer
end

R.GetIdentifier = function(source)
  if Config.Framework == "ESX" then 
    return ESX.GetPlayerFromId(source).identifier
  elseif Config.Framework == "QBCore" then 
    return QBCore.Functions.GetPlayer(source).PlayerData.citizenid
  else 
    return R.PrimaryIdentifier(source)
  end
end
 

R.RemapPlayer = function(xPlayer)
   local self = {}
   
   self.GetAccountData = function(account)
      if Config.Framework == "ESX" then 
         return xPlayer.getAccount(account)
      else 
         return xPlayer.PlayerData.money[account]
      end
   end

   self.GiveAccountMoney = function(account, money)
      if Config.Framework == "ESX" then 
         xPlayer.addAccountMoney(account, money)
      else 
         xPlayer.Functions.AddMoney(account, money)
      end
   end

   self.JobData = function()
      if Config.Framework == "ESX" then 
          return xPlayer.getJob()
      else 
         return xPlayer.PlayerData.job
      end
   end

   self.GiveJob = function(name, grade)
      if Config.Framework == "ESX" then 
          xPlayer.setJob(name, grade)
      else 
         xPlayer.Functions.SetJob(name, grade)
      end
   end

   self.GetItem = function(item)
      if Config.Framework == "ESX" then 
          return xPlayer.getInventoryItem(item)
      else 
         return xPlayer.Functions.GetItemByName()
      end  
   end

   self.Notif = function(type, text, icon)
      if Config.Framework == "ESX" then
         TriggerClientEvent("0r-core:notif", xPlayer.source, { type = type or "success", text = text, icon = icon or "💬" })
      else
         TriggerClientEvent("0r-core:notif", xPlayer.PlayerData.source, { type = type or "success", text = text, icon = icon or "💬" })
      end
   end
 
   return R.MergeTable(self, xPlayer)
end

R.MergeTable = function(t1, t2)
  for k, v in pairs(t2) do
      if (type(v) == "table") and (type(t1[k] or false) == "table") then
          R.MergeTable(t1[k], t2[k])
      else
          t1[k] = v
      end
  end
  return t1
end

R.RegisterServerCallback = function(name, cb)
	R.ServerCallbacks[name] = cb
end

R.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if R.ServerCallbacks[name] then
		R.ServerCallbacks[name](source, cb, ...)
	else
		print(('[^3WARNING^7] Server callback ^5"%s"^0 does not exist. ^1Please Check The Server File for Errors!'):format(name))
	end
end

RegisterServerEvent('0r-core:triggerServerCallback')
AddEventHandler('0r-core:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	R.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('0r-core:serverCallback', playerId, requestId, ...)
	end, ...)
end)


