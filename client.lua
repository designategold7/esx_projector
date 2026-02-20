local duiObj = nil
local txd = "script_rt_projector"
local txn = "slides"

-- Holographic Screen Configuration
local screenCoords = vector3(448.51, -985.00, 35.50) 
local renderDistance = 25.0 
local slideWidth = 0.8 
local slideHeight = 0.45 

RegisterNetEvent('police_projector:updateUrl')
AddEventHandler('police_projector:updateUrl', function(url)
    if url == "off" then
        if duiObj then
            SendDuiMessage(duiObj, json.encode({
                type = 'updateSlide',
                url = 'off'
            }))
        end
        return
    end

    if not duiObj then
        duiObj = CreateDui("nui://esx_projector/html/index.html", 1920, 1080)
        local duiHandle = GetDuiHandle(duiObj)
        
        local txdId = CreateRuntimeTxd(txd)
        CreateRuntimeTextureFromDuiHandle(txdId, txn, duiHandle)
        
        Wait(500)
    end
    
    SendDuiMessage(duiObj, json.encode({
        type = 'updateSlide',
        url = url
    }))
end)

-- Spatial Render Loop
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        
        if duiObj then
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            
            if #(playerCoords - screenCoords) < renderDistance then
                wait = 0
                SetDrawOrigin(screenCoords.x, screenCoords.y, screenCoords.z, 0)
                DrawSprite(txd, txn, 0.0, 0.0, slideWidth, slideHeight, 0.0, 255, 255, 255, 255)
                ClearDrawOrigin()
            end
        end
        
        Wait(wait)
    end
end)

-- ox_target Implementation for Laptop/Podium
Citizen.CreateThread(function()
    TriggerServerEvent('police_projector:requestSync')
    
    local laptopCoords = vector3(448.51, -988.35, 34.97) 
    
    exports.ox_target:addBoxZone({
        coords = laptopCoords,
        size = vector3(1.5, 1.5, 1.5),
        rotation = 0.0,
        debug = false,
        options = {
            {
                name = 'proj_start',
                event = 'police_projector:clientControl',
                icon = 'fa-solid fa-play',
                label = 'Start Presentation',
                action = 'start'
            },
            {
                name = 'proj_next',
                event = 'police_projector:clientControl',
                icon = 'fa-solid fa-arrow-right',
                label = 'Next Slide',
                action = 'next'
            },
            {
                name = 'proj_prev',
                event = 'police_projector:clientControl',
                icon = 'fa-solid fa-arrow-left',
                label = 'Previous Slide',
                action = 'prev'
            },
            {
                name = 'proj_add',
                event = 'police_projector:clientControl',
                icon = 'fa-solid fa-plus',
                label = 'Emergency Add URL',
                action = 'add'
            },
            {
                name = 'proj_clear',
                event = 'police_projector:clientControl',
                icon = 'fa-solid fa-power-off',
                label = 'Turn Projector Off',
                action = 'clear'
            }
        }
    })
end)
AddEventHandler('police_projector:clientControl', function(data)
    if data.action == 'add' then
        local input = exports.ox_lib:inputDialog('Emergency Add Slide', {
            {type = 'input', label = 'Direct Image URL', required = true}
        })
        
        if input and input[1] then
            TriggerServerEvent('police_projector:controlSlide', 'add', input[1])
        end
    else
        TriggerServerEvent('police_projector:controlSlide', data.action)
    end
end)