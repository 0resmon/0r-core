Config = {}

Config.Multichar = false

Config.Mysql = "oxmysql" -- ghmattimysql or mysql-async or oxmysql

Config.PrimaryIdentifier = "license" -- or steam -- discord -- live like

Config.Framework = "ESX" -- or QBCore

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
        ["QBCore"] = "QBCore:Client:OnJobUpdate",
    },  
}

Config.Lang = {
    ["NeedUpdate"] = "A new update is available for this script."
}
