pointshoot:RegisterClientToServer('CTSFinish')


function pointshoot:CTSFinish(ply)
    self:FinishEffect(ply)
end

function pointshoot:FinishEffect(ply)
    if SERVER then
        pointshoot:SetInvincible(ply, false)
        timer.Simple(0.15, function()
            self:TimeScaleFadeIn(1, nil)
        end)
        self:TimeScaleFadeIn(GetConVar('ps_timescale_finish'):GetFloat(), nil)
    elseif CLIENT then
        return
    end
end
