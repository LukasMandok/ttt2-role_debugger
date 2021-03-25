hb_playercontroller = hb_playercontroller or {}

print("INITIALIZE PLAYERCONTROLLER CLIENTSIDE")

-- Instructs the Client using data received from the Server.
net.Receive("hb_playercontrollernetwork", function(len)
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local tbl = net.ReadTable()
	
	if tbl.arg == 1 then
		notification.AddLegacy(tbl.message, tbl.type, 5)
		surface.PlaySound(tbl.sound)
	elseif tbl.arg == 2 then
		local msg = ""
		ply.hb_playercontroller = {}
		ply.hb_playercontroller["plyCTRLENT"] = tbl.player
		
		if tbl.controller then
			ply.hb_playercontroller["plyCTRLR"] = true
			ply.hb_playercontroller["plyView"] = 0
			hb_playercontroller.controllerHUD()
			timer.Create("hb_playercontrollerHUDRefresh", 0.5, 0, function()
				if IsValid(ply) and ply.hb_playercontroller and IsValid(ply.hb_playercontroller["plyCTRLENT"]) then
					if tobool(ply.hb_playercontroller.controllerHUDPlyInfoRefresh) then
						ply.hb_playercontroller.controllerHUDPlyInfoRefresh()
					end
					if tobool(ply.hb_playercontroller.controllerHUDPlyWeaponRefresh) then
						ply.hb_playercontroller.controllerHUDPlyWeaponRefresh()
					end
					if gmod.GetGamemode().IsSandboxDerived and tobool(ply.hb_playercontroller.controllerHUDPlySpawnsRefresh) then
						ply.hb_playercontroller.controllerHUDPlySpawnsRefresh()
					end
				end
			end)
			hook.Add("PrePlayerDraw", "hb_playercontrollerOverridePlayerDraw", hb_playercontroller.overridePlayerDraw)
			--hook.Add("CalcView", "hb_playercontrollerOverrideView", hb_playercontroller.overrideView)
			hook.Add("Think", "hb_playercontrollerToggleCursor", hb_playercontroller.toggleCursor)
			if gmod.GetGamemode().IsSandboxDerived then
				cvars.AddChangeCallback("gmod_toolmode", function(nme, vol, vnw)
					hb_playercontroller.networkSendCL(5, vnw)
				end, "hb_playercontrollerToolmode")
			end
			msg = "Now Controlling: "
		else
			ply.hb_playercontroller["plyCTRLD"] = true
			hook.Add("CreateMove", "hb_playercontrollerOverrideCommandCL", hb_playercontroller.overrideCommandCL)
			hook.Add("ContextMenuOpen", "hb_playercontrollerOverrideContextMenu", hb_playercontroller.overrideMenus)
			hook.Add("SpawnMenuOpen", "hb_playercontrollerOverrideSpawnmenu", hb_playercontroller.overrideMenus)
			msg = "Under Control by: "
		end
		
		hook.Add("HUDShouldDraw", "hb_playercontrollerOverrideHUDElements", hb_playercontroller.overrideHUDElements)
		hook.Add("PlayerBindPress", "hb_playercontrollerOverrideBindPress", hb_playercontroller.overrideBindPress)
		notification.AddProgress("hb_playercontrollerCTRL", msg..ply.hb_playercontroller["plyCTRLENT"]:Nick())
		timer.Create("hb_playercontrollerNotice", 5, 0, function()
			notification.Kill("hb_playercontrollerCTRL")
		end)
	elseif tbl.arg == 5 then
		MsgC(Color(255, 64, 64), "[PLAYER CONTROLLER] ", Color(198, 198, 198), tbl.log.."\n")
	elseif ply.hb_playercontroller then
		if tbl.arg == 3 and tobool(ply.hb_playercontroller.controllerHUDPlySpawnsRefresh) then
			ply.hb_playercontroller["entTYPES"] = tbl.spawns
			ply.hb_playercontroller.controllerHUDPlySpawnsRefresh()
		elseif tbl.arg == 4 then
			ply:ConCommand(tbl.command)
			timer.Simple(0.1, function()
				if IsValid(ply) and ply.hb_playercontroller then
					hb_playercontroller.networkSendCL(4)
				end
			end)
		elseif tbl.arg == 6 then
			hb_playercontroller.endControlCL()
		end
	end
end)

