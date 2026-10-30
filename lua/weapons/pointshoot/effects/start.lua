local notSkeleton = {
	['models/eli.mdl'] = true,
	['models/zombie/classic_torso.mdl'] = true,
	['models/zombie/fast_torso.mdl'] = true,
}


local function filter(ent)
	if ent == LocalPlayer() or ent:GetOwner() == LocalPlayer() or ent:GetParent() == LocalPlayer() then
		return nil
	end

	if pointshoot:IsGrenade(ent) then
		if IsValid(ent.psss_skin) then
			ent.psss_skin:Remove()
		end

		return 'grenades'
	end

	if ent:IsNPC() then
		if not ent:Alive() then
			return nil
		end

		if ent:LookupBone('ValveBiped.Bip01_Pelvis') and not notSkeleton[ent:GetModel()] then
			if IsValid(ent.psss_skin) then
				ent.psss_skin:Remove()
			end

			local skeleton = ClientsideModel('models/player/skeleton.mdl', RENDERGROUP_OTHER)
			skeleton:SetParent(ent)
			skeleton:AddEffects(EF_BONEMERGE)
			skeleton:SetRenderMode(RENDERMODE_TRANSCOLOR)
			skeleton:SetColor(Color(0, 0, 0, 0)) 

			ent.psss_skin = skeleton

			ent:CallOnRemove('sixthsense_skeleton', function() if IsValid(skeleton) then skeleton:Remove() end end)

			return 'actors', skeleton
		else
			return 'actors'
		end
	end

	if ent:GetMaxHealth() > 2 then
		return 'breakables'
	end

	return nil
end

function SWEP:StartEffect(ply)
	if SERVER then
		pointshoot:TimeScaleFadeIn(GetConVar('ps_timescale_mark'):GetFloat(), 0.1)
	elseif CLIENT then
		surface.PlaySound('hitman/start.mp3')
		self:ScreenFlash(150, 0, 0.2)

		local succ, err = pcall(sixthsense.Start, sixthsense, LocalPlayer(), 500, 0.1, 0.5, 30, false, filter)
		if not succ then
			print('[PointShooting]: sixthsense.Start failed:', err)
		end

		local emitter = ParticleEmitter(LocalPlayer():GetPos())
		local center = LocalPlayer():GetPos()

		for i = 1, 100 do
			local rand = VectorRand()
			local part = emitter:Add('effects/spark', center + rand * 200)
			local dir = VectorRand()
			local grav =  VectorRand() * 150
			if part then
				part:SetDieTime(0.5)

				part:SetStartAlpha(255)
				part:SetEndAlpha(0) 

				part:SetStartSize(5)
				part:SetEndSize(0)

				part:SetGravity(grav)
				part:SetVelocity(dir * 500)
				part:SetAngles(dir:Angle())
			end
		end
		emitter:Finish()
		
	end
end

if CLIENT then
	local startAlpha, targetAlpha = 0, 0
	local duration, startTime = 0, 0
	function SWEP:DrawFlash()
		if not startTime then 
			return 
		end

		local dt = self.drawtime - startTime
		if dt >= duration then
			startTime = nil
			return
		end

		surface.SetDrawColor(255, 255, 255, Lerp(dt / duration, startAlpha, targetAlpha))
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end

	function SWEP:ScreenFlash(startalpha, targetalpha, dura)
		startAlpha = startalpha
		targetAlpha = targetalpha
		duration = dura
		startTime = RealTime()
	end

	table.insert(SWEP.DrawHUDs, SWEP.DrawFlash)
end
