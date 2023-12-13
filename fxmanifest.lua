fx_version 'bodacious'

game 'gta5'

author '0Resmon'

description "Created by 0Resmon"

discord 'https://discord.gg/0resmon'

ui_page "web/index.html"

client_scripts { 'config.lua', 'client/client.lua' }

server_scripts {  
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server/common.lua',
    'server/server.lua',
    'server/vcheck.lua',
}

files {
    'web/index.html',
    'web/**/*',
}

version "1.0.3"