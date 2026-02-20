local duiObj = nil
local txd = "script_rt_projector"
local txn = "slides"

local targetModel = GetHashKey("prop_tv_flat_01") 
local targetTxd = "prop_tv_flat_01" 
local targetTxn = "script_rt_tvscreen" 
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
        
        AddReplaceTexture(targetTxd, targetTxn, txd, txn)
        Wait(500)
    end
    SendDuiMessage(duiObj, json.encode({
        type = 'updateSlide',
        url = url
    }))
end)
Citizen.CreateThread(function()
    TriggerServerEvent('police_projector:requestSync')
end)