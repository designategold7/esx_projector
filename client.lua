local isPlacing, ghostObj, activeDuis = false, nil, {}
function GetCoords()
    local cam = GetGameplayCamCoords()
    local endC = cam + (RotationToDirection(GetGameplayCamRot(2)) * 15.0)
    local ray = StartShapeTestRay(cam.x, cam.y, cam.z, endC.x, endC.y, endC.z, -1, PlayerPedId(), 0)
    local _, hit, coords = GetShapeTestResult(ray)
    return hit, coords
end
RegisterCommand('hologram', function()
    if isPlacing then return end
    isPlacing = true
    local model = `prop_area_monitor_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    ghostObj = CreateObject(model, 0, 0, 0, false, false, false)
    SetEntityAlpha(ghostObj, 150)
    SetEntityCollision(ghostObj, false)

    Citizen.CreateThread(function()
        while isPlacing do
            local hit, coords = GetCoords()
            if hit then SetEntityCoords(ghostObj, coords.x, coords.y, coords.z) end
            if IsControlJustPressed(0, 38) then -- 'E' to Place
                isPlacing = false
                local url = "https://www.google.com" -- Default, can be prompted
                AnchorHologram(coords, GetEntityRotation(ghostObj), url)
            end
            Wait(0)
        end
    end)
end)
function AnchorHologram(coords, rot, url)
    DeleteObject(ghostObj)
    local obj = CreateObject(`prop_area_monitor_01`, coords.x, coords.y, coords.z, true, true, true)
    SetEntityRotation(obj, rot.x, rot.y, rot.z, 2, true)
    FreezeEntityPosition(obj, true)

    local dui = CreateDui(url, 1280, 720)
    local handle = GetDuiHandle(dui)
    local txd = CreateRuntimeTxd("Holo_"..obj)
    CreateRuntimeTextureFromDuiHandle(txd, "tex", handle)
    AddReplaceTexture('prop_area_monitor_01', 'script_rt_screen', "Holo_"..obj, "tex")
    
    activeDuis[obj] = {dui = dui, txd = txd}
end
-- Cleanup to prevent "Memory Leaks" and "Texture Loss"
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for obj, data in pairs(activeDuis) do
            DestroyDui(data.dui)
            DeleteObject(obj)
        end
    end
end)
