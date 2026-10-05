AddCSLuaFile()

if CLIENT then
	hook.Add('PopulateToolMenu', 'pointshoot.menu.state', function()
		spawnmenu.AddToolMenuOption('Options', 
			language.GetPhrase('#pointsh.category'), 
			'pointshoot.menu.state', 
			language.GetPhrase('#pointsh.menu.state'), '', '', 
			function(panel)
				local default = {
					ps_invincible = '1',
					ps_timescale_mark = '0.1',
					ps_timescale_execute = '0.3',
					ps_timescale_finish = '0.1',
					ps_timescale_mp_disable = '1',
				}

				local ctrl = vgui.Create('ControlPresets', panel)
				ctrl:SetPreset('pointshoot_state')
				ctrl:AddOption('#preset.default', default)
				for k, v in pairs(default) do ctrl:AddConVar(k) end
				panel:AddPanel(ctrl)

				panel:CheckBox(language.GetPhrase('#ps.invincible'), 'ps_invincible')

				panel:NumSlider(language.GetPhrase('#ps.timescale_mark'), 'ps_timescale_mark', 0, 1, 2)
				panel:NumSlider(language.GetPhrase('#ps.timescale_execute'), 'ps_timescale_execute', 0, 1, 2)
				panel:NumSlider(language.GetPhrase('#ps.timescale_finish'), 'ps_timescale_finish', 0, 1, 2)

				panel:CheckBox(language.GetPhrase('#ps.timescale_mp_disable'), 'ps_timescale_mp_disable')
				panel:ControlHelp(language.GetPhrase('#ps.timescale_mp_disable.help'))
			end
		)
	end)
end
