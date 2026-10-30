AddCSLuaFile()

if CLIENT then
	hook.Add('PopulateToolMenu', 'pointshoot.menu.sixthsense', function()
		spawnmenu.AddToolMenuOption('Options', 
			language.GetPhrase('#pointsh.category'), 
			'pointshoot.menu.sixthsense', 
			language.GetPhrase('#pointsh.menu.sixthsense'), '', '', 
			function(panel)
				local default = {
					ps_sixthsense_range = '1000',
					ps_sixthsense_cost = '0.3',
					ps_sixthsense_ent_limit = '30',
					ps_sixthsense_duration = '1',
					ps_sixthsense_expand_time = '1',
					ps_sixthsense_scan_players = '1',
					ps_sixthsense_scan_npcs = '1',
					ps_sixthsense_scan_grenades = '1',
					ps_sixthsense_scan_vehicles = '1',
					ps_sixthsense_scan_breakables = '1',
				}

				local ctrl = vgui.Create('ControlPresets', panel)
				ctrl:SetPreset('pointshoot_sixthsense')
				ctrl:AddOption('#preset.default', default)
				for k, v in pairs(default) do ctrl:AddConVar(k) end
				panel:AddPanel(ctrl)

				panel:NumSlider(language.GetPhrase('#ps.sixthsense_range'), 'ps_sixthsense_range', 100, 2000, 0)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_cost'), 'ps_sixthsense_cost', 0, 1, 2)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_ent_limit'), 'ps_sixthsense_ent_limit', 10, 60, 0)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_duration'), 'ps_sixthsense_duration', 0, 5, 1)
				panel:NumSlider(language.GetPhrase('#ps.sixthsense_expand_time'), 'ps_sixthsense_expand_time', 0.1, 5, 2)
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_players'), 'ps_sixthsense_scan_players')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_npcs'), 'ps_sixthsense_scan_npcs')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_grenades'), 'ps_sixthsense_scan_grenades')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_vehicles'), 'ps_sixthsense_scan_vehicles')
				panel:CheckBox(language.GetPhrase('#ps.sixthsense_scan_breakables'), 'ps_sixthsense_scan_breakables')

				panel:ControlHelp("Version: " .. (pointshoot and pointshoot.Version or 'Unknown'))
			end
		)
	end)
end
