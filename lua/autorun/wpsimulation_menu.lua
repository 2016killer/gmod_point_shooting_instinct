AddCSLuaFile()

if CLIENT then
	hook.Add('PopulateToolMenu', 'pointshoot.menu.wpsimulation', function()
		spawnmenu.AddToolMenuOption('Options', 
			language.GetPhrase('#pointsh.category'), 
			'pointshoot.menu.wpsimulation', 
			language.GetPhrase('#pointsh.menu.wpsimulation'), '', '', 
			function(panel)
				local default = {
					ps_aim_cost = '0.2',
					ps_rpm_mode = '1',
					ps_rpm_mul = '1',
					ps_damage_mul = '1',
					ps_damage_penetration_mul = '1',
					ps_deploy_duration_mul = '0.8',
				}

				local ctrl = vgui.Create('ControlPresets', panel)
				ctrl:SetPreset('pointshoot_wpsimulation')
				ctrl:AddOption('#preset.default', default)
				for k, v in pairs(default) do ctrl:AddConVar(k) end
				panel:AddPanel(ctrl)

				panel:NumSlider(language.GetPhrase('#ps.aim_cost'), 'ps_aim_cost', 0, 5, 2)

				panel:CheckBox(language.GetPhrase('#ps.rpm_mode'), 'ps_rpm_mode')
				panel:ControlHelp(language.GetPhrase('#ps.rpm_mode.help'))

				panel:NumSlider(language.GetPhrase('#ps.rpm_mul'), 'ps_rpm_mul', 0.1, 5, 1)
				panel:NumSlider(language.GetPhrase('#ps.damage_mul'), 'ps_damage_mul', 0, 5, 1)
				panel:NumSlider(language.GetPhrase('#ps.damage_penetration_mul'), 'ps_damage_penetration_mul', 0, 5, 1)

				panel:NumSlider(language.GetPhrase('#ps.deploy_duration_mul'), 'ps_deploy_duration_mul', 0, 1, 1)
				panel:ControlHelp(language.GetPhrase('#ps.deploy_duration_mul.help'))
			end
		)
	end)
end
