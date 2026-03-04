fx_version 'cerulean'

game 'gta5'
lua54 'yes'

dependencies {
  'ox_lib',
  'ox_inventory',
  'es_extended',
  'oxmysql',
  'cmdVehiclekeys'
}

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua'
}
