Config = {}

Config.Multichar = false

Config.Framework = 'Hello Everyone'

Config.OldFramework = false
-- If you are using legacy ESX or legacy Qbus infrastructure, mark true.

Config.CoreName = {
    ["ESX"] = 'es_extended',
    ["QBCore"] = 'qb-core'
}

Config.Mysql = "oxmysql" -- ghmattimysql or mysql-async or oxmysql

Config.MoneyIsItem = true 

Config.ItemMoneyName = "cash"

Config.PrimaryIdentifier = "license" -- or steam -- discord -- live like

Config.Version = {
    DB = "https://raw.githubusercontent.com/0resmon/0r-core/main/versions.json",
    Loop = false,
    LoopTime = 1000
}

Config.events = {
    updateJob = {
        ["ESX"] = "esx:setJob",
        ["QBCore"] = "QBCore:Client:OnJobUpdate",
    },
    playerLoaded = {
        ["ESX"] = "esx:playerLoaded",
        ["QBCore"] = "QBCore:Client:OnPlayerLoaded",
    },  
}

Config.Lang = {
    ["NeedUpdate"] = "A new update is available for this script."
}
