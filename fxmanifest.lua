fx_version 'cerulean'
game 'gta5'

name "mVehicles"

description "Manage Vehicles"

author "MONO&RAW"

version "1.1.0"

lua54 'yes'

shared_scripts {
	'shared/*.lua',
	'@ox_lib/init.lua'
}

client_scripts {
	'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

files { 'import.lua', }
