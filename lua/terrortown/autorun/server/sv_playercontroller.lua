PlayerControl = PlayerControl or {
    -- TODO: Diese Zuweisung bringt wahrscheinlich nichts
    c_ply = nil,
    t_ply = nil,

    isActive = false,

    spectator = nil,
}

util.AddNetworkString("PlayerController:StartControl")
util.AddNetworkString("PlayerController:EndControl")
util.AddNetworkString("PlayerController:Net")
util.AddNetworkString("PlayerController:NetCl")

util.AddNetworkString("PlayerController:TargetAngle")

net.Receive("PlayerController:StartControl", function (len, calling_ply)
    if (calling_ply:IsAdmin() or calling_ply:IsSuperAdmin()) then
        local target_ply = net.ReadEntity()
        local thirdperson = net.ReadBool()
        local roaming = net.ReadBool()
        local realFirstPerson = net.ReadBool()
        PlayerControl:StartControl(calling_ply, target_ply, thirdperson, roaming, realFirstPerson)
    end
end)

net.Receive("playerControllerEndontrol", function (len, calling_ply)
    if (calling_ply:IsAdmin() or calling_ply:IsSuperAdmin()) then
        PlayerControl:EndControl()
    end
end)

function PlayerControl.NetSend(ply, tbl)
    net.Start("PlayerController:Net")
        net.WriteTable(tbl)
    net.Send(ply)
end

function PlayerControl:StartControl(c_ply, t_ply, thirdperson, roaming, realFirstPerson)

    if not self.isActive then
        print("Running Server Hooks to start Control")
        -- Add Controlling Hooks
        hook.Add("StartCommand", "PlayerController:OverrideCommands", PlayerControl.overrideCommand)
        hook.Add("SetupMove", "PlayerController:SetupMove", PlayerControl.setupMove)
        hook.Add("Move", "PlayerController:DisableControllerMovment", PlayerControl.disableMovment)

        hook.Add("WeaponEquip", "PlayerController:UpdateTargetInventory", function(wep, ply) PlayerControl.updateInventory(ply, wep) end)
        hook.Add("PlayerDroppedWeapon", "PlayerController:UpdateTargetInventory", PlayerControl.updateInventory)

        self.isActive = true

        -- Define Tables
        c_ply.controller = {}
        c_ply.controller["t_ply"] = t_ply
        self.c_ply = c_ply

        t_ply.controller = {}
        t_ply.controller["c_ply"] = c_ply
        self.t_ply = t_ply

        -- t_ply:InstallDataTable()
        -- t_ply:SetupDataTables()

        -- Make Transition
        --self.spectator = StartPCSpectate(c_ply, t_ply, realFirstPerson)


        -- Send initial information to the clients
        PlayerControl.NetSend(self.c_ply, {
            mode = PC_SV_START,
            player = self.t_ply,
            thirdperson = thirdperson,
            roaming = roaming,
            controlling = true,
        })

        PlayerControl.NetSend(self.t_ply, {
            mode = PC_SV_START,
            player = self.c_ply,
            controlling = false
        })

        -- Set Some Network Variables:
        self.t_ply:SetNWBool("playerController_Controlled", true)

        -- Start driver:
        --self.c_ply:SetViewEntity(self.t_ply)
        --drive.Start(self.c_ply, self.t_ply)

        print("Update Inventory!")
        self.updateInventory(self.t_ply)
    end
end

function PlayerControl:EndControl()
    -- Add Controlling Hooks
    if self.isActive then
        hook.Remove("StartCommand", "PlayerController:OverrideCommands")

        hook.Remove("SetupMove", "PlayerController:SetupMove")
        hook.Remove("Move", "PlayerController:DisableControllerMovment")

        hook.Remove("WeaponEquip", "PlayerController:UpdateTargetInventory")
        hook.Remove("PlayerDroppedWeapon", "PlayerController:UpdateTargetInventory")
        -- Start driver:

        --drive.End(self.c_ply, self.t_ply)
        --self.c_ply:SetViewEntity(cam)

        -- DO Some transition
        --self.spectator:endSpectating()
        --self.spectator = nil

        -- Send Message to CLients
        PlayerControl.NetSend(self.c_ply, {
            mode = PC_SV_END,
        })

        PlayerControl.NetSend(self.t_ply, {
            mode = PC_SV_END,
        })

        -- Rest Network Variables
        self.c_ply:SetNWInt("playerController_Buttons", 0)
        self.c_ply:SetNWInt("playerController_Impluse", 0)

        self.t_ply:SetNWBool("playerController_Controlled", false) --TODO: Brauche ich das überhaupt?

        -- Reset Entries in Players:
        self.c_ply.controller = nil
        self.t_ply.controller = nil

        self.c_ply = nil
        self.t_ply = nil

        self.isActive = nil
    end
end