-- Ends the control state of the Client.
function hb_playercontroller.endControlCL()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller) then return end
	
	timer.Remove("hb_playercontrollerHUDRefresh")
	if ply.hb_playercontroller.plyMenu then
		ply.hb_playercontroller.plyMenu:Remove()
	end
	cvars.RemoveChangeCallback("gmod_toolmode", "hb_playercontrollerToolmode")
	hook.Remove("PrePlayerDraw", "hb_playercontrollerOverridePlayerDraw")
	--hook.Remove("CalcView", "hb_playercontrollerOverrideView")
	hook.Remove("CreateMove", "hb_playercontrollerOverrideCommandCL")
	hook.Remove("ContextMenuOpen", "hb_playercontrollerOverrideContextMenu")
	hook.Remove("SpawnMenuOpen", "hb_playercontrollerOverrideSpawnmenu")
	hook.Remove("HUDShouldDraw", "hb_playercontrollerOverrideHUDElements")
	hook.Remove("Think", "hb_playercontrollerToggleCursor")
	hook.Remove("PlayerBindPress", "hb_playercontrollerOverrideBindPress")
	gui.EnableScreenClicker(false)
	timer.Remove("hb_playercontrollerNotice")
	notification.Kill("hb_playercontrollerCTRL")
	ply.hb_playercontroller = nil
end

-- Networks the passed Arguments to the Server.
function hb_playercontroller.networkSendCL(arg, ex1, ex2)
	net.Start("hb_playercontrollernetwork")
		net.WriteInt(arg, 6)
		
		if arg == 1 then
			net.WriteBool(ex1)
			
			if not (ex1) then
				net.WriteString(ex2)
			end
		elseif arg == 2 or arg == 5 then
			net.WriteString(ex1)
		elseif arg == 7 then
			net.WriteBool(ex1)
		end
	net.SendToServer()
end

-- Overrides the Controlled Client's commands to simulate control locally.
function hb_playercontroller.overrideCommandCL(cmd)
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLD"]) then return end
	local ctrlr = ply.hb_playercontroller["plyCTRLENT"]
	if not IsValid(ctrlr) then return end
	
	cmd:ClearMovement()
	cmd:SetButtons(ctrlr:GetNWInt("hb_playercontrollerCMDButtons", 0))
	cmd:SetImpulse(ctrlr:GetNWInt("hb_playercontrollerCMDImpulse", 0))
end

function hb_playercontroller.toggleCursor()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"]) then return end
	
	if input.IsKeyDown(KEY_F6) then
		if not ply.hb_playercontroller["plyKEYHELDF6"] and not ply.hb_playercontroller["plyCURSORVISIBLE"] then
			ply.hb_playercontroller["plyKEYHELDF6"] = true
			ply.hb_playercontroller["plyCURSORVISIBLE"] = true
			gui.EnableScreenClicker(true)
			
			if ply.hb_playercontroller["plyCURSORPOS"] then
				input.SetCursorPos(ply.hb_playercontroller["plyCURSORPOS"][1], ply.hb_playercontroller["plyCURSORPOS"][2])
				ply.hb_playercontroller["plyCURSORPOS"] = nil
			end
		elseif not ply.hb_playercontroller["plyKEYHELDF6"] then
			ply.hb_playercontroller["plyKEYHELDF6"] = true
			ply.hb_playercontroller["plyCURSORPOS"] = {input.GetCursorPos()}
			ply.hb_playercontroller["plyCURSORVISIBLE"] = nil
			gui.EnableScreenClicker(false)
		end
	else
		ply.hb_playercontroller["plyKEYHELDF6"] = nil
	end
	
	if input.IsKeyDown(KEY_F7) then
		if not ply.hb_playercontroller["plyKEYHELDF7"] then
			ply.hb_playercontroller["plyKEYHELDF7"] = true
			ply.hb_playercontroller.plyMenu.menuHide:Toggle()
		end
	else
		ply.hb_playercontroller["plyKEYHELDF7"] = nil
	end
	
	if input.IsKeyDown(KEY_F8) then
		if not ply.hb_playercontroller["plyKEYHELDF8"] then
			ply.hb_playercontroller["plyKEYHELDF8"] = true
			hb_playercontroller.networkSendCL(6)
			hb_playercontroller.endControlCL()
		end
	else
		ply.hb_playercontroller["plyKEYHELDF8"] = nil
	end
