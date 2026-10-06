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
					ps_key_pointshoot = '0',
					ps_key_sixthsense = '0',
					ps_key_markall = tostring(MOUSE_MIDDLE),
					ps_hud_change = '1',
					ps_hud_full = '0',
					ps_markall_range = '1000',
					ps_markall_ang = '30',
					ps_markall_visible = '1',
				}

				local ctrl = vgui.Create('ControlPresets', panel)
				ctrl:SetPreset('pointshoot_sundry')
				ctrl:AddOption('#preset.default', default)
				for k, v in pairs(default) do ctrl:AddConVar(k) end
				panel:AddPanel(ctrl)

				panel:KeyBinder(language.GetPhrase('#ps.key_mark'), 'ps_key_mark', nil, nil)
				panel:KeyBinder(language.GetPhrase('#ps.key_execute'), 'ps_key_execute', nil, nil)
				panel:KeyBinder(language.GetPhrase('#ps.key_cancel'), 'ps_key_cancel', nil, nil)
				panel:KeyBinder(language.GetPhrase('#ps.key_pointshoot'), 'ps_key_pointshoot', nil, nil)
				panel:KeyBinder(language.GetPhrase('#ps.key_sixthsense'), 'ps_key_sixthsense', nil, nil)
				panel:KeyBinder(language.GetPhrase('#ps.key_markall'), 'ps_key_markall', nil, nil)

				panel:NumSlider(language.GetPhrase('#ps.markall_range'), 'ps_markall_range', 0, 2000, 0)
				panel:NumSlider(language.GetPhrase('#ps.markall_ang'), 'ps_markall_ang', 0, 180, 0)
				panel:CheckBox(language.GetPhrase('#ps.markall_visible'), 'ps_markall_visible')

				panel:CheckBox(language.GetPhrase('#ps.hud_change'), 'ps_hud_change')
				panel:CheckBox(language.GetPhrase('#ps.hud_full'), 'ps_hud_full')
			end
		)
	end)
end
