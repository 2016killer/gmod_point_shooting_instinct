
local flags = { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }

CreateConVar('ps_sixthsense_range', '1000', flags)
CreateConVar('ps_sixthsense_cost', '0.3', flags)
CreateConVar('ps_sixthsense_ent_limit', '30', flags)
CreateConVar('ps_sixthsense_duration', '1', flags)
CreateConVar('ps_sixthsense_expand_time', '1', flags)
CreateConVar('ps_sixthsense_scan_players', '1', flags)
CreateConVar('ps_sixthsense_scan_npcs', '1', flags)
CreateConVar('ps_sixthsense_scan_grenades', '1', flags)
CreateConVar('ps_sixthsense_scan_vehicles', '1', flags)
CreateConVar('ps_sixthsense_scan_breakables', '1', flags)

if SERVER then return end

local scanPlayers = GetConVar('ps_sixthsense_scan_players')
local scanNPCs = GetConVar('ps_sixthsense_scan_npcs')
local scanGrenades = GetConVar('ps_sixthsense_scan_grenades')
local scanVehicles = GetConVar('ps_sixthsense_scan_vehicles')
local scanBreakables = GetConVar('ps_sixthsense_scan_breakables')


sixthsense = sixthsense or {}
local sixthsense = sixthsense
concommand.Add('sixthsense_debug', function()
	PrintTable(sixthsense)
end)

sixthsense.color1 = Color(0, 0, 0, 100)
sixthsense.color2 = Color(255, 255, 255, 255)
sixthsense.color3 = Color(255, 255, 255, 255)
concommand.Add('sixthsense', function(ply)
	local curpower = LocalPlayer():GetNW2Float('psnw_power', 1)
	local powercost = GetConVar('ps_sixthsense_cost'):GetFloat()
	if curpower < powercost then 
		ply:EmitSound('Buttons.snd40')
		return 
	end

	if not sixthsense.enable or (sixthsense.alphaRate and sixthsense.alphaRate <= 0.2) then
		pointshoot:CallDoubleEnd('CTSDecrPower', LocalPlayer(), powercost)
		sixthsense:Start(LocalPlayer(), 
			GetConVar('ps_sixthsense_range'):GetInt(),
			GetConVar('ps_sixthsense_expand_time'):GetFloat(),
			GetConVar('ps_sixthsense_duration'):GetFloat(),
			GetConVar('ps_sixthsense_ent_limit'):GetFloat(),
			false
		)
		surface.PlaySound('dishonored/darkvision_scan.wav')
	end
end)

concommand.Add('sixthsense_old', function(ply, cmd, args)
	local curpower = LocalPlayer():GetNW2Float('psnw_power', 1)
	local powercost = GetConVar('ps_sixthsense_cost'):GetFloat()
	if curpower <= powercost then 
		return 
	end

	if not sixthsense.enable or (sixthsense.alphaRate and sixthsense.alphaRate <= 0.2) then
		pointshoot:CallDoubleEnd('CTSDecrPower', LocalPlayer(), powercost)
		sixthsense:Start(LocalPlayer(), unpack(args))
		surface.PlaySound('dishonored/darkvision_scan.wav')
	end
end)

sixthsense.WhiteList = {
	['combine_mine'] = 0,
	['grenade_helicopter'] = 0,
	['item_ammo_357'] = 1,
	['item_ammo_357_large'] = 1,
	['item_ammo_ar2'] = 1,
	['item_ammo_ar2_altfire'] = 1,
	['item_ammo_ar2_large'] = 1,
	['item_ammo_crossbow'] = 1,
	['item_ammo_pistol'] = 1,
	['item_ammo_pistol_large'] = 1,
	['item_ammo_smg1'] = 1,
	['item_ammo_smg1_grenade'] = 1,
	['item_ammo_smg1_large'] = 1,
	['item_battery'] = 1,
	['item_box_buckshot'] = 1,
	['item_healthcharger'] = 1,
	['item_healthkit'] = 1,
	['item_healthvial'] = 1,
	['item_rpg_round'] = 1,
	['item_suitcharger'] = 1,
	['combine_mine_resistance'] = 1,
}