-- TODO: ist nur vorübergehend. EIgentlich sollte der SPectator Mode 
-- vom Player Controller abgebrochen werden und nicht anders rum
-- hook.Add("PCSpectate_EndSpectating", "Remove Player Control", function (c_ply)
--     print(PlayerControl.c_ply, c_ply)
--     print("Called End Spectating Hook", PlayerControl.c_ply:Nick(), c_ply:Nick())
--     if PlayerControl.c_ply == c_ply then
--         print("Terminate PlayerControl")
--         PlayerControl:EndControl()
--     end
-- end)

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

        c_ply.controller["viewAngles"] = cmd:GetViewAngles()--c_ply:EyeAngles()

        c_ply.controller["ForwardMove"] = cmd:GetForwardMove()
        c_ply.controller["SideMove"] = cmd:GetSideMove()
        c_ply.controller["UpMove"] = cmd:GetUpMove()

        c_ply.controller["MouseWheel"] = cmd:GetMouseWheel()
        c_ply.controller["MouseX"] = cmd:GetMouseX()
        c_ply.controller["MouseY"] = cmd:GetMouseY()

        --cmd:ClearMovement()
        --cmd:ClearButtons()


    -- Override for the controlled Person
    elseif  ply.controller and ply.controller["c_ply"] then
        local t_ply = ply
        local c_ply = ply.controller["c_ply"]

        if not IsValid(c_ply) then return end

        cmd:SetButtons(c_ply:GetNWInt("playerController_Buttons", 0))
        cmd:SetImpulse(c_ply:GetNWInt("playerController_Impluse", 0))

        --t_ply:SetEyeAngles(c_ply.controller["viewAngles"] or t_ply:EyeAngles())
        --print("ViewAngles:", c_ply.controller["viewAngles"], t_ply:EyeAngles())

        --cmd:SetViewAngles(c_ply.controller["ViewAngles"] or t_ply:EyeAngles())

        cmd:SetForwardMove(c_ply.controller["ForwardMove"] or 0)
        cmd:SetSideMove(c_ply.controller["SideMove"] or 0)
        cmd:SetUpMove(c_ply.controller["UpMove"] or 0)

        cmd:SetMouseWheel(c_ply.controller["MouseWheel"] or 0)
        cmd:SetMouseX(c_ply.controller["MouseX"] or 0)
        cmd:SetMouseY(c_ply.controller["MouseY"] or 0)


    -- elseif ply == player.GetBots()[2] then
    --     local t_ply = ply
    --     local c_ply = PlayerControl.c_ply

    --     if not IsValid(c_ply) then return end

    --     cmd:SetButtons(c_ply:GetNWInt("playerController_Buttons", 0))
    --     cmd:SetImpulse(c_ply:GetNWInt("playerController_Impluse", 0))

    --     t_ply:SetEyeAngles(c_ply.controller["viewAngles"] or t_ply:EyeAngles())
    --     --print("ViewAngles:", c_ply.controller["viewAngles"], t_ply:EyeAngles())

    --     cmd:SetViewAngles(c_ply.controller["ViewAngles"] or t_ply:EyeAngles())

    -- 	cmd:SetForwardMove(c_ply.controller["ForwardMove"] or 0)
    --     cmd:SetSideMove(c_ply.controller["SideMove"] or 0)
    -- 	cmd:SetUpMove(c_ply.controller["UpMove"] or 0)

    -- 	cmd:SetMouseWheel(c_ply.controller["MouseWheel"] or 0)
    -- 	cmd:SetMouseX(c_ply.controller["MouseX"] or 0)
    -- 	cmd:SetMouseY(c_ply.controller["MouseY"] or 0)
    end
end

-- Update Target Inventory:
PlayerControl.updateInventory = function(ply, wep)
    if IsValid(ply) and ply == PlayerControl.t_ply then
        print("SERVER: Updating Inventory:", PlayerControl.t_ply:Nick(), "Hat ", wep, "aufgehoben. Send to:", PlayerControl.c_ply:Nick())
        timer.Simple(0.1, function()
            PlayerControl.NetSend(PlayerControl.c_ply, {
                mode = PC_SV_INVENTORY,
                player = PlayerControl.t_ply,
                inventory = PlayerControl.t_ply:GetInventory()
            })
        end)
    end
end


--- Communication

net.Receive("PlayerController:TargetAngle", function (len, calling_ply)
    local angle = net.ReadAngle()
    --print("Setting Eye Angles", angle)
    if calling_ply == PlayerControl.c_ply then
        PlayerControl.t_ply:SetEyeAngles(angle or PlayerControl.t_ply:EyeAngles())
    end
end)

net.Receive("PlayerController:NetCl", function (len, c_ply)
    local mode = net.ReadInt(6)

    if c_ply == PlayerControl.c_ply then

        local t_ply = PlayerControl.t_ply

        -- Select Weapon
        if mode == PC_CL_WEAPON then
            local wep = net.ReadString()

            print("Select Weapon:", wep)

            t_ply:SelectWeapon(wep)

        -- Drop Weapon
        elseif mode == PC_CL_DROP_WEAPON then
            local wep = net.ReadEntity()

            if wep.AllowDrop then
                print("Drop Weapon.", wep)

                t_ply:DropWeapon(wep)
            end

        -- Request Inventory:
        elseif mode == PC_CL_INVENTORY then
            print("NetCl: Send inventory of Player: " .. t_ply:Nick() .. " to player: ", c_ply:Nick())
            PlayerControl.updateInventory(t_ply)
            -- PlayerControl.NetSend(c_ply, {
            --     mode = PC_SV_INVENTORY,
            --     player = t_ply,
            --     inventory = t_ply:GetInventory()
            -- })
        end
    end
end)





-- function PlayerControl.finishMove(ply, mv)
--     if ply.controller and ply.controller["t_ply"]  then
--         print("finish Move")
--         return true
--     end
-- end

-- function GM:Move(ply, mv)
--     return true
--     -- if ply.controller and ply.controller["t_ply"] then
--     --     return true
--     -- end
-- end
