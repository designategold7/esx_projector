local isPlacing, ghostObj, activeDuis = false, nil, {}
function GetUserURL()
    AddTextEntry('URL_PROMPT', "Enter Hologram URL (must start with http/https):")
    DisplayOnscreenKeyboard(1, "URL_PROMPT", "", "https://", "", "", "", 100)
    while UpdateOnscreenKeyboard() == 0 do Wait(0) end
    if GetOnscreenKeyboardResult() then
        return GetOnscreenKeyboardResult()
    end
    return nil
end
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
    SetEntityAlpha(ghostObj, 150, false)
    SetEntityCollision(ghostObj, false, false)
    Citizen.CreateThread(function()
        while isPlacing do
            local hit, coords = GetCoords()
            if hit then SetEntityCoords(ghostObj, coords.x, coords.y, coords.z) end
            
            if IsControlJustPressed(0, 38) then -- 'E' key
                local url = GetUserURL()
                if url then
                    isPlacing = false
                    AnchorHologram(coords, GetEntityRotation(ghostObj), url)
                else
                    print("Placement Cancelled: Invalid URL")
                end
            end
            Wait(0)
        end
    end)
end)
function AnchorHologram(coords, rot, url)
    if DoesEntityExist(ghostObj) then DeleteObject(ghostObj) end
    
    local obj = CreateObject(`prop_area_monitor_01`, coords.x, coords.y, coords.z, true, true, true)
    SetEntityRotation(obj, rot.x, rot.y, rot.z, 2, true)
    FreezeEntityPosition(obj, true)

    -- Memory-Safe DUI Creation
    local txdName = "Holo_" .. tostring(obj)
    local dui = CreateDui(url, 1280, 720)
    local handle = GetDuiHandle(dui)
    local txd = CreateRuntimeTxd(txdName)
    CreateRuntimeTextureFromDuiHandle(txd, "tex", handle)
    AddReplaceTexture('prop_area_monitor_01', 'script_rt_screen', txdName, "tex")
    activeDuis[obj] = {dui = dui, txd = txd}
end
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for obj, data in pairs(activeDuis) do
            DestroyDui(data.dui)
            if DoesEntityExist(obj) then DeleteObject(obj) end
        end
    end
end)
function RotationToDirection(rotation)
	local adjustedRotation = { x = (math.pi / 180) * rotation.x, y = (math.pi / 180) * rotation.y, z = (math.pi / 180) * rotation.z }
	local direction = { x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), z = math.sin(adjustedRotation.x) }
	return direction
end
