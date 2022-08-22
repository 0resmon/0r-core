fx_version 'cerulean'
game 'gta5'
author '0RESMON'
discord 'https://discord.gg/0resmon'

client_scripts { 'config.lua', 'client/client.lua', 'shared.lua' }

server_scripts {  
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server/common.lua',
    'server/server.lua',
    'server/vcheck.lua',
    'shared.lua'
}

version "1.1"