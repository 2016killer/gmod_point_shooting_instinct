function SWEP:ExecuteEffect()
    if SERVER then
        pointshoot:TimeScaleFadeIn(GetConVar('ps_timescale_execute'):GetFloat(), nil)
    elseif CLIENT then
        surface.PlaySound('hitman/execute.mp3')
    end
end
