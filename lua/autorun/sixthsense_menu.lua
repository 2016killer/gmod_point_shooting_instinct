AddCSLuaFile()

if CLIENT then
	hook.Add('PopulateToolMenu', 'pointshoot.menu.sixthsense', function()
		spawnmenu.AddToolMenuOption('Options', 
			language.GetPhrase('#pointsh.category'), 
			'pointshoot.menu.sixthsense', 
			language.GetPhrase('#pointsh.menu.sixthsense'), '', '', 
			function(panel)
				local default = {
					ps_sixthsense_range = '2000',
					ps_sixthsense_cost = '0.1',
					ps_sixthsense_ent_limit_actors = '30',
					ps_sixthsense_ent_limit_grenades = '30',
					ps_sixthsense_ent_limit_vehicles = '30',
					ps_sixthsense_ent_limit_breakables = '30',
					ps_sixthsense_ent_limit_weapons = '30',
					ps_sixthsense_ent_limit_scripted = '30',
					ps_sixthsense_ent_limit_other = '30',
					ps_sixthsense_cooldown = '1',
					ps_sixthsense_color_dangerous = '255,255,255',
					ps_sixthsense_color_scripted = '255,255,255',
					ps_sixthsense_color_other = '255,255,255',
					ps_sixthsense_duration = '1',
					ps_sixthsense_expand_time = '1',
					ps_sixthsense_scan_players = '1',
					ps_sixthsense_scan_npcs = '1',
					ps_sixthsense_scan_grenades = '1',
					ps_sixthsense_scan_vehicles = '1',
					ps_sixthsense_scan_breakables = '1',
					ps_sixthsense_scan_weapons = '1',
					ps_sixthsense_scan_scripted = '1',
				}

				local ctrl = vgui.Create('ControlPresets', panel)
				ctrl:SetPreset('pointshoot_sixthsense')
				ctrl:AddOption('#preset.default', default)
				for k, v in pairs(default) do ctrl:AddConVar(k) end
				panel:AddPanel(ctrl)

				panel:NumSlider(language.GetPhrase('#ps.sixthsense_range'), 'ps_sixthsense_range', 100, 5000, 0)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_cost'), 'ps_sixthsense_cost', 0, 1, 2)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_duration'), 'ps_sixthsense_duration', 0, 5, 1)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_expand_time'), 'ps_sixthsense_expand_time', 0.1, 5, 2)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_cooldown'), 'ps_sixthsense_cooldown', 0, 5, 2)

				panel:ControlHelp(language.GetPhrase('#ps.sixthsense.filter_behavior'))
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_players'), 'ps_sixthsense_scan_players')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_npcs'), 'ps_sixthsense_scan_npcs')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_grenades'), 'ps_sixthsense_scan_grenades')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_vehicles'), 'ps_sixthsense_scan_vehicles')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_breakables'), 'ps_sixthsense_scan_breakables')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_weapons'), 'ps_sixthsense_scan_weapons')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_scripted'), 'ps_sixthsense_scan_scripted')

				panel:ControlHelp(language.GetPhrase('#ps.sixthsense.entity_limit'))
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_ent_limit_actors'), 'ps_sixthsense_ent_limit_actors', 0, 60, 0)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_ent_limit_grenades'), 'ps_sixthsense_ent_limit_grenades', 0, 60, 0)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_ent_limit_vehicles'), 'ps_sixthsense_ent_limit_vehicles', 0, 60, 0)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_ent_limit_breakables'), 'ps_sixthsense_ent_limit_breakables', 0, 60, 0)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_ent_limit_weapons'), 'ps_sixthsense_ent_limit_weapons', 0, 60, 0)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_ent_limit_scripted'), 'ps_sixthsense_ent_limit_scripted', 0, 60, 0)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_ent_limit_other'), 'ps_sixthsense_ent_limit_other', 0, 60, 0)

				panel:ControlHelp(language.GetPhrase('#ps.sixthsense.color_options'))
				local colorOptions = {
					{ label = '#ps.sixthsense_color_dangerous', cvar = 'ps_sixthsense_color_dangerous' },
					{ label = '#ps.sixthsense_color_scripted', cvar = 'ps_sixthsense_color_scripted' },
					{ label = '#ps.sixthsense_color_other', cvar = 'ps_sixthsense_color_other' },
				}
				for _, option in ipairs(colorOptions) do
					local cvarName = option.cvar
					panel:ControlHelp(language.GetPhrase(option.label))

					local palette = vgui.Create('DColorPalette', panel)
					palette:SetTall(75)
					palette:SetButtonSize(16)
					palette:Reset()
					palette.DoClick = function(_, color)
						GetConVar(cvarName):SetString(string.format(
							'%d,%d,%d',
							math.Round(color.r),
							math.Round(color.g),
							math.Round(color.b)
						))
					end
					panel:AddPanel(palette)
				end

				panel:ControlHelp("Version: " .. (pointshoot and pointshoot.Version or 'Unknown'))
			end
		)
	end)
end
