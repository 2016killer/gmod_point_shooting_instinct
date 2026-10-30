
local flags = { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }

CreateConVar('ps_sixthsense_range', '2000', flags)
CreateConVar('ps_sixthsense_cost', '0.1', flags)
CreateConVar('ps_sixthsense_ent_limit_actors', '30', flags)
CreateConVar('ps_sixthsense_ent_limit_grenades', '30', flags)
CreateConVar('ps_sixthsense_ent_limit_vehicles', '30', flags)
CreateConVar('ps_sixthsense_ent_limit_breakables', '30', flags)
CreateConVar('ps_sixthsense_ent_limit_weapons', '30', flags)
CreateConVar('ps_sixthsense_ent_limit_scripted', '30', flags)
CreateConVar('ps_sixthsense_ent_limit_other', '30', flags)
CreateConVar('ps_sixthsense_duration', '1', flags)
CreateConVar('ps_sixthsense_expand_time', '2', flags)
CreateConVar('ps_sixthsense_scan_players', '1', flags)
CreateConVar('ps_sixthsense_scan_npcs', '1', flags)
CreateConVar('ps_sixthsense_scan_grenades', '1', flags)
CreateConVar('ps_sixthsense_scan_vehicles', '1', flags)
CreateConVar('ps_sixthsense_scan_breakables', '1', flags)
CreateConVar('ps_sixthsense_scan_weapons', '1', flags)
CreateConVar('ps_sixthsense_scan_scripted', '1', flags)

if SERVER then return end

local function IsDev()
	if GetConVar('developer') and GetConVar('developer'):GetBool() then
		return true
	end

	return false
end

CreateClientConVar('ps_sixthsense_cooldown', '1', true, false, '')
CreateClientConVar('ps_sixthsense_color_dangerous', '255,255,255', true, false, '')
CreateClientConVar('ps_sixthsense_color_scripted', '255,255,255', true, false, '')
CreateClientConVar('ps_sixthsense_color_other', '255,255,255', true, false, '')

local cooldownCVar = GetConVar('ps_sixthsense_cooldown')
local scanPlayers = GetConVar('ps_sixthsense_scan_players')
local scanNPCs = GetConVar('ps_sixthsense_scan_npcs')
local scanGrenades = GetConVar('ps_sixthsense_scan_grenades')
local scanVehicles = GetConVar('ps_sixthsense_scan_vehicles')
local scanBreakables = GetConVar('ps_sixthsense_scan_breakables')
local scanWeapons = GetConVar('ps_sixthsense_scan_weapons')
local scanScripted = GetConVar('ps_sixthsense_scan_scripted')

local groupLimitCVars = {
	actors = GetConVar('ps_sixthsense_ent_limit_actors'),
	grenades = GetConVar('ps_sixthsense_ent_limit_grenades'),
	vehicles = GetConVar('ps_sixthsense_ent_limit_vehicles'),
	breakables = GetConVar('ps_sixthsense_ent_limit_breakables'),
	weapons = GetConVar('ps_sixthsense_ent_limit_weapons'),
	scripted = GetConVar('ps_sixthsense_ent_limit_scripted'),
	other = GetConVar('ps_sixthsense_ent_limit_other'),
}

local groupColorCVars = {
	dangerous = GetConVar('ps_sixthsense_color_dangerous'),
	scripted = GetConVar('ps_sixthsense_color_scripted'),
	other = GetConVar('ps_sixthsense_color_other'),
}


sixthsense = sixthsense or {}
local sixthsense = sixthsense
sixthsense.snapshots = {}
sixthsense.nextUse = 0
local function ParseColor(value)
	local r, g, b = string.match(value or '', '^%s*(%d+)[%s,]+(%d+)[%s,]+(%d+)%s*$')
	if not r then
		return Color(255, 255, 255, 255)
	end

	return Color(
		math.Clamp(tonumber(r), 0, 255),
		math.Clamp(tonumber(g), 0, 255),
		math.Clamp(tonumber(b), 0, 255)
	)
end
sixthsense.ParseColor = ParseColor

concommand.Add('sixthsense_debug', function()
	PrintTable(sixthsense)
end)

