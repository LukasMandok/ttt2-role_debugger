PlayerControl = PlayerControl or {
    c_ply = nil,
    t_ply = nil,

    isActive = false,

    spectator = nil,
}

util.AddNetworkString("playerControllerStartControl")
util.AddNetworkString("playerControllerNet")

net.Receive("playerControllerStartControl", function (len, calling_ply)
    if (calling_ply:IsAdmin() or calling_ply:IsSuperAdmin()) then
        target_ply = net.ReadEntity()
        realFirstPerson = net.ReadBool()
        PlayerControl:StartControl(calling_ply, target_ply, realFirstPerson)
    end
end)

function PlayerControl.NetSend(ply, tbl)
    net.Start("playerControllerNet")
        net.WriteTable(tbl)
    net.Send(ply)
end

function PlayerControl:StartControl(c_ply, t_ply, realFirstPerson)

    if not PlayerControl.isActive then
        -- Add Controlling Hooks
        hook.Add("StartCommand", "playerControllerOverrideCommands", PlayerControl.overrideCommand)

        PlayerControl.isActive = true

        -- Define Tables
        c_ply.controller = {}
        c_ply.controller["t_ply"] = t_ply
        self.c_ply = c_ply

        t_ply.controller = {}
        t_ply.controller["c_ply"] = c_ply
        self.t_ply = t_ply

        -- Make Transition
        self.spectator = StartPCSpectate(c_ply, t_ply, realFirstPerson)


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

        -- Set Some Network Variables:
        t_ply:SetNWBool("playerController_Controlled", true)
    end
end

function PlayerControl:EndControl()
    -- Add Controlling Hooks
    if self.isActive then
        hook.Remove("playerController_Buttons", "playerControllerOverrideCommands")

        -- DO Some transition
        self.spectator:endSpectating()
        self.spectator = nil

        -- Send Message to CLients
        PlayerControl.NetSend(self.c_ply, {
        mode = PC_MODE_END,
        })

        PlayerControl.NetSend(self.t_ply, {
            mode = PC_MODE_END,
        })

        -- Rest Network Variables
        self.c_ply:SetNWInt("playerController_Buttons", 0)
        self.c_ply:SetNWInt("playerController_Impluse", 0)
        
        self.t_ply:SetNWBool("playerController_Controlled", false) --TODO: Brauche ich das überhaupt?

        -- Reset Entries in Players:
        self.c_ply.controller = nil
        self.t_ply.controller = nil

        self.isActive = false
    end    
end

-- TODO: ist nur vorübergehend. EIgentlich sollte der SPectator Mode 
-- vom Player Controller abgebrochen werden und nicht anders rum
hook.Add("PCSpectate_EndSpectating", "Remove Player Control", function (c_ply)
    print(PlayerControl.c_ply, c_ply)
    print("Called End Spectating Hook", PlayerControl.c_ply:Nick(), c_ply:Nick())
    if PlayerControl.c_ply == c_ply then
        print("Terminate PlayerControl")
        PlayerControl:EndControl()
    end
end)

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

        c_ply.controller["viewAngles"] = c_ply:EyeAngles()

        c_ply.controller["ForwardMove"] = cmd:GetForwardMove()
        c_ply.controller["SideMove"] = cmd:GetSideMove()
		c_ply.controller["UpMove"] = cmd:GetUpMove()

		c_ply.controller["MouseWheel"] = cmd:GetMouseWheel()
		c_ply.controller["MouseX"] = cmd:GetMouseX()
		c_ply.controller["MouseY"] = cmd:GetMouseY()

        --print(c_ply.controller["MouseX"])

        cmd:ClearMovement()
        cmd:ClearButtons()
		
    -- Override for the controlled Person
    elseif  ply.controller and ply.controller["c_ply"] then
        local t_ply = ply
        local c_ply = ply.controller["c_ply"]

        if not IsValid(c_ply) then return end

        cmd:SetButtons(c_ply:GetNWInt("playerController_Buttons", 0))
        cmd:SetImpulse(c_ply:GetNWInt("playerController_Impluse", 0))

        t_ply:SetEyeAngles(c_ply.controller["viewAngles"] or t_ply:EyeAngles())
        --print("ViewAngles:", c_ply.controller["viewAngles"], t_ply:EyeAngles())

        --cmd:SetViewAngles(c_ply.controller["ViewAngles"] or t_ply:EyeAngles())
		--ply:SetEyeAngles(c_ply.controller["ViewAngles"] or t_ply:EyeAngles())

		cmd:SetForwardMove(c_ply.controller["ForwardMove"] or 0)
        cmd:SetSideMove(c_ply.controller["SideMove"] or 0)
		cmd:SetUpMove(c_ply.controller["UpMove"] or 0)

		cmd:SetMouseWheel(c_ply.controller["MouseWheel"] or 0)
		cmd:SetMouseX(c_ply.controller["MouseX"] or 0)
		cmd:SetMouseY(c_ply.controller["MouseY"] or 0)

    end

end