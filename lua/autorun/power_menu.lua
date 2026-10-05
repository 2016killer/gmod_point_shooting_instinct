AddCSLuaFile()

if CLIENT then
	hook.Add('PopulateToolMenu', 'pointshoot.menu.power', function()
		spawnmenu.AddToolMenuOption('Options', 
			language.GetPhrase('#pointsh.category'), 
			'pointshoot.menu.power', 
			language.GetPhrase('#pointsh.menu.power'), '', '', 
			function(panel)
				local default = {
					ps_buoyancy = '0.1',
					ps_headshot_reward = '0.3',
					ps_power_cost = '0.1',
				}

				local ctrl = vgui.Create('ControlPresets', panel)
				ctrl:SetPreset('pointshoot_power')
				ctrl:AddOption('#preset.default', default)
				for k, v in pairs(default) do ctrl:AddConVar(k) end
				panel:AddPanel(ctrl)

				panel:NumSlider(language.GetPhrase('#ps.buoyancy'), 'ps_buoyancy', 0, 1, 1)
				panel:ControlHelp(language.GetPhrase('#ps.buoyancy.help'))

				panel:NumSlider(language.GetPhrase('#ps.headshot_reward'), 'ps_headshot_reward', 0, 1, 1)
				panel:ControlHelp(language.GetPhrase('#ps.headshot_reward.help'))

				panel:NumSlider(language.GetPhrase('#ps.power_cost'), 'ps_power_cost', 0, 1, 1)
			end
		)
	end)
end
