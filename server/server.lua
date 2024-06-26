
RegisterNetEvent("0r-core:onPlayerJoined")
AddEventHandler('0r-core:onPlayerJoined', function()
    local source = source

    if not R.Players[source] then 
       info = {}
       identifier = R.GetIdentifier(source)
       if not identifier then return end
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
             info["phone"] = nil
          else
               info["firstname"] = info.PlayerData.charinfo.firstname
               info["lastname"] = info.PlayerData.charinfo.lastname
               info["phone"] = info.PlayerData.charinfo.phone
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

R.GetByIdentifier = function(identifier)
   if Config.Framework == "QBCore" then
      zPlayer = QBCore.Functions.GetPlayerByCitizenId(identifier)
      if not zPlayer then return end
      zPlayer.identifier = zPlayer.PlayerData.citizenid
      zPlayer.source = zPlayer.PlayerData.source
   else
      zPlayer = ESX.GetPlayerFromIdentifier(identifier)
   end
   zPlayer = R.RemapPlayer(zPlayer)
   return zPlayer
end

R.GetByIdentifierV2 = function(identifier)
   local zPlayer = {}

   if Config.Framework == "QBCore" then
      zPlayer = QBCore.Functions.GetPlayerByCitizenId(identifier)
      if not zPlayer then return end
      zPlayer.identifier = zPlayer.PlayerData.citizenid
      zPlayer.source = zPlayer.PlayerData.source
   else
      zPlayer = ESX.GetPlayerFromIdentifier(identifier).source
   end

   zPlayer = R.RemapPlayer(zPlayer)
   return zPlayer
end

R.xPlayer = function(source)
   local source = source
   if Config.Framework == "ESX" then 
      rPlayer = ESX.GetPlayerFromId(source)
      if not rPlayer then return end
      rPlayer.job_grade_level = rPlayer.job.grade
      rPlayer.name = rPlayer.getName()
   elseif Config.Framework == "QBCore" then 
      rPlayer = QBCore.Functions.GetPlayer(source)
      if not rPlayer then return end
      rPlayer.identifier = rPlayer.PlayerData.citizenid
      rPlayer.job_grade_level = rPlayer.PlayerData.job.grade.level
      rPlayer.source = rPlayer.PlayerData.source
      rPlayer.job_grade_name = rPlayer.PlayerData.job.grade.name
      rPlayer.job = rPlayer.PlayerData.job.name 
      rPlayer.name = rPlayer.PlayerData.charinfo.firstname..' '..rPlayer.PlayerData.charinfo.lastname
   end

   rPlayer = R.RemapPlayer(rPlayer)
   return rPlayer
end

R.UsableItem = function(item, cb)
   if Config.Framework == "ESX" then
      return ESX.RegisterUsableItem(item, cb)
   else
      return QBCore.Functions.CreateUseableItem(item, cb)
   end
end

R.GetItemBySlot = function(source, slot)
   if Config.Framework == "QBCore" then
      local Player = QBCore.Functions.GetPlayer(source)
      slot = tonumber(slot)
      return Player.PlayerData.items[slot]
   else
      local Player = ESX.GetPlayerFromId(source)
      slot = tonumber(slot)
      return Player.items[slot]
   end
end

R.GetIdentifier = function(source)
   if Config.Framework == "ESX" then 
      local player = ESX.GetPlayerFromId(source)
      if not player then return end
      return player.identifier
   elseif Config.Framework == "QBCore" then 
      return QBCore.Functions.GetPlayer(source).PlayerData.citizenid
   else 
      return R.PrimaryIdentifier(source)
   end
end

R.GetPlayers = function()
	local sources = {}
	for k,v in pairs(R.Players) do
		sources[#sources + 1] = k
	end
	return sources
end

R.GetAllPlayers = function()
	if Config.Framework == 'ESX' then
      return ESX.GetPlayers()
   else
      return QBCore.Functions.GetPlayers()
   end
end

R.RemapPlayer = function(xPlayer)
   local self = {}
   
   self.GetAccountData = function(account)
      if Config.Framework == "ESX" then 
         if account == "cash" then account = "money" end
         return xPlayer.getAccount(account).money
      else 
         return xPlayer.PlayerData.money[account]
      end
   end

   self.GetProfile = function(xx)
      if Config.Framework == "ESX" then 
         query = "SELECT * FROM `users` WHERE identifier = '"..xPlayer.identifier.."' "
         result = R.ExecuteSql(query)
         if xx == "name" then return result[1].firstname..' '..result[1].lastname else return nil end
      else 
         if xx == "name" then return xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname else return xPlayer.PlayerData.charinfo.phone end
      end
   end

   self.AddItem = function(item, amount, slot, metadata)
      if Config.Framework == "ESX" then 
         return xPlayer.addInventoryItem(item, amount, slot, metadata)
      else 
         return xPlayer.Functions.AddItem(item, amount, slot, metadata)
      end
   end

   self.RemoveItem = function(item, amount, slot, metadata)
      if Config.Framework == "ESX" then 
         return xPlayer.removeInventoryItem(item, amount, slot, metadata)
      else 
         return xPlayer.Functions.RemoveItem(item, amount, slot, metadata)
      end
   end

   self.GiveAccountMoney = function(account, money)
      if Config.Framework == "ESX" then 
         if account == "cash" then account = "money" end
         xPlayer.addAccountMoney(account, money)
      else 
         xPlayer.Functions.AddMoney(account, money)
      end
   end

   self.RemoveMoney = function(account, money)
      if Config.Framework == "ESX" then 
         if account == "cash" then account = "money" end
         return xPlayer.removeAccountMoney(account, money)
      else 
         return xPlayer.Functions.RemoveMoney(account, money)
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
         x = xPlayer.Functions.GetItemByName(item)
         if x ~= nil then
            x.count = x.amount
         end
         return x
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

R.GetFramework = function()
   return Config.Framework
end

R.CheckPerm = function(source, perm)
   local auth = false
   if Config.Framework == 'QBCore' then
      if QBCore.Functions.HasPermission(source, perm) then
         auth = true
      end
   else
      local xPlayer = ESX.GetPlayerFromId(source)
      if xPlayer.getGroup() == perm then
         auth = true
      end
   end

   return auth
end

R.MergeTable = function(t1, t2)
   if not t2 then return end
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


