-- Pre-load your presentation here so you never have to paste URLs in-game
local slidesArray = {
    "png url",
    "png url",
    "png url"
}
local currentSlideIndex = 1

local function IsAuthorizedToPresent(xPlayer)
    if not xPlayer then return false end
    
    local jobName = xPlayer.job.name
    local gradeName = xPlayer.job.grade_name
    
    if jobName == 'police' 
        if gradeName == 'supervisor' then
            return true
        end
    end
    
    return false
end

RegisterNetEvent('police_projector:controlSlide')
AddEventHandler('police_projector:controlSlide', function(action, urlPayload)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if not IsAuthorizedToPresent(xPlayer) then
        return xPlayer.showNotification('You lack the required command rank to operate the briefing projector.')
    end

    if action == 'add' then
        if urlPayload and type(urlPayload) == 'string' then
            table.insert(slidesArray, urlPayload)
            xPlayer.showNotification('Slide appended to presentation. Total: ' .. #slidesArray)
        end
    elseif action == 'clear' then
        TriggerClientEvent('police_projector:updateUrl', -1, "off")
        xPlayer.showNotification('Projector screen turned off.')
    elseif action == 'start' then
        currentSlideIndex = 1
        if #slidesArray > 0 then
            TriggerClientEvent('police_projector:updateUrl', -1, slidesArray[currentSlideIndex])
            xPlayer.showNotification('Presentation started.')
        else
            xPlayer.showNotification('No slides configured in the server script.')
        end
    elseif action == 'next' then
        if #slidesArray == 0 then return xPlayer.showNotification('No slides loaded.') end
        
        if currentSlideIndex < #slidesArray then
            currentSlideIndex = currentSlideIndex + 1
            TriggerClientEvent('police_projector:updateUrl', -1, slidesArray[currentSlideIndex])
        else
            xPlayer.showNotification('End of presentation.')
        end
    elseif action == 'prev' then
        if #slidesArray == 0 then return xPlayer.showNotification('No slides loaded.') end
        
        if currentSlideIndex > 1 then
            currentSlideIndex = currentSlideIndex - 1
            TriggerClientEvent('police_projector:updateUrl', -1, slidesArray[currentSlideIndex])
        else
            xPlayer.showNotification('You are on the first slide.')
        end
    end
end)

RegisterNetEvent('police_projector:requestSync')
AddEventHandler('police_projector:requestSync', function()
    local _source = source
    if #slidesArray > 0 and slidesArray[currentSlideIndex] then
        TriggerClientEvent('police_projector:updateUrl', _source, slidesArray[currentSlideIndex])
    end
end)