Config = {}

Config.Multichar = false

Config.Mysql = "oxmysql" -- ghmattimysql or mysql-async or oxmysql

Config.MoneyIsItem = true 

Config.ItemMoneyName = "cash"

Config.PrimaryIdentifier = "license" -- or steam -- discord -- live like

Config.Framework = "QBCore" -- or QBCore

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
