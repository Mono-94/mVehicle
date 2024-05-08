fx_version 'cerulean'

game 'gta5'

name "mVehicles"

description "Vehicle API - https://discord.gg/Vk7eY8xYV2"

author "aka_mono & .rawpaper"

version "1.0.0"

lua54 'yes'

shared_scripts { 'shared/lang.lua', 'shared/*.lua', '@ox_lib/init.lua' }

client_script 'client/*.lua'

server_scripts { '@oxmysql/lib/MySQL.lua', 'server/*.lua' }

file 'import.lua'
