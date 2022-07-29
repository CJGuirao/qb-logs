
fx_version 'cerulean'
game 'gta5'

description 'QB-Logs'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'config.lua'
}

lua54 'yes'