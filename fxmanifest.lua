fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script '@es_extended/imports.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

-- You must declare the local HTML file so the CEF can access it natively
files {
    'html/index.html'
}