sixthsense.BlackList = {
	['mg_viewmodel'] = -1,
	['lg_ragdoll'] = -1,
	['mg_attachment'] = -1,
}


sixthsense.Filter = function(ent)
	if ent == LocalPlayer() or ent:GetOwner() == LocalPlayer() or ent:GetParent() == LocalPlayer() then
		return nil
	end

	local class = ent:GetClass()

	if sixthsense.WhiteList[class] then
		return sixthsense.WhiteList[class]
	end

	if sixthsense.BlackList[class] then
		return nil
	end

	if pointshoot:IsGrenade(ent) then
		if not scanGrenades:GetBool() then
			return nil
		end

		if IsValid(ent.psss_skin) then
			ent.psss_skin:Remove()
		end

		local grenade = ClientsideModel(ent:GetModel())
		grenade:SetPos(ent:GetPos())
		grenade:SetAngles(ent:GetAngles())
		grenade:SetParent(ent)
		grenade:SetNoDraw(true)

		ent.psss_skin = grenade

		ent:CallOnRemove('sixthsense_grenade', function() if IsValid(grenade) then grenade:Remove() end end)

		return 0, grenade
	end

	if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
		if ent:IsPlayer() and not scanPlayers:GetBool() then
			return nil
		elseif not ent:IsPlayer() and not scanNPCs:GetBool() then
			return nil
		end

		if not ent:Alive() then
			return nil
		end

		return 0
	end

	if ent:IsVehicle() then
		if not scanVehicles:GetBool() then
			return nil
		end

		return 2
	end

	if ent:GetMaxHealth() > 2 then
		if not scanBreakables:GetBool() then
			return nil
		end

		return 1
	end

	if scripted_ents.GetStored(class) or ent:IsWeapon() then
		return 1
	end

	return nil
end

local function ClampAbs(num, min, max)
	return math.Clamp(math.abs(num), min, max)
end

