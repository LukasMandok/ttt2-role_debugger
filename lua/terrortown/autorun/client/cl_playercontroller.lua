PlayerControl = PlayerControl or {
    c_ply = nil,
    t_ply = nil,

    camera = nil,

    back_pressed = false,
    e_pressed = false,
}

ply_meta = FindMetaTable("Player")

ply_meta.OldSteamID64 = ply_meta.OldSteamID64 or ply_meta.SteamID64
ply_meta.OldGetForward = ply_meta.OldGetForward or ply_meta.GetForward

-- t_ply_meta.DisplayName = "t_ply"
-- t_ply_meta.SteamID64 = function(slf)
--     return 00000
-- end

-- player_manager.RegisterClass( "t_ply", t_ply_meta, {} )

OldLocalPlayer = OldLocalPlayer or LocalPlayer

-- Override Functions for the controlling Player
local function overrideFunctions( flag )

    local t_ply = PlayerControl.t_ply
    --local t_ply_meta = getmetatable(t_ply)

    -- start override
    if flag == true then
        -- Local Player
        LocalPlayer = function()
            if t_ply == nil then
                return OldLocalPlayer()
            else
                return t_ply
            end
        end

        -- Admin RIghts



        -- SteamID for Bots
        if t_ply:IsBot() then
            print("overriding SteamID64 for:", t_ply:Nick())
            print("\nOld SteamID64:", t_ply:SteamID64())

            --player_manager.SetPlayerClass(t_ply, "t_ply")
            ply_meta.SteamID64 = function(slf)
                --print("slf:", slf)
                --print("old:", slf:OldSteamID64())
                if slf == t_ply then
                    return PlayerControl.c_ply:OldSteamID64()
                else
                    return slf:OldSteamID64()
                end
                -- TODO: For some reaseon the game crashes with that!!
                --return OldLocalPlayer():SteamID64()
            end
            --print("PlayerClass:", player_manager.GetPlayerClass(t_ply))
            --PrintTable( baseclass.Get( "t_ply" ) )
            print("New SteamID64:", t_ply:SteamID64())
            --print("DisplayName:", t_ply.DisplayName)
        end

        -- Forward function for clients
        ply_meta.GetForward = function(slf)
            if slf == t_ply then
                local angle = slf:EyeAngles()
                angle[3] = 0
                return angle:Forward()
            else
                return slf:GetForward()
            end
        end

    -- reset back to previous
    else
        -- reset LocalPlayer function
        LocalPlayer = OldLocalPlayer

        -- reset SteamID64 functino for bots
        if PlayerControl.t_ply:IsBot() then
            --player_manager.ClearPlayerClass(t_ply)
            ply_meta.SteamID64 = ply_meta.OldSteamID64
            -- = function(self)
            --     return nil
            -- end
        end

        -- reset GetForward function
        ply_meta.GetForward = ply_meta.OldGetForward
    end
end

-- HARDCODED!!!
local function HandleArmorStatusIcons(ply)
    -- removed armor
    if ply.armor <= 0 then
        if STATUS:Active("ttt_armor_status") then
            STATUS:RemoveStatus("ttt_armor_status")
        end

        return
    end

    -- check if reinforced
    local icon_id = 1

    if not GetGlobalBool("ttt_armor_classic", false) then
        icon_id = ply:ArmorIsReinforced() and 2 or 1
    end

    -- normal armor level change (update)
    if STATUS:Active("ttt_armor_status") then
        STATUS:SetActiveIcon("ttt_armor_status", icon_id)

        return
    end

    -- added armorc if not active
    STATUS:AddStatus("ttt_armor_status", icon_id)
end



function PlayerControl.NetSendCl( mode, arg1, arg2 )
    net.Start("PlayerController:NetCL")
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

