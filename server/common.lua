R = {}
R.Players = {}
R.ServerCallbacks = {}

exports("Get0RCore", function()
	return R
end)

AddEventHandler('0r-core:getSharedObject', function(cb)
	cb(R)
end)

function getSharedObject()
	return R
end

if Config.Framework == "ESX" then 
   ESX = nil
   TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.Framework == "QBCore" then 
   QBCore = exports['qb-core']:GetCoreObject()
end

R.ExecuteSql = function(query)
    local IsBusy = true
    local result = nil
    if Config.Mysql == "oxmysql" then
        if MySQL == nil then
            exports.oxmysql:execute(query, function(data)
                result = data
                IsBusy = false
            end)
        else
            MySQL.query(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.Mysql == "mysql-async" then
        MySQL.Async.fetchAll(query, {}, function(data)
            result = data
            IsBusy = false
        end)
    elseif Config.Mysql == "ghmattimysql" then
        exports.ghmattimysql:execute(query, function (data)
            result = data
            IsBusy = false
        end)
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end