function sixthsense:Start(ply, targetRange, duration, durationAlpha, limitent, cycle, filterOverride)
	self.curRange = 0
	self.alphaRate = 1

	self.targetRange = ClampAbs(targetRange or 1000, 1, 10000)
	self.limitent = ClampAbs(limitent or 30, 5, 100)
	self.duration = ClampAbs(duration or 1, 0.1, 10)
	self.durationAlpha = ClampAbs(durationAlpha or 2, 0.1, 10)

	self.entqueue = {}

	local pos = ply:GetPos()
	local range = math.min(self.targetRange + 0.75 * (self.targetRange / self.duration) * self.durationAlpha, 2 * self.targetRange)
	local entities = ents.FindInSphere(pos, range)
	
	local filter = filterOverride or self.Filter
	local rangeSqr = range * range
	local weightTable = {}
	for i, ent in ipairs(entities) do 
		if not IsValid(ent) then
			continue
		elseif not isfunction(ent.DrawModel) then
			continue
		end

		local priority, entOverride = filter(ent)
		if priority == nil then 
			continue 
		end

		table.insert(
			weightTable, 
			{
				ent = IsValid(entOverride) and entOverride or ent, 
				priority = (ent:GetPos() - pos):LengthSqr() / rangeSqr + priority
			}
		)
	end

	table.sort(weightTable, function(a, b) return a.priority < b.priority end)

	-- PrintTable(weightTable)

	for i = 1, math.min(self.limitent, #weightTable) do
		table.insert(self.entqueue, weightTable[i].ent)
	end

	self.cycle = cycle
	self.StartTime = RealTime()
	self.enable = true

	hook.Run('SixthSenseStart')
end

function sixthsense:Clean()
	self.enable = nil
	self.curRange = nil
	self.alphaRate = nil
	
	self.targetRange = nil
	self.limitent = nil
	self.duration = nil
	self.durationAlpha = nil
	self.entqueue = {}
	
	self.cycle = nil
	self.StartTime = nil
end

function sixthsense:Think()
	if not self.enable then
		return
	end

	local dt = RealTime() - self.StartTime
	local rate = dt / self.duration

	self.curRange = rate * self.targetRange
	if dt >= self.duration then
		self.alphaRate = math.Clamp(1 - (dt - self.duration) / self.durationAlpha, 0, 1)
	end

	if dt >= self.duration + self.durationAlpha then
		if not self.cycle then
			self:Clean()
			return
		end
		self:Start(LocalPlayer(), self.targetRange, self.duration, self.durationAlpha, self.limitent, self.cycle)
		surface.PlaySound('dishonored/darkvision_scan.wav')
		hook.Run('SixthSenseEnd')
	end
end

hook.Add('Think', 'sixthsense', function() sixthsense:Think() end)

local white = Color(255, 255, 255, 255)
local vol_light001_mat = Material('Models/effects/vol_light001')
function sixthsense:Draw()
	if not self.enable then
		return 
	end
	local plypos = LocalPlayer():GetPos()

	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SuppressEngineLighting(true)
		-- 全屏
		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_INCR)
		render.SetMaterial(vol_light001_mat)
		render.DrawSphere(plypos, self.curRange, 8, 8, white)
	
		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		cam.Start2D()
			surface.SetDrawColor(self.color1.r, self.color1.g, self.color1.b, self.color1.a * self.alphaRate)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()

		-- 遮罩
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_INCR)
		render.SetMaterial(vol_light001_mat)
		render.DrawSphere(plypos, self.curRange + 20, 8, 8, white)


		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		cam.Start2D()
			surface.SetDrawColor(self.color2.r, self.color2.g, self.color2.b, self.color2.a * self.alphaRate)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()

	render.SetStencilEnable(false)
	render.SuppressEngineLighting(false)
end

local npc_halo_entities = {}
local other_halo_entities = {}
function sixthsense:DrawHalos()
	if not self.enable then
		return
	end

	local plypos = LocalPlayer():GetPos()
	local maxDistSqr = self.curRange * self.curRange + 40000

	for i = #npc_halo_entities, 1, -1 do
		npc_halo_entities[i] = nil
	end
	for i = #other_halo_entities, 1, -1 do
		other_halo_entities[i] = nil
	end

	for _, ent in ipairs(self.entqueue) do
		if IsValid(ent) and plypos:DistToSqr(ent:GetPos()) <= maxDistSqr then
			if ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() then
				if not ent:Alive() then
					continue
				end
			end

			if ent:IsNPC() then
				npc_halo_entities[#npc_halo_entities + 1] = ent
			else
				other_halo_entities[#other_halo_entities + 1] = ent
			end
		end
	end

	local alpha = math.Clamp(self.alphaRate or 0, 0, 1)
	local color = self.color3
	local haloColor = Color(color.r * alpha, color.g * alpha, color.b * alpha)
	if #npc_halo_entities > 0 then
		halo.Add(npc_halo_entities, haloColor, 1, 1, 1, true, true)
	end
	if #other_halo_entities > 0 then
		halo.Add(other_halo_entities, haloColor, 1, 1, 1, true, true)
	end
end

hook.Add('PostDrawOpaqueRenderables', 'sixthsense', function() 
	local succ, err = pcall(sixthsense.Draw, sixthsense)
	if not succ then
		print(err)
		render.SuppressEngineLighting(false)
		render.SetStencilEnable(false)
		render.MaterialOverride(nil)
	end
end)

hook.Add('PreDrawHalos', 'sixthsense.halos', function()
	local succ, err = pcall(sixthsense.DrawHalos, sixthsense)
	if not succ then
		print(err)
	end
end)
