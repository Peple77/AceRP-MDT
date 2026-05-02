fx_version "cerulean"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

name "AceRP MDT"
author "Peple | AceRP Discord: https://discord.gg/NBcXdtD2XZ"
version "1.0"

client_scripts {'client/*.lua'}

server_scripts {
    'server/*.lua', 
    '@oxmysql/lib/MySQL.lua',
}

shared_script {
    '@ox_lib/init.lua',
    'config.lua'
}