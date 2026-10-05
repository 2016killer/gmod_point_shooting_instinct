local flags = { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }

CreateConVar('ps_invincible', '1', flags)
CreateConVar('ps_timescale_mark', '0.1', flags)
CreateConVar('ps_timescale_execute', '0.3', flags)
CreateConVar('ps_timescale_finish', '0.1', flags)
CreateConVar('ps_timescale_mp_disable', '1', flags)

if CLIENT then return end


function pointshoot:TimeScaleAllowed()
    if game.SinglePlayer() then return true end
    local mpDisable = GetConVar('ps_timescale_mp_disable')
    return not (mpDisable and mpDisable:GetBool())
end


function pointshoot:SetInvincible(ply, on)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    if on then
        if not GetConVar('ps_invincible'):GetBool() then return end
        if ply.ps_god_prev == nil then
            ply.ps_god_prev = ply:HasGodMode()
        end
        ply:GodEnable()
    else
        if ply.ps_god_prev == nil then return end
        if not ply.ps_god_prev then ply:GodDisable() end
        ply.ps_god_prev = nil
    end
end


for _, event in ipairs({ 'PlayerDeath', 'PlayerDisconnected', 'PlayerSpawn' }) do
    hook.Add(event, 'pointshoot.invincible.cleanup', function(ply)
        pointshoot:SetInvincible(ply, false)
    end)
end
