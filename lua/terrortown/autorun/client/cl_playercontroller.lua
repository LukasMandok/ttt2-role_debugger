PlayerControl = PlayerControl or {}

function PlayerControl.NetSendCl(mode, arg1, arg2)
    net.Start("PlayerController:NetCl")
        net.WriteInt(mode, 6)

        if mode == PC_CL_WEAPON then
            net.WriteString(arg1)

        elseif mode == PC_CL_DROP_WEAPON then
            net.WriteEntity(arg1)

        elseif mode == PC_CL_INVENTORY then
            -- nothing more
        end

    net.SendToServer()
end

net.Receive("PlayerController:Net", function (len)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local tbl = net.ReadTable()

    -- START
    if tbl.mode == PC_SV_START then
        --MsgC(Color(255, 64, 64), "[PLAYER CONTROLLER] ", Color(198, 198, 198), tbl.log.."\n")

        -- Set the table to the player
        ply.controller = {}

        -- If controlling Player
        if tbl.controlling then
            ply.controller["t_ply"] = tbl.player

            local thirdperson = tbl.thirdperson or false
            local roaming = tbl.roaming or false

            -- ply.controller["t_ply"]:InstallDataTable()
            -- ply.controller["t_ply"]:SetupDataTables()

            -- create Camera
            PlayerControl.camera = PlayerControl.Camera(ply, ply.controller["t_ply"], thirdperson, roaming)

            hook.Add("Move", "PlayerController:DisableControllerMovment", PlayerControl.disableMovment)
            --hook.Add("PlayerSwitchWeapon", "PlayerController:DisableControllerMouse", PlayerControl.disableMouse)
            --hook.Add("InputMouseApply", "PlayerController:DisableControllerMouse", PlayerControl.disableMouse)

            hook.Add("PlayerBindPress", "PlayerController:OverrideControllerBinds", PlayerControl.overrideBinds)

            hook.Add("CalcView", "PlayerController:CameraView", function(calling_ply, pos, angles, fov, znear, zfar)
                local view = {origin = pos, angles = angles, fov = fov, znear = znear, zfar = zfar, drawviewer = true}
                if PlayerControl.camera:CalcView( view, calling_ply, true ) then return view end -- ply:IsPlayingTaunt()
            end)

            hook.Add("CreateMove","PlayerController:ControllerMovment",function(cmd)
                PlayerControl.camera:CreateMove( cmd, ply, true)
            end)

        -- If the controlled Player
        else

            ply.controller["c_ply"] = tbl.player
            -- hook.Add("CreateMove","PlayerController:TargetMovment",function(cmd)
            --     print("Create Target Move:", ply:Nick())
            --     camera:CreateTargetMove( cmd, ply, true)
            -- end)

            -- TODO: Disable all commands / or maybe not
            hook.Add("PlayerBindPress", "PlayerController:DisableTargetBinds", PlayerControl.diableBinds)

        end


    -- END
    elseif tbl.mode == PC_SV_END then
        hook.Remove("Move", "PlayerController:DisableControllerMovment")
        --hook.Remove("InputMouseApply", "PlayerController:DisableControllerMouse")

        hook.Remove("CalcView", "PlayerController:CameraView")
        hook.Remove("CreateMove", "PlayerController:ControllerMovment")

        hook.Remove("PlayerBindPress", "PlayerController:OverrideControllerBinds")
        hook.Remove("PlayerBindPress", "PlayerController:DisableTargetBinds")

        PlayerControl.camera = nil
        ply.controller = nil

    -- MESSAGE FROM SERVER
    elseif tbl.mode == PC_SV_MESSAGE then

    -- Inventory Update of Target Player for Controlling Player
    elseif tbl.mode == PC_SV_INVENTORY then
        print("CLIENT: Update Inventory")
        if ply.controller and ply.controller["t_ply"] then
            ply.controller["t_ply"].inventory = tbl.inventory
            print("\n\nNew Inventory: ")
            PrintTable(ply.controller["t_ply"].inventory)
            print("Actual Inventory: ")
            PrintTable(ply.controller["t_ply"]:GetInventory())
        end
    end
end)


-- Controlling

-- Disable Binds
function PlayerControl.diableBinds(ply, bind, pressed)
    if not (ply.controller or ply.controller["c_ply"]) then return end

    -- if bind == "+attack" then
    --     --print("Player does an attack:")
    --     return true
    -- end

    return true
end

-- Override Binds
function PlayerControl.overrideBinds(ply, bind, pressed)
    if not (ply.controller or ply.controller["t_ply"]) then return end
    local t_ply = ply.controller["t_ply"]

    --print("Command:", bind)

    -- Next Weapon Slot / Camera Distance
    if bind == "invnext" and pressed then

        -- Change Camera Distance
        if input.IsKeyDown( KEY_LSHIFT ) then -- If shift is pressed, change camera distance
            PlayerControl.camera:ChangeOffset(-10)

        -- Select Next Weapon
        else
            local weps = t_ply:GetWeapons()
            local active_w = table.KeyFromValue(weps, t_ply:GetActiveWeapon())

            active_w = active_w + 1
            if active_w > #weps then
                active_w = 1
            end

            --print("FLAG:", PC_CL_WEAPON, "Class:", weps[active_w]:GetClass())
            PlayerControl.NetSendCl(PC_CL_WEAPON, weps[active_w]:GetClass())
        end

        return true

    -- Previous Weapon Slot
    elseif bind == "invprev" and pressed then

        -- Change Camera Distance
        if input.IsKeyDown( KEY_LSHIFT ) then -- If shift is pressed, change camera distance
            PlayerControl.camera:ChangeOffset(10)

        -- Select Previous Weapon
        else
            print("select previous weapon")
            local weps = t_ply:GetWeapons()
            local active_w = table.KeyFromValue(weps, t_ply:GetActiveWeapon())

            active_w = active_w - 1
            if active_w < 1 then
                active_w = #weps
            end

            print("FLAG:", PC_CL_WEAPON, "Class:", weps[active_w]:GetClass())
            PlayerControl.NetSendCl(PC_CL_WEAPON, weps[active_w]:GetClass())
        end

        return true

    -- Weapon Slot Number -> Select Slot 
    elseif string.sub(bind, 1, 4) == "slot" and pressed then
        local inv = t_ply:GetInventory()
        local idx = tonumber(string.sub(bind, 5, - 1)) or 1

        local weps = t_ply:GetWeapons()

        print("inventory:")
        PrintTable(inv)
        print("selected:", PrintTable(inv[idx]))

        if inv[idx][1] then
            print("name:", inv[idx][1]:GetClass())
            PlayerControl.NetSendCl(PC_CL_WEAPON, inv[idx][1]:GetClass())
            return true
        end

    -- Q Button -> Drop Weapon
    elseif bind == "+menu" then
        PlayerControl.NetSendCl(PC_CL_DROP_WEAPON, t_ply:GetActiveWeapon())
        return true
    end
end
