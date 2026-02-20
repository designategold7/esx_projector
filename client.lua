local duiObj = nil
local txd = "script_rt_projector"
local txn = "slides"

-- Configuration for the Holographic Screen
-- Set these coordinates to the exact spot on the wall where you want the slides to appear
local screenCoords = vector3(448.51, -985.00, 35.50) 
local renderDistance = 25.0 -- How close players must be to see the presentation (optimizes performance)
local slideWidth = 0.8 -- Base width of the projection
local slideHeight = 0.45 -- Base height (maintains a perfect 16:9 aspect ratio)

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
        -- Initialize the headless browser
        duiObj = CreateDui("nui://esx_projector/html/index.html", 1920, 1080)
        local duiHandle = GetDuiHandle(duiObj)
        
        -- Create the runtime texture, but do NOT apply it to a prop
        local txdId = CreateRuntimeTxd(txd)
        CreateRuntimeTextureFromDuiHandle(txdId, txn, duiHandle)
        
        Wait(500)
    end
    
    SendDuiMessage(duiObj, json.encode({
        type = 'updateSlide',
        url = url
    }))
end)

-- The Native Spatial Render Loop
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        
        if duiObj then
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            local dist = #(playerCoords - screenCoords)
            
            -- Only execute the draw loop if the player is actually in the briefing room
            if dist < renderDistance then
                wait = 0
                
                -- Pin the 2D rendering context to the 3D wall coordinates
                SetDrawOrigin(screenCoords.x, screenCoords.y, screenCoords.z, 0)
                
                -- Draw the CEF runtime texture into the world space
                -- Parameters: TextureDict, TextureName, X, Y, Width, Height, Heading, R, G, B, Alpha
                DrawSprite(txd, txn, 0.0, 0.0, slideWidth, slideHeight, 0.0, 255, 255, 255, 255)
                
                -- Release the drawing context back to normal
                ClearDrawOrigin()
            end
        end
        
        Wait(wait)
    end
end)

-- ox_target Implementation for the Podium Laptop
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
                name = 'projector_next',
                event = 'police_projector:clientControl',
                icon = 'fa-solid fa-arrow-right',
                label = 'Next Slide',
                action = 'next'
            },
            {
                name = 'projector_prev',
                event = 'police_projector:clientControl',
                icon = 'fa-solid fa-arrow-left',
                label = 'Previous Slide',
                action = 'prev'
            },
            {
                name = 'projector_add',
                event = 'police_projector:clientControl',
                icon = 'fa-solid fa-plus',
                label = 'Add Slide URL',
                action = 'add'
            },
            {
                name = 'projector_clear',
                event = 'police_projector:clientControl',
                icon = 'fa-solid fa-trash',
                label = 'Clear Presentation',
                action = 'clear'
            }
        }
    })
end)

AddEventHandler('police_projector:clientControl', function(data)
    if data.action == 'add' then
        local input = exports.ox_lib:inputDialog('Add Slide', {
            {type = 'input', label = 'Direct Image URL', description = 'Must be a direct link to an image (e.g., Imgur .png)', required = true}
        })
        
        if input and input[1] then
            TriggerServerEvent('police_projector:controlSlide', 'add', input[1])
        end
    else
        TriggerServerEvent('police_projector:controlSlide', data.action)
    end
end)