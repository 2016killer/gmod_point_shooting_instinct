CreateClientConVar('ps_key_mark', '107', true, false, '')
CreateClientConVar('ps_key_execute', '108', true, false, '')
CreateClientConVar('ps_key_cancel', '12', true, false, '')
CreateClientConVar('ps_hud_change', '1', true, false, '')
CreateClientConVar('ps_hud_full', '0', true, false, '')

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