net.Receive("PlayerController:NetSV", function (len)
    local ply = OldLocalPlayer()
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
            ply.controller["t_ply"].controller = {}
            ply.controller["t_ply"].controller["c_ply"] = ply

            PlayerControl.c_ply = ply
            PlayerControl.t_ply = ply.controller["t_ply"]

            local view_flag = tbl.view_flag or PC_CAM_FIRSTPERSON

            -- ply.controller["t_ply"]:InstallDataTable()
            -- ply.controller["t_ply"]:SetupDataTables()

            -- create Camera
            PlayerControl.camera = PlayerControl.Camera(ply, ply.controller["t_ply"], view_flag)

            hook.Add("PlayerBindPress", "PlayerController:OverrideControllerBinds", PlayerControl.overrideBinds)
            hook.Add("DoAnimationEvent", "PlayerController:PreventAnimations", PlayerControl.preventAnimations) -- CalcMainActivity

            hook.Add("Move", "PlayerController:ButtonControls", PlayerControl.buttonControls)

            --hook.Add("SetupMove", "PlayerController:SetupMove", PlayerControl.preventAttacking)
            hook.Add("FinishMove", "PlayerController:DisableControllerMovment", PlayerControl.disableMovment)
            hook.Add("PlayerSwitchWeapon", "PlayerController:DisableWeaponSwitch", PlayerControl.disableWeaponSwitch)
            --hook.Add("InputMouseApply", "PlayerController:DisableControllerMouse", PlayerControl.disableMouse)

            hook.Add("CalcView", "PlayerController:CameraView", function(calling_ply, pos, angles, fov, znear, zfar)
                local view = {origin = pos, angles = angles, fov = fov, znear = znear, zfar = zfar, drawviewer = true}
                if PlayerControl.camera:CalcView( view, calling_ply, true ) then return view end -- ply:IsPlayingTaunt()
            end)

            hook.Add("CreateMove","PlayerController:ControllerMovment",function(cmd)
                PlayerControl.camera:CreateMove( cmd, ply, true)
            end)

            hook.Add("HUDPaint", "PlayerController:DrawHelpHUD", PlayerControl.drawHelpHUD)

            overrideFunctions(true)

            ply.controller["t_ply"].armor = ply.controller["t_ply"].armor or 0
            HandleArmorStatusIcons(ply.controller["t_ply"])

            -- Override Sprint Update
            PlayerControl.updateSprintOverriden = true

        -- If the controlled Player
        else
            ply.controller["c_ply"] = tbl.player
            ply.controller["c_ply"].controller["t_ply"] = ply

            PlayerControl.t_ply = ply
            PlayerControl.c_ply = ply.controller["c_ply"]
            -- hook.Add("CreateMove","PlayerController:TargetMovment",function(cmd)
            --     print("Create Target Move:", ply:Nick())
            --     camera:CreateTargetMove( cmd, ply, true)
            -- end)

            -- TODO: Disable all commands / or maybe not
            hook.Add("PlayerBindPress", "PlayerController:DisableTargetBinds", PlayerControl.disableBinds)

            -- Timer to send Hud updates to the server and from there to the client.
            -- TODO: Remove Message
            timer.Create("SendHUD", 1, 0, function()
                --print("Sending message from t_ply")
                local curHUD = HUDManager.GetHUD()
                local curHUDTbl = huds.GetStored(curHUD)

                PlayerControl.NetSendCl(PC_CL_MESSAGE)
            end)
        end


    -- END
    elseif tbl.mode == PC_SV_END then
        hook.Remove("DoAnimationEvent", "PlayerController:PreventAnimations")
        --hook.Remove("SetupMove", "PlayerController:SetupMove")
        hook.Remove("FinishMove", "PlayerController:DisableControllerMovment")
        hook.Remove("PlayerSwitchWeapon", "PlayerController:DisableWeaponSwitch")

        hook.Remove("Move", "PlayerController:ButtonControls")

        hook.Remove("CalcView", "PlayerController:CameraView")
        hook.Remove("CreateMove", "PlayerController:ControllerMovment")

        hook.Remove("PlayerBindPress", "PlayerController:OverrideControllerBinds")
        hook.Remove("PlayerBindPress", "PlayerController:DisableTargetBinds")

        hook.Remove("HUDPaint", "PlayerController:DrawHelpHUD")

        print("reversing to OldLocalPlayer")
        overrideFunctions(false)

        -- back to previous Sprint update function
        PlayerControl.updateSprintOverriden = false

        PlayerControl.camera:Stop()
        PlayerControl.camera = nil
        ply.controller = nil

        PlayerControl.c_ply = nil
        PlayerControl.t_ply = nil

        -- Update Status of Armor Icon, at player change.
        HandleArmorStatusIcons(ply)

        -- Remove Tier for Hud Update
        timer.Remove( "SendHUD" )

    -- MESSAGE FROM SERVER
    elseif tbl.mode == PC_SV_MESSAGE then

    -- Inventory Update of Target Player for Controlling Player
    elseif tbl.mode == PC_SV_INVENTORY then
        --print("CLIENT: Update Inventory")
        if ply.controller and ply.controller["t_ply"] then
            ply.controller["t_ply"].inventory = tbl.inventory
            -- print("\n\nNew Inventory: ")
            -- PrintTable(ply.controller["t_ply"].inventory)
            -- print("Actual Inventory: ")
            -- PrintTable(ply.controller["t_ply"]:GetInventory())
        end

    elseif tbl.mode == PC_SV_PLAYER then
        --print("Client: Update Target Information", ply.controller, ply.controller["t_ply"])
        if ply.controller and ply.controller["t_ply"] == tbl.player then

            ply.controller["t_ply"]:SetRole(tbl.role)
            ply.controller["t_ply"].equipment_credits = tbl.credits
            --ply.controller["t_ply"].sprintProgress = tbl.sprintProgress
            --ply.controller["t_ply"].oldSprintProgress = tbl.sprintProgress

            if tbl.armor and ply.controller["t_ply"].armor ~= tbl.armor then
                ply.controller["t_ply"].armor = tbl.armor
                HandleArmorStatusIcons(ply.controller["t_ply"])
            end
            

            local wep = ply.controller["t_ply"]:GetActiveWeapon()
            -- local clip = tbl.clip
            -- local ammo = tbl.ammo
            -- print("ammo:", ammo, "clip:", clip)
            if IsValid(wep) then
                --print("Valid weapon -> set ammo and clip count")
                ply.controller["t_ply"]:SetAmmo( tbl.ammo,  wep:GetPrimaryAmmoType() )
                ply.controller["t_ply"]:GetActiveWeapon():SetClip1(tbl.clip)
            else
                print("Current weapon is not valid!")
            end

            --print("Role to set:", role)
            --print("Role of t_ply:", ply.controller["t_ply"]:GetSubRole())
        end
    elseif tbl.mode == PC_SV_PICKUP then
        if ply.controller and ply.controller["t_ply"] == tbl.player then
            
            if tbl.type == PC_PICKUP_WEAPON then
                hook.Run("HUDWeaponPickedUp", tbl.weapon)

            elseif tbl.type == PC_PICKUP_ITEM then
                hook.Run("HUDItemPickedUp", tbl.item)

            elseif tbl.type == PC_PICKUP_AMMO then
                hook.Run("HUDAmmoPickedUp", tbl.ammo, tbl.count)
            end

        end
    end
end)


