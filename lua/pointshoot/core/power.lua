local flags = { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }

CreateConVar('ps_buoyancy', '0.1', flags)
CreateConVar('ps_headshot_reward', '0.3', flags)
CreateConVar('ps_power_cost', '0.1', flags)

pointshoot:RegisterClientToServer('CTSDecrPower')

function pointshoot:CTSDecrPower(ply, delta)
    if SERVER then 
        local oldPower = ply:GetNW2Float('psnw_power', 1)
        local newPower = math.Clamp(oldPower - delta, 0, 1)
        if oldPower == newPower then return end
        self.PowerBuoyancyTime = CurTime() + 2
        ply:SetNW2Float('psnw_power', newPower)
    elseif CLIENT then
        return
    end
end

if SERVER then
    local pointshoot = pointshoot
    pointshoot.PowerBuoyancyTime = 0
    hook.Add('PlayerPostThink', 'pointshoot.buoyancy', function(ply)
        local curtime = CurTime()
        if curtime < pointshoot.PowerBuoyancyTime then return end
        pointshoot.PowerBuoyancyTime = curtime + 1

        local oldPower = ply:GetNW2Float('psnw_power', 1)
        local newPower = math.Clamp(oldPower + GetConVar('ps_buoyancy'):GetFloat(), 0, 1)
        if oldPower == newPower then return end
        ply:SetNW2Float('psnw_power', newPower)
    end)

    hook.Add('ScaleNPCDamage', 'pointshoot.headshot.reward' , function(npc, hitgroup, dmginfo)
        if hitgroup ~= HITGROUP_HEAD or not IsValid(dmginfo) or dmginfo:GetInflictor().ps_flag then 
            return 
        end

        local attacker = dmginfo:GetAttacker()
        if not IsValid(attacker) or not attacker:IsPlayer() then 
            return 
        end
        
        local oldPower = attacker:GetNW2Float('psnw_power', 1)
        local newPower = math.Clamp(oldPower + GetConVar('ps_headshot_reward'):GetFloat(), 0, 1)
        if oldPower == newPower then return end

        attacker:SetNW2Float('psnw_power', newPower)
    end)
end