end

-- Overrides the Client's Key Binds.
function hb_playercontroller.overrideBindPress(ply, str, psd)
	if not (IsValid(ply) or ply.hb_playercontroller) then return end
	
	if ply.hb_playercontroller["plyCTRLR"] then
		local strl = string.lower(str)
		
		if str == input.LookupKeyBinding(KEY_F6) or str == input.LookupKeyBinding(KEY_F7) or str == input.LookupKeyBinding(KEY_F8) then
			return true
		elseif (strl == "undo" or strl == "gmod_undo") and psd then
			hb_playercontroller.networkSendCL(3)
			return true
		elseif strl == "impulse 100" and psd then
			hb_playercontroller.networkSendCL(7, false)
		elseif strl == "noclip" or strl == "impulse 154" and psd then
			hb_playercontroller.networkSendCL(7, true)
		elseif (strl == "invnext" or strl == "invprev") and psd and ply:KeyDown(IN_WALK) then
			if strl == "invnext" then
				ply.hb_playercontroller["plyView"] = math.Clamp(ply.hb_playercontroller["plyView"] + 5, 100, 300)
			else
				ply.hb_playercontroller["plyView"] = math.Clamp(ply.hb_playercontroller["plyView"] - 5, 100, 300)
			end
			return true
		elseif (strl == "invnext" or strl == "invprev") and psd and not ply:KeyDown(IN_ATTACK) then
			ctrld = ply.hb_playercontroller["plyCTRLENT"]
			if not IsValid(ctrld) then return end
			local weps = ctrld:GetWeapons()
			local actv = table.KeyFromValue(weps, ctrld:GetActiveWeapon())
			if not actv then return end
			
			if strl == "invnext" then
				actv = actv + 1
				if actv > #weps then
					actv = 1
				end
			else
				actv = actv - 1
				if actv < 1 then
					actv = #weps
				end
			end
			
			hb_playercontroller.networkSendCL(2, weps[actv]:GetClass())
			return true
		end
	elseif (ply.hb_playercontroller["plyCTRLD"]) then
		return true
	end
end

-- Disables HUD elements for the Client.
function hb_playercontroller.overrideHUDElements(hud)
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller) then return end
	
	if ply.hb_playercontroller["plyCTRLR"] or ply.hb_playercontroller["plyCTRLD"] then
		if hud == "CHudWeaponSelection" then
			return false
		end
	end
end

-- Disables the Controlled Player's Spawnmenu and Context Menu.
function hb_playercontroller.overrideMenus()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLD"]) then return end
	
	return false
end

-- Disables drawing of the Controlled Player when in Firstperson.
function hb_playercontroller.overridePlayerDraw(ctrld)
	local ply = LocalPlayer()
	if not IsValid(ctrld) or ctrld ~= ply.hb_playercontroller["plyCTRLENT"] then return end
	return true
	-- if ply.hb_playercontroller.plyViewRestore then
    --     return true
	-- end
end

-- Overrides the view of the Player Controller.
-- function hb_playercontroller.overrideView(ply, pos, ang, fov)
-- 	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"]) then return end
-- 	local ctrld = ply.hb_playercontroller["plyCTRLENT"]
-- 	if not IsValid(ctrld) then return end
-- 	local view = {}
	
-- 	if ply.hb_playercontroller["plyView"] <= 100 and GetViewEntity() == ply then
-- 		ply.hb_playercontroller.plyViewRestore = true
-- 		view.origin = ctrld:EyePos()
-- 	else
-- 		ply.hb_playercontroller.plyViewRestore = nil
		
-- 		if GetViewEntity() == ply then
-- 			view.origin = (ctrld:GetPos() + ctrld:GetCurrentViewOffset()) - (ang:Forward() * ply.hb_playercontroller["plyView"])
-- 		end
-- 	end
	 
-- 	return view
-- end