-- Controlling

-- Disable Binds
function PlayerControl.disableBinds( ply, bind, pressed )
    if not (ply.controller or ply.controller["c_ply"]) then return end

    -- if bind == "+attack" then
    --     --print("Player does an attack:")
    --     return true
    -- end

    return true
end

-- send current weapon to server and activate HelpHUD
local function SelectWeapon( oldidx )
    local idx = WSWITCH.Selected

    -- if weapon did not change, do nothing
    if oldidx and oldidx == WSWITCH.Selected then return end

    local wep = WSWITCH.WeaponCache[idx]

    -- if wep.Initialize then
    --     wep:Initialize()
    -- end

    PlayerControl.NetSendCl(PC_CL_WEAPON, wep:GetClass())
end

-- Override Binds
function PlayerControl.overrideBinds( ply, bind, pressed )
    if not (ply.controller or ply.controller["t_ply"]) then return end
    local t_ply = ply.controller["t_ply"]

    --print("Command:", bind)

    -- Next Weapon Slot / Camera Distance
    if bind == "invnext" and pressed then

        -- Change Camera Distance
        if input.IsKeyDown( KEY_LSHIFT ) then -- If shift is pressed, change camera distance
            PlayerControl.camera:ChangeOffset(10)

        -- Select Next Weapon
        else
            WSWITCH:SelectNext()
            SelectWeapon()
        end

        return true

    -- Previous Weapon Slot
    elseif bind == "invprev" and pressed then
        -- Change Camera Distance
        if input.IsKeyDown( KEY_LSHIFT ) then -- If shift is pressed, change camera distance
            PlayerControl.camera:ChangeOffset(-10)

        -- Select Previous Weapon
        else
            WSWITCH:SelectPrev()
            SelectWeapon()
        end

        return true

    -- Weapon Slot Number -> Select Slot 
    elseif string.sub(bind, 1, 4) == "slot" and pressed then
        local oldidx = WSWITCH.Selected
        --local inv = t_ply:GetInventory()
        local idx = tonumber(string.sub(bind, 5, - 1)) or 1

        WSWITCH:SelectSlot(idx)

        SelectWeapon(oldidx)

        -- if inv[idx][1] then
        --     --print("name:", inv[idx][1]:GetClass())
        --     PlayerControl.NetSendCl(PC_CL_WEAPON, inv[idx][1]:GetClass())
        --     return true
        -- end

    -- Q Button -> Drop Weapon
    elseif bind == "+menu" then
        PlayerControl.NetSendCl(PC_CL_DROP_WEAPON, t_ply:GetActiveWeapon())
        return true

    end
