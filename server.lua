
RegisterServerEvent('hologram:sync')
AddEventHandler('hologram:sync', function(coords, rot, url)
    TriggerClientEvent('hologram:spawn', -1, coords, rot, url)
end)
