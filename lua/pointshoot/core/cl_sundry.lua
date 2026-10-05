CreateClientConVar('ps_key_mark', '107', true, false, '')
CreateClientConVar('ps_key_execute', '108', true, false, '')
CreateClientConVar('ps_key_cancel', '12', true, false, '')
CreateClientConVar('ps_key_pointshoot', '0', true, false, '')
CreateClientConVar('ps_key_sixthsense', '0', true, false, '')
CreateClientConVar('ps_key_markall', tostring(MOUSE_MIDDLE), true, false, '')
CreateClientConVar('ps_markall_range', '1000', true, false, '')
CreateClientConVar('ps_hud_change', '1', true, false, '')
CreateClientConVar('ps_hud_full', '0', true, false, '')


-- ============= 启动按键 =============
-- 0(未绑定) 视为没按下
local function IsBoundKeyDown(key)
    return key ~= 0 and (input.IsKeyDown(key) or input.IsMouseDown(key))
end

local startKeyDown = false
local senseKeyDown = false

hook.Add('Think', 'pointshoot.keys', function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local blocked = gui.IsGameUIVisible() or gui.IsConsoleVisible()

    local startKey = not blocked and IsBoundKeyDown(GetConVar('ps_key_pointshoot'):GetInt())
    if startKey and not startKeyDown and not IsValid(ply:GetWeapon('pointshoot')) then
        RunConsoleCommand('+pointshoot')
    end
    startKeyDown = startKey

    local senseKey = not blocked and IsBoundKeyDown(GetConVar('ps_key_sixthsense'):GetInt())
    if senseKey and not senseKeyDown then
        RunConsoleCommand('sixthsense')
    end
    senseKeyDown = senseKey
end)


function pointshoot:DrawPowerTick(endtime, duration)
    if CurTime() > endtime then 
        self:RemoveDrawPowerTick()
        return 
    end

    local scrW, scrH = ScrW(), ScrH()
    local w, h = scrW * 0.2, 20
    local x = (scrW - w) * 0.5
    local y = scrH - 3 * h

    local alphaRate = math.Clamp((endtime - CurTime()) / duration, 0, 1)
    local curpower = LocalPlayer():GetNW2Float('psnw_power', 1)

    surface.SetDrawColor(170, 170, 170, 255 * alphaRate)
    surface.DrawOutlinedRect(x, y, w, h)
    surface.SetDrawColor(255, 255, 0, 100 * alphaRate)
    surface.DrawRect(x, y, w * curpower, h)
end

function pointshoot:EnableDrawPowerTick(duration)
    local endtime = CurTime() + duration
    hook.Add('HUDPaint', 'pointshoot.drawpower', function() self:DrawPowerTick(endtime, duration) end)
end

function pointshoot:RemoveDrawPowerTick()
    hook.Remove('HUDPaint', 'pointshoot.drawpower')
end

hook.Add('EntityNetworkedVarChanged', 'pointshoot.power.change', function(ent, name, oldval, newval)
    if ent ~= LocalPlayer() then return end
    if name ~= 'psnw_power' then return end

    if GetConVar('ps_hud_change'):GetBool() then 
        pointshoot:EnableDrawPowerTick(1.5) 
    end

    if oldval ~= 1 and newval == 1 and GetConVar('ps_hud_full'):GetBool() then 
        pointshoot:EnableDrawPowerTick(1.5) 
    end
end)