end

-- Draws the help Hud for the active weapon
function PlayerControl.drawHelpHUD()
    local wep = PlayerControl.t_ply:GetActiveWeapon()
    if IsValid(wep) then
        PlayerControl.t_ply:GetActiveWeapon():DrawHUD()
    end
end

-- Button Controls
function PlayerControl.buttonControls(ply, mv)

    if not ply.controller and not ply.controller["t_ply"] then return end
        -- end Control

    if not input.IsKeyDown(KEY_LSHIFT) and input.WasKeyPressed(KEY_BACKSPACE) then
        if PlayerControl.back_pressed == false then
            print("End Player Control")
            PlayerControl.back_pressed = true
            net.Start("PlayerController:NetControl")
            net.WriteInt(PC_CL_START , 6)
            net.SendToServer()
        end

        return

    -- switch to next player
    elseif input.IsKeyDown(KEY_LSHIFT) and input.WasKeyPressed(KEY_BACKSPACE) then
        if PlayerControl.back_pressed == false then
            PlayerControl.back_pressed = true
            local t_i, c_i
            local alive_players = {}

            for i, p in pairs(player.GetAll()) do
                if p:Alive() then
                    alive_players[#alive_players + 1] = p
                    if p == PlayerControl.t_ply then t_i = #alive_players - 1
                    elseif p == PlayerControl.c_ply then c_i = #alive_players - 1 end
                end
            end

            local n = #alive_players
            local next = (c_i ~= (t_i + 1) % n and (t_i + 1) % n or (t_i + 2) % n ) + 1

            print("n", n, "t:", t_i, "c", c_i, "next:", next)

            print("Switch through players.")

            net.Start("PlayerController:NetControl")
            net.WriteInt(PC_CL_SWITCH , 6)
            net.WriteEntity(alive_players[next])
            net.SendToServer()
        end

        return

    -- switch to player in front
    elseif input.IsKeyDown(KEY_LSHIFT) and input.WasKeyPressed(KEY_E) then
        if PlayerControl.e_pressed == false then
            PlayerControl.e_pressed = true
            local ent = PlayerControl.camera.GetViewTargetEntity()

            if IsValid(ent) and ent:IsPlayer() and ent:Alive() then
                if ent == PlayerControl.c_ply then
                    print("Terminating Control")
                    net.Start("PlayerController:NetControl")
                    net.WriteInt(PC_CL_END , 6)
                    net.SendToServer()
                else
                    print("Switching to player:", ent:Nick())
                    net.Start("PlayerController:NetControl")
                    net.WriteInt(PC_CL_SWITCH , 6)
                    net.WriteEntity(ent)
                    net.SendToServer()
                end
            end
        end

        return
    end

    PlayerControl.back_pressed = false
    PlayerControl.e_pressed = false

end