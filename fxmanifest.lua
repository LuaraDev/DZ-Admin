fx_version 'cerulean'
games { 'gta5' }
author 'Development Zone'

description 'Development Zone - Admin panel.'
version '0.0.1'

client_scripts { 'client/cl_main.lua', 'client/cl_noclip.lua', 'client/cl_utils.lua' }
server_scripts { 'server/sv_main.lua', 'configuration.lua', '@mysql-async/lib/MySQL.lua' }

ui_page 'user-interface/index.html'
files { 'user-interface/index.html', 'user-interface/style.css', 'user-interface/script.js', 'server/bans.json' }