sixthsense.color1 = Color(0, 0, 0, 100)
sixthsense.color2 = Color(255, 255, 255, 255)
sixthsense.color3 = Color(255, 255, 255, 255)
concommand.Add('sixthsense', function(ply)
	local now = RealTime()
	if now < sixthsense.nextUse then
		return
	end

	local curpower = LocalPlayer():GetNW2Float('psnw_power', 1)
	local powercost = GetConVar('ps_sixthsense_cost'):GetFloat()
	if curpower < powercost then 
		ply:EmitSound('Buttons.snd40')
		return 
	end

	pointshoot:CallDoubleEnd('CTSDecrPower', LocalPlayer(), powercost)
	sixthsense:Start(LocalPlayer(),
		GetConVar('ps_sixthsense_range'):GetInt(),
		GetConVar('ps_sixthsense_expand_time'):GetFloat(),
		GetConVar('ps_sixthsense_duration'):GetFloat()
	)
	sixthsense.nextUse = now + math.max(cooldownCVar:GetFloat(), 0)
	surface.PlaySound('dishonored/darkvision_scan.wav')
end)

concommand.Add('sixthsense_debug_showentclass', function(ply)
	local origin = ply:GetPos()

	for _, ent in ipairs(ents.FindInSphere(origin, 2000)) do
		if IsValid(ent) then
			debugoverlay.Text(ent:GetPos() + Vector(0, 0, 16), ent:GetClass(), 5, false)
		end
	end
end)


sixthsense.WhiteList = {
	['combine_mine'] = 'grenades',
	['grenade_helicopter'] = 'grenades',
	['item_ammo_357'] = 'other',
	['item_ammo_357_large'] = 'other',
	['item_ammo_ar2'] = 'other',
	['item_ammo_ar2_altfire'] = 'other',
	['item_ammo_ar2_large'] = 'other',
	['item_ammo_crossbow'] = 'other',
	['item_ammo_pistol'] = 'other',
	['item_ammo_pistol_large'] = 'other',
	['item_ammo_smg1'] = 'other',
	['item_ammo_smg1_grenade'] = 'other',
	['item_ammo_smg1_large'] = 'other',
	['item_battery'] = 'other',
	['item_box_buckshot'] = 'other',
	['item_healthcharger'] = 'other',
	['item_healthkit'] = 'other',
	['item_healthvial'] = 'other',
	['item_rpg_round'] = 'other',
	['item_suitcharger'] = 'other',
	['combine_mine_resistance'] = 'grenades',
}

sixthsense.BlackList = {
	['mg_viewmodel'] = -1,
	['lg_ragdoll'] = -1,
	['mg_attachment'] = -1,
}

local filterGroupOrder = {
	'actors',
	'grenades',
	'vehicles',
	'breakables',
	'weapons',
	'scripted',
	'other',
}
local haloGroupOrder = {
	'dangerous',
	'scripted',
	'other',
}
local filterGroupToHaloGroup = {
	actors = 'dangerous',
	grenades = 'dangerous',
	vehicles = 'other',
	breakables = 'other',
	weapons = 'other',
	scripted = 'scripted',
	other = 'other',
}
sixthsense.Filter = function(ent)
	if ent == LocalPlayer() or ent:GetOwner() == LocalPlayer() or ent:GetParent() == LocalPlayer() then
		return nil
	end
	-- print(ent, ent:GetClass())
	-- debugoverlay.Text( ent:GetPos(), ent:GetClass(), 1, false )

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

		return 'grenades'
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

		return 'actors'
	end

	if ent:IsVehicle() then
		if not scanVehicles:GetBool() then
			return nil
		end

		return 'vehicles'
	end

	if ent:IsWeapon() then
		if not scanWeapons:GetBool() then
			return nil
		end

		return 'weapons'
	end

	if scripted_ents.GetStored(class) then
		if not scanScripted:GetBool() then
			return nil
		end

		return 'scripted'
	end

	if ent:GetMaxHealth() > 2 then
		if not scanBreakables:GetBool() then
			return nil
		end

		return 'breakables'
	end

	return nil
end

local function ClampAbs(num, min, max)
	return math.Clamp(math.abs(num), min, max)
end

