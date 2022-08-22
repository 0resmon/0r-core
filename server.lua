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
       local data = R.ExecuteSql(query)
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
   print(R.xPlayer(source).identifier)
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
  if Config.Framework == "ESX" then 
    return ESX.GetPlayerFromId(source)
  elseif Config.Framework == "QBCore" then 
    return QBCore.Functions.GetPlayers(source)
  end
end

R.GetIdentifier = function(source)
  if Config.Framework == "ESX" then 
    return R.xPlayer(source).identifier
  elseif Config.Framework == "QBCore" then 
    return R.xPlayer(source).PlayerData.citizenid
  else 
    return R.PrimaryIdentifier(source)
  end
end