-- function hb_playercontroller.overrideViewModel(wep, ply, oldPos, oldAng, pos, ang)
--     local ply = LocalPlayer()
--     if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLD"]) then return end

--     return pos, ang
-- end

-- Controls HUD elements for when the Client is a Controller.
function hb_playercontroller.controllerHUD()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"]) then return end
	local ctrld = ply.hb_playercontroller["plyCTRLENT"]
	if not IsValid(ctrld) then return end
	local gmd = gmod.GetGamemode()
	
	ply.hb_playercontroller.plyMenu = vgui.Create("DFrame")
	ply.hb_playercontroller.plyMenu:SetTitle("Player Controller (F8: Cease Control)")
	ply.hb_playercontroller.plyMenu:SetDraggable(false)
	ply.hb_playercontroller.plyMenu:SetMouseInputEnabled(false)
	ply.hb_playercontroller.plyMenu:SetSize(300, 370)
	ply.hb_playercontroller.plyMenu:SetPos(-ply.hb_playercontroller.plyMenu:GetWide(), ScrH() / 5)
	ply.hb_playercontroller.plyMenu:MoveTo(0, ScrH() / 5, 0.4, 0, -1, function(tbl, pnl)
		ply.hb_playercontroller.plyMenu.menuHide:Toggle()
		pnl:SetMouseInputEnabled(true)
	end)
	function ply.hb_playercontroller.plyMenu:OnClose()
		hb_playercontroller.networkSendCL(6)
		hb_playercontroller.endControlCL()
	end
	ply.hb_playercontroller.plyMenu.Paint = function(self, w, h)
		draw.RoundedBoxEx(6, 0, 0, w - 4.8, 30, Color(0, 0, 0, 255), false, true, false, true)
	end
	
	ply.hb_playercontroller.plyMenu.menuHide = vgui.Create("DCollapsibleCategory", ply.hb_playercontroller.plyMenu)
	ply.hb_playercontroller.plyMenu.menuHide:SetPos(0, 20)
	ply.hb_playercontroller.plyMenu.menuHide:SetSize(ply.hb_playercontroller.plyMenu:GetWide() - 5, 100)
	ply.hb_playercontroller.plyMenu.menuHide:SetLabel("[CLICK HERE OR PRESS F7 TO SHOW/HIDE MENU]")
	ply.hb_playercontroller.plyMenu.menuHide:SetExpanded(false)
	
	ply.hb_playercontroller.plyMenu.menuHide.bindWalk = input.LookupBinding("+walk", true) or "\"+walk\""
	ply.hb_playercontroller.plyMenu.menuHide.bindInvNext = input.LookupBinding("invnext", true) or "\"invnext\""
	ply.hb_playercontroller.plyMenu.menuHide.bindInvPrev = input.LookupBinding("invprev", true) or "\"invprev\""
	ply.hb_playercontroller.plyMenu.menuHide.bindUndo = input.LookupBinding("undo", true) or input.LookupBinding("gmod_undo", true) or "\"gmod_undo\""
	ply.hb_playercontroller.plyMenu.menuHide:SetTooltip(
		"Player Controller Help\n\n"..
		"- -GENERAL USAGE- -\n"..
		"[Cease Control]: Press F8 or the 'X' Button at the top of the Menu to release control of your Victim\n"..
		"[Bots]: Bots have a few limitations to their control. Visit the addon's Workshop page for specifics\n"..
		"[Clean Up Type]: Left-click an entry under Spawn Management to clean up everything of the selected type owned by your Victim (Sandbox Derived Only)\n"..
		"[Clean Up Everything]: Right-click an entry under Spawn Management to clean up everything owned by your Victim (Sandbox Derived Only)\n\n"..
		"- -BINDS USAGE- -\n"..
		"["..string.upper(ply.hb_playercontroller.plyMenu.menuHide.bindWalk.." + "..ply.hb_playercontroller.plyMenu.menuHide.bindInvPrev.."/"..ply.hb_playercontroller.plyMenu.menuHide.bindInvNext).."]: Zoom your camera view in/out\n"..
		"["..string.upper(ply.hb_playercontroller.plyMenu.menuHide.bindInvPrev.."/"..ply.hb_playercontroller.plyMenu.menuHide.bindInvNext).."]: Cycles through your Victim's weapons for use\n"..
		"["..string.upper(ply.hb_playercontroller.plyMenu.menuHide.bindUndo).."]: Undo the last thing done by your Victim\n\n"..
		"- -CHAT USAGE- -\n"..
		"[Message]: Sending chat messages as normal will instead be sent as your Victim\n"..
		"[!! Message]: Appending '!!' before a message will execute it as a Console Command on your Victim\n"..
		"[!!! Message]: Appending '!!!' before a message will send the message as yourself, not your Victim"
	)
	
	ply.hb_playercontroller.plyMenu.menuHide.Paint = function(self, w, h)
		draw.RoundedBoxEx(6, 0, 0, w, h, Color(0, 0, 0, 255), false, false, false, true)
		draw.RoundedBoxEx(6, 0, 2, w, 16, Color(255, 0, 0, 255), false, true, false, true)
	end
	
	ply.hb_playercontroller.plyMenu.menuInfoLabel = vgui.Create("DLabel", ply.hb_playercontroller.plyMenu.menuHide)
	ply.hb_playercontroller.plyMenu.menuInfoLabel:SetPos(5, 16)
	ply.hb_playercontroller.plyMenu.menuInfoLabel:SetSize(ply.hb_playercontroller.plyMenu.menuHide:GetWide() - 5, 20)
	ply.hb_playercontroller.plyMenu.menuInfoLabel:SetText("Victim Information")
	
	ply.hb_playercontroller.plyMenu.menuInfo = vgui.Create("DListView", ply.hb_playercontroller.plyMenu.menuHide)
	ply.hb_playercontroller.plyMenu.menuInfo:SetMouseInputEnabled(false)
	ply.hb_playercontroller.plyMenu.menuInfo:SetPos(0, 32)
	ply.hb_playercontroller.plyMenu.menuInfo:SetSize(ply.hb_playercontroller.plyMenu:GetWide() - 5, 105)
	ply.hb_playercontroller.plyMenu.menuInfo:AddColumn("Info")
	ply.hb_playercontroller.plyMenu.menuInfoValue = ply.hb_playercontroller.plyMenu.menuInfo:AddColumn("Data")
	ply.hb_playercontroller.plyMenu.menuInfoValue:SetWidth(220)
	function ply.hb_playercontroller.controllerHUDPlyInfoRefresh()
		if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"] or ply.hb_playercontroller.plyMenu.menuInfo) then return end
		
		ply.hb_playercontroller.plyMenu.menuInfo:Clear()
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Name", ctrld:Nick())
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Team", team.GetName(ctrld:Team()))
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Usergroup", ctrld:GetUserGroup())
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Health", ctrld:Health().." / "..ctrld:GetMaxHealth().." (Armor: "..ctrld:Armor()..")")
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Ping", ctrld:Ping().." (Yours: "..ply:Ping()..")")
	end
	
	ply.hb_playercontroller.plyMenu.menuWeaponLabel = vgui.Create("DLabel", ply.hb_playercontroller.plyMenu.menuHide)
	ply.hb_playercontroller.plyMenu.menuWeaponLabel:SetPos(5, 134)
	ply.hb_playercontroller.plyMenu.menuWeaponLabel:SetSize(ply.hb_playercontroller.plyMenu.menuHide:GetWide() - 5, 20)
	ply.hb_playercontroller.plyMenu.menuWeaponLabel:SetText("Weapon Selection")
	
	ply.hb_playercontroller.plyMenu.menuWeapon = vgui.Create("DComboBox", ply.hb_playercontroller.plyMenu.menuHide)
	ply.hb_playercontroller.plyMenu.menuWeapon:SetPos(0, 152)
	ply.hb_playercontroller.plyMenu.menuWeapon:SetSize(ply.hb_playercontroller.plyMenu:GetWide() - 5, 20)
	function ply.hb_playercontroller.controllerHUDPlyWeaponRefresh()
		if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"] or ply.hb_playercontroller.plyMenu.menuWeapon) then return end
		
		if not ply.hb_playercontroller.plyMenu.menuWeapon:IsMenuOpen() then
			ply.hb_playercontroller.plyMenu.menuWeapon:Clear()
			ply.hb_playercontroller.plyMenu.menuWeapon:SetValue("(No Weapons)")
			local ctrldActiveWeapon = ctrld:GetActiveWeapon()
			
			if IsValid(ctrldActiveWeapon) then
				ply.hb_playercontroller.plyMenu.menuWeapon:SetValue(ctrldActiveWeapon:GetPrintName())
			end
			for k, v in ipairs(ctrld:GetWeapons()) do
				ply.hb_playercontroller.plyMenu.menuWeapon:AddChoice(v:GetPrintName(), v:GetClass())
			end
		end
	end
	function ply.hb_playercontroller.plyMenu.menuWeapon:OnSelect(idx, val, dat)
		hb_playercontroller.networkSendCL(2, dat)
	end
	
	if gmd.IsSandboxDerived then
		ply.hb_playercontroller.plyMenu.menuSpawnsLabel = vgui.Create("DLabel", ply.hb_playercontroller.plyMenu.menuHide)
		ply.hb_playercontroller.plyMenu.menuSpawnsLabel:SetPos(5, 170)
		ply.hb_playercontroller.plyMenu.menuSpawnsLabel:SetSize(ply.hb_playercontroller.plyMenu.menuHide:GetWide() - 5, 20)
		ply.hb_playercontroller.plyMenu.menuSpawnsLabel:SetText("Spawns Management")
	
		ply.hb_playercontroller.plyMenu.menuSpawns = vgui.Create("DListView", ply.hb_playercontroller.plyMenu.menuHide)
		ply.hb_playercontroller.plyMenu.menuSpawns:SetPos(0, 188)
		ply.hb_playercontroller.plyMenu.menuSpawns:SetSize(ply.hb_playercontroller.plyMenu:GetWide() - 5, 120)
		ply.hb_playercontroller.plyMenu.menuSpawns:SetMultiSelect(false)
		ply.hb_playercontroller.plyMenu.menuSpawnsType = ply.hb_playercontroller.plyMenu.menuSpawns:AddColumn("Type")
		ply.hb_playercontroller.plyMenu.menuSpawnsType:SetSize(ply.hb_playercontroller.plyMenu:GetWide() - 80, 85)
		ply.hb_playercontroller.plyMenu.menuSpawns:AddColumn("Count")
		function ply.hb_playercontroller.controllerHUDPlySpawnsRefresh()
			if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"] or ply.hb_playercontroller.plyMenu.menuSpawns) then return end
			
			if ply.hb_playercontroller["entTYPES"] then
				ply.hb_playercontroller.plyMenu.menuSpawns:Clear()
				for k, v in ipairs(ply.hb_playercontroller["entTYPES"]) do
					ply.hb_playercontroller.plyMenu.menuSpawns:AddLine(string.upper(string.sub(v, 1, 1))..string.Replace(string.sub(v, 2), "_", " "), ctrld:GetCount(v).." / "..cvars.Number("sbox_max"..v, "?"))
				end
			end
		end
		function ply.hb_playercontroller.plyMenu.menuSpawns:OnRowSelected(idx, row)
			if input.IsMouseDown(MOUSE_LEFT) then
				hb_playercontroller.networkSendCL(1, false, row:GetValue(1))
			elseif input.IsMouseDown(MOUSE_RIGHT) then
				hb_playercontroller.networkSendCL(1, true)
			end
		end
	end
	
	ply.hb_playercontroller.plyMenu.menuHelpLabel = vgui.Create("DLabel", ply.hb_playercontroller.plyMenu.menuHide)
	if gmd.IsSandboxDerived then
		ply.hb_playercontroller.plyMenu.menuHelpLabel:SetPos(5, 306)
	else
		ply.hb_playercontroller.plyMenu.menuHelpLabel:SetPos(5, 172)
	end
	ply.hb_playercontroller.plyMenu.menuHelpLabel:SetSize(ply.hb_playercontroller.plyMenu.menuHide:GetWide() - 5, 30)
	ply.hb_playercontroller.plyMenu.menuHelpLabel:SetText("USE MENU: Press F6 to toggle your Cursor for Menu use\nMORE INFO: Hover your Mouse over the Menu for help")
end