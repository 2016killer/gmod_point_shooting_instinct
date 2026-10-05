AddCSLuaFile()

if CLIENT then
	hook.Add('PopulateToolMenu', 'pointshoot.menu.sundry', function()
		spawnmenu.AddToolMenuOption('Options', 
			language.GetPhrase('#pointsh.category'), 
			'pointshoot.menu.sundry', 
			language.GetPhrase('#pointsh.menu.sundry'), '', '', 
			function(panel)
				local default = {
					ps_key_mark = '107',
					ps_key_execute = '108',
					ps_key_cancel = '12',
					ps_hud_change = '1',
					ps_hud_full = '0',
				}

				local ctrl = vgui.Create('ControlPresets', panel)
				ctrl:SetPreset('pointshoot_sundry')
				ctrl:AddOption('#preset.default', default)
				for k, v in pairs(default) do ctrl:AddConVar(k) end
				panel:AddPanel(ctrl)

				panel:KeyBinder(language.GetPhrase('#ps.key_mark'), 'ps_key_mark', nil, nil)
				panel:KeyBinder(language.GetPhrase('#ps.key_execute'), 'ps_key_execute', nil, nil)
				panel:KeyBinder(language.GetPhrase('#ps.key_cancel'), 'ps_key_cancel', nil, nil)

				panel:CheckBox(language.GetPhrase('#ps.hud_change'), 'ps_hud_change')
				panel:CheckBox(language.GetPhrase('#ps.hud_full'), 'ps_hud_full')
			end
		)
	end)
end