function sixthsense:Start(ply, targetRange, duration, durationAlpha, filterOverride)
	local snapshot = {
		position = ply:GetPos(),
		startTime = RealTime(),
		targetRange = ClampAbs(targetRange or 1000, 1, 10000),
		expandTime = ClampAbs(duration or 1, 0.1, 10),
		fadeTime = ClampAbs(durationAlpha or 2, 0.1, 10),
		curRange = 0,
		alphaRate = 1,
		groups = {},
		filterGroups = {},
		renderGroups = {},
	}

	for _, group in ipairs(filterGroupOrder) do
		snapshot.filterGroups[group] = {}
	end

	for _, group in ipairs(haloGroupOrder) do
		snapshot.groups[group] = {}
		snapshot.renderGroups[group] = {}
	end

	local range = math.min(
		snapshot.targetRange + 0.75 * (snapshot.targetRange / snapshot.expandTime) * snapshot.fadeTime,
		2 * snapshot.targetRange
	)
	local entities = ents.FindInSphere(snapshot.position, range)

	local filter = filterOverride or self.Filter
	local groupCandidates = {}
	for _, group in ipairs(filterGroupOrder) do
		groupCandidates[group] = {}
	end

	for i, ent in ipairs(entities) do 
		if not IsValid(ent) then
			continue
		elseif not isfunction(ent.DrawModel) then
			continue
		end

		local group, entOverride = filter(ent)
		local candidates = groupCandidates[group]
		if candidates == nil then
			continue
		end

		table.insert(
			candidates,
			{
				ent = IsValid(entOverride) and entOverride or ent,
				sourceEnt = ent,
				distanceSqr = (ent:GetPos() - snapshot.position):LengthSqr()
			}
		)
	end

	for _, group in ipairs(filterGroupOrder) do
		local candidates = groupCandidates[group]
		table.sort(candidates, function(a, b)
			return a.distanceSqr < b.distanceSqr
		end)

		local haloGroup = filterGroupToHaloGroup[group]
		local limit = math.Clamp(groupLimitCVars[group]:GetInt(), 0, 1000)
		for i = 1, math.min(limit, #candidates) do
			table.insert(snapshot.filterGroups[group], candidates[i].sourceEnt)
			table.insert(snapshot.groups[haloGroup], candidates[i].ent)
		end
	end

	table.insert(self.snapshots, snapshot)
	hook.Run('SixthSenseStart')
	if IsDev() then
		PrintTable(snapshot)
	end
	return snapshot
end

function sixthsense:Think()
	local now = RealTime()
	for i = #self.snapshots, 1, -1 do
		local snapshot = self.snapshots[i]
		local elapsed = now - snapshot.startTime

		snapshot.curRange = (elapsed / snapshot.expandTime) * snapshot.targetRange
		if elapsed >= snapshot.expandTime then
			snapshot.alphaRate = math.Clamp(
				1 - (elapsed - snapshot.expandTime) / snapshot.fadeTime,
				0,
				1
			)
		end

		if elapsed >= snapshot.expandTime + snapshot.fadeTime then
			table.remove(self.snapshots, i)
		end
	end
end

hook.Add('Think', 'sixthsense', function() sixthsense:Think() end)

local white = Color(255, 255, 255, 255)
local vol_light001_mat = Material('Models/effects/vol_light001')
function sixthsense:DrawSnapshot(snapshot)
	if snapshot.alphaRate <= 0 then
		return
	end

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
		render.DrawSphere(snapshot.position, snapshot.curRange, 8, 8, white)
	
		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		cam.Start2D()
			surface.SetDrawColor(self.color1.r, self.color1.g, self.color1.b, self.color1.a * snapshot.alphaRate)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()

		-- 遮罩
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_INCR)
		render.SetMaterial(vol_light001_mat)
		render.DrawSphere(snapshot.position, snapshot.curRange + 20, 8, 8, white)


		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		cam.Start2D()
			surface.SetDrawColor(self.color2.r, self.color2.g, self.color2.b, self.color2.a * snapshot.alphaRate)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()

	render.SetStencilEnable(false)
	render.SuppressEngineLighting(false)
end

function sixthsense:Draw()
	for _, snapshot in ipairs(self.snapshots) do
		self:DrawSnapshot(snapshot)
	end
end

function sixthsense:DrawSnapshotHalos(snapshot)
	local maxDistSqr = snapshot.curRange * snapshot.curRange + 40000
	for _, group in ipairs(haloGroupOrder) do
		local entities = snapshot.renderGroups[group]
		for i = #entities, 1, -1 do
			entities[i] = nil
		end

		for _, ent in ipairs(snapshot.groups[group]) do
			if IsValid(ent) and snapshot.position:DistToSqr(ent:GetPos()) <= maxDistSqr then
				if ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() then
					if not ent:Alive() then
						continue
					end
				end

				entities[#entities + 1] = ent
			end
		end

		if #entities > 0 then
			local color = ParseColor(groupColorCVars[group]:GetString())
			local haloColor = Color(
				color.r * snapshot.alphaRate,
				color.g * snapshot.alphaRate,
				color.b * snapshot.alphaRate
			)
			halo.Add(entities, haloColor, 1, 1, 1, true, true)
		end
	end
end

function sixthsense:DrawHalos()
	for _, snapshot in ipairs(self.snapshots) do
		self:DrawSnapshotHalos(snapshot)
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
