PlayerControl = PlayerControl or {}

util.AddNetworkString("playerControllerStartControl")
util.AddNetworkString("playerControllerNet")

net.Receive("playerControllerStartControl", function (len, calling_ply)
    if (calling_ply:IsAdmin() or calling_ply:IsSuperAdmin()) then
        target_ply = net.ReadEntity()
        real_first_person = net.ReadBool()
        PlayerControl.StartControl(calling_ply, target_ply, real_first_person)
    end
end)

function PlayerControl.NetSend(ply, tbl)
    net.Start("playerControllerNet")
        net.WriteTable(tbl)
    net.Send(ply)
end

function PlayerControl.StartControl(c_ply, t_ply, real_first_person)

    -- Add Controlling Hooks
    if not PlayerControl.controllers then
        hook.Add("StartCommand", "playerControllerOverrideCommands", PlayerControl.overrideCommand)
    end

    -- Define Tables
    c_ply.controller = {}
    c_ply.controller["t_ply"] = t_ply
    t_ply.controller = {}
    t_ply.controller["c_ply"] = c_ply

    -- Make Transition
    StartPCSpectate(c_ply, t_ply, real_first_person) --OBS_MODE_IN_EYE
    --c_ply:SpectateEntity(t_ply)
    --c_ply:SetViewEntity(t_ply)

    -- Send initial information to the clients
    PlayerControl.NetSend(c_ply, {
        mode = PC_MODE_START,
        player = t_ply,
        controlling = true,
    })

    PlayerControl.NetSend(t_ply, {
        len = PC_MODE_START,
        player = c_ply,
        controlling = false
    })

end

-----------------------------------
------ Controller Funktions -------
-----------------------------------

function PlayerControl.overrideCommand(ply, cmd)
    -- Override for the controling Person
    if ply.controller and ply.controller["t_ply"] then
        local c_ply = ply
        local t_ply = ply.controller["t_ply"]

        if not IsValid(t_ply) then return end

        c_ply:SetNWInt("playerController_Buttons", cmd:GetButtons())
        c_ply:SetNWInt("playerController_Impluse", cmd:GetImpulse())

        c_ply.controller["viewAngles"] = ply:EyeAngles()

        c_ply.controller["ForwardMove"] = cmd:GetForwardMove()
        c_ply.controller["SideMove"] = cmd:GetSideMove()
		c_ply.controller["UpMove"] = cmd:GetUpMove()

		c_ply.controller["MouseWheel"] = cmd:GetMouseWheel()
		c_ply.controller["MouseX"] = cmd:GetMouseX()
		c_ply.controller["MouseY"] = cmd:GetMouseY()
		
    -- Override for the controlled Person
    elseif  ply.controller and ply.controller["c_ply"] then
        local t_ply = ply
        local c_ply = ply.controller["c_ply"]

        if not IsValid(c_ply) then return end

        cmd:SetButtons(c_ply:GetNWInt("playerController_Buttons", 0))
        cmd:SetImpulse(c_ply:GetNWInt("playerController_Impluse", 0))

        cmd:SetViewAngles(c_ply.controller["ViewAngles"] or t_ply:EyeAngles())
		t_ply:SetEyeAngles(c_ply.controller["ViewAngles"] or t_ply:EyeAngles())

		cmd:SetForwardMove(c_ply.controller["ForwardMove"] or 0)
        cmd:SetSideMove(c_ply.controller["SideMove"] or 0)
		cmd:SetUpMove(c_ply.controller["UpMove"] or 0)

		cmd:SetMouseWheel(c_ply.controller["MouseWheel"] or 0)
		cmd:SetMouseX(c_ply.controller["MouseX"] or 0)
		cmd:SetMouseY(c_ply.controller["MouseY"] or 0)
        
    end

end