-----------------------------------------------------
------------------- Player Control ------------------
-----------------------------------------------------

PlayerController = PlayerController or {}
PlayerController.__index = PlayerController

setmetatable(PlayerController, {
    __call = function(cls, ...) 
        print("Creating PlayerController")
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

function PlayerController:__init(tbl)
    -------------- Overriding Network Communication --------------

    self:StartControl(tbl)
end



-- PlayerController = PlayerController or {
--     c_ply = nil,
--     t_ply = nil,

--     camera = nil,

--     back_pressed = false,
--     e_pressed = false,
-- }

local TryT = LANG.TryTranslation
local ParT = LANG.GetParamTranslation



local ply_meta = FindMetaTable("Player")

ply_meta.OldSteamID64 = ply_meta.OldSteamID64 or ply_meta.SteamID64
ply_meta.OldGetForward = ply_meta.OldGetForward or ply_meta.GetForward

WSWITCH.OldConfirmSelection = WSWITCH.OldConfirmSelection or WSWITCH.ConfirmSelection

OldLocalPlayer = OldLocalPlayer or LocalPlayer

-- Override Functions for the controlling Player
function PlayerController:__overrideFunctions( flag )

    local t_ply = self.t_ply
    local c_ply = self.c_ply
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

        -- WSITCH 
        WSWITCH.ConfirmSelection = function() end

        -- SteamID for Bots
        if t_ply:IsBot() then
            print("overriding SteamID64 for:", t_ply:Nick())
            print("\nOld SteamID64:", t_ply:SteamID64())

            --player_manager.SetPlayerClass(t_ply, "t_ply")
            ply_meta.SteamID64 = function(slf)
                --print("slf:", slf)
                --print("old:", slf:OldSteamID64())
                if slf == t_ply then
                    return c_ply:OldSteamID64()
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
        if LocalPlayer != OldLocalPlayer then
            LocalPlayer = OldLocalPlayer
        end

        -- -- reset WSWITCH
        -- WSWITCH.ConfirmSelection = WSWITCH.OldConfirmSelection

        -- -- reset SteamID64 functino for bots
        -- if t_ply:IsBot() then
        --     --player_manager.ClearPlayerClass(t_ply)
        --     ply_meta.SteamID64 = ply_meta.OldSteamID64
        --     -- = function(self)
        --     --     return nil
        --     -- end
        -- end

        -- -- reset GetForward function
        -- if ply_meta.GetForward != ply_meta.OldGetForward then
        --     ply_meta.GetForward = ply_meta.OldGetForward
        -- end
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

-----------------------------------------------------
------------------- Communication -------------------
-----------------------------------------------------

function PlayerController.NetSendCl( mode, arg1, arg2 )
    net.Start("PlayerController:NetToCL")
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


net.Receive("PlayerController:NetToSV", function (len)
    local ply = OldLocalPlayer()
    if not IsValid(ply) then return end
    local tbl = net.ReadTable()

    -- START
    if tbl.mode == PC_SV_START then
        --MsgC(Color(255, 64, 64), "[PLAYER CONTROLLER] ", Color(198, 198, 198), tbl.log.."\n")

        -- Set the table to the player
        PlayerController(tbl)

    -- END
    elseif tbl.mode == PC_SV_END then
        local controller = ply.controller

        if not controller then
            print("Contoler not valid for:", ply:Nick(), controller)
            return
        end

        print("Controller is valid and Terminating now:", controller.camera)
        controller:EndControl()

    -- MESSAGE FROM SERVER
    elseif tbl.mode == PC_SV_MESSAGE then
        -- TODO: Popup mit Inhalt und Dauer
        print("received message from the server")

    -- Inventory Update of Target Player for Controlling Player
    elseif tbl.mode == PC_SV_INVENTORY then
        --print("CLIENT: Update Inventory")
        if ply:IsController() then
            ply.controller["t_ply"].inventory = tbl.inventory
            -- print("\n\nNew Inventory: ")
            -- PrintTable(ply.controller["t_ply"].inventory)
            -- print("Actual Inventory: ")
            -- PrintTable(ply.controller["t_ply"]:GetInventory())
        end

    elseif tbl.mode == PC_SV_PLAYER then
        --print("Client: Update Target Information", ply.controller, ply.controller["t_ply"])
        if ply:IsController(tbl.player) then
            local t_ply = ply.controller["t_ply"] 

            t_ply:SetRole(tbl.role)
            t_ply.equipment_credits = tbl.credits
            --ply.controller["t_ply"].sprintProgress = tbl.sprintProgress
            --ply.controller["t_ply"].oldSprintProgress = tbl.sprintProgress

            if tbl.armor and t_ply.armor ~= tbl.armor then
                t_ply.armor = tbl.armor
                HandleArmorStatusIcons(t_ply)
            end

            local wep = t_ply:GetActiveWeapon()
            -- local clip = tbl.clip
            -- local ammo = tbl.ammo
            -- print("ammo:", ammo, "clip:", clip)
            if IsValid(wep) then
                --print("Valid weapon -> set ammo and clip count")
                t_ply:SetAmmo( tbl.ammo,  wep:GetPrimaryAmmoType() )
                t_ply:GetActiveWeapon():SetClip1(tbl.clip)
            end

            --print("Role to set:", role)
            --print("Role of t_ply:", ply.controller["t_ply"]:GetSubRole())
        end
    elseif tbl.mode == PC_SV_PICKUP then
        if ply:IsController(tbl.player) then

            if tbl.type == PC_PICKUP_WEAPON then
                print("\n\n Callinf HUDPWeaponPickedUp")
                GAMEMODE:HUDWeaponPickedUp(tbl.weapon)
                --gamemode.Call("HUDWeaponPickedUp", tbl.weapon)

            elseif tbl.type == PC_PICKUP_ITEM then
                GAMEMODE:HUDItemPickedUp(tbl.item)
                --gamemode.Call("HUDItemPickedUp", tbl.item)

            elseif tbl.type == PC_PICKUP_AMMO then
                GAMEMODE:HUDAmmoPickedUp(tbl.ammo, tbl.count)
                --gamemode.Call("HUDAmmoPickedUp", tbl.ammo, tbl.count)
            end

        end
    end
end)

function PlayerController.NetSendCommands(ply, cmd)
    if not ply:IsController() then return end

    local camera = ply.controller.camera
    local controller = ply.controller

    controller["Buttons"] = cmd:GetButtons()
    controller["Impluse"] = cmd:GetImpulse()

    controller["ForwardMove"] = cmd:GetForwardMove()
    controller["SideMove"] = cmd:GetSideMove()
    controller["UpMove"] = cmd:GetUpMove()

    controller["MouseWheel"] = cmd:GetMouseWheel()
    controller["MouseX"] = cmd:GetMouseX()
    controller["MouseY"] = cmd:GetMouseY()

    net.Start("PlayerController:NetCommands")
        net.WriteAngle(camera:GetCorrectedAngles())

        net.WriteUInt(cmd:GetButtons(), 25)     -- 25: +33554431 (needs: 16777216)
        net.WriteUInt(cmd:GetImpulse(), 8)      --  8: +255      (needs: +204)

        net.WriteInt(cmd:GetForwardMove(), 15)  -- 15: +-16384   (needs: +-10000)
        net.WriteInt(cmd:GetSideMove(), 15)     -- 15: +-16384   (needs: +-10000)
        net.WriteInt(cmd:GetUpMove(), 15)       -- 15: +-16384   (needs: +-10000)

        net.WriteInt(cmd:GetMouseWheel(), 6)    --  6: +-31      (needs: +-25)
        net.WriteInt(cmd:GetMouseX(), 14)       -- 14: +-8191    (needs: +-5000)
        net.WriteInt(cmd:GetMouseY(), 14)       -- 14: +-8191    (needs: +-5000)
    net.SendToServer()
--         -- c_ply.controller["ForwardMove"] = cmd:GetForwardMove()
--         -- c_ply.controller["SideMove"] = cmd:GetSideMove()
--         -- c_ply.controller["UpMove"] = cmd:GetUpMove()

--         -- c_ply.controller["MouseWheel"] = cmd:GetMouseWheel()
--         -- c_ply.controller["MouseX"] = cmd:GetMouseX()
--         -- c_ply.controller["MouseY"] = cmd:GetMouseY()
    

    cmd:ClearMovement()
    cmd:ClearButtons()
end

-----------------------------------------------------
----------------- Control Functions -----------------
-----------------------------------------------------

function PlayerController:StartControl(tbl)
    local ply = OldLocalPlayer()

    -- If controlling Player
    if tbl.controlling then
        local c_ply = ply
        local t_ply = tbl.player

        c_ply.controller = self
        t_ply.controller = self

        self.t_ply = t_ply
        self.c_ply = c_ply

        local view_flag = tbl.view_flag or PC_CAM_FIRSTPERSON


        -- create Camera
        self.camera = PlayerCamera(c_ply, t_ply, view_flag)
        print("camera1:", self.camera)
        print("camera2:", c_ply.controller.camera)
        print("camera3:", self.c_ply.controller.camera)
        print("camera4:", t_ply.controller.camera)
        hook.Add("StartCommand", "PlayerController:NetSendCommands", PlayerController.NetSendCommands)
        hook.Add("PlayerBindPress", "PlayerController:OverrideControllerBinds", PlayerController.overrideBinds)
        hook.Add("DoAnimationEvent", "PlayerController:PreventAnimations", PlayerController.preventAnimations) -- CalcMainActivity

        hook.Add("Move", "PlayerController:ButtonControls", PlayerController.buttonControls)
        --hook.Add("SetupMove", "PlayerController:SetupMove", PlayerController.preventAttacking)
        hook.Add("FinishMove", "PlayerController:DisableControllerMovment", PlayerController.disableMovment)
        hook.Add("PlayerSwitchWeapon", "PlayerController:DisableWeaponSwitch", PlayerController.disableWeaponSwitch)
        --hook.Add("InputMouseApply", "PlayerController:DisableControllerMouse", PlayerController.disableMouse)

        hook.Add("CalcView", "PlayerController:CameraView", function(calling_ply, pos, angles, fov, znear, zfar)
            local view = {origin = pos, angles = angles, fov = fov, znear = znear, zfar = zfar, drawviewer = true}
            if self.camera:CalcView( view, calling_ply, true ) then return view end -- ply:IsPlayingTaunt()
        end)

        hook.Add("CreateMove","PlayerController:CameraMovment",function(cmd)
            self.camera:CreateMove( cmd, c_ply, true)
        end)

        hook.Add("HUDPaint", "PlayerController:DrawHelpHUD", PlayerController.drawHelpHUD)
        hook.Add("TTTRenderEntityInfo", "PlayerController:DrawTargetID", PlayerController.drawTargetID)
        hook.Add("HUDWeaponPickedUp", "PlayerController:WeaponPickupNotification", PlayerController.pickupNotification)
        hook.Add("HUDItemPickedUp", "PlayerController:ItemPickupNotification", PlayerController.pickupNotification)
        hook.Add("HUDAmmoPickedUp", "PlayerController:AmmoPickupNotification", PlayerController.pickupNotification)

        self:__overrideFunctions(true)

        t_ply.armor = t_ply.armor or 0
        HandleArmorStatusIcons(t_ply)

        -- Override Sprint Update
        self.updateSprintOverriden = true
        self:addHUDHelp()

    -- If the controlled Player
    else
        local c_ply = tbl.player
        local t_ply = ply

        c_ply.controller = self
        t_ply.controller = self

        self.t_ply = t_ply
        self.c_ply = c_ply

        -- hook.Add("CreateMove","PlayerController:TargetMovment",function(cmd)
        --     print("Create Target Move:", ply:Nick())
        --     camera:CreateTargetMove( cmd, ply, true)
        -- end)

        -- TODO: Disable all commands / or maybe not
        hook.Add("StartCommand", "PlayerController:DisableTargetBinds", PlayerController.disableBinds)
    end
end

function PlayerController:EndControl()
    local t_ply = self.t_ply
    local c_ply = self.c_ply

    --TODO: Distinguish between c_ply and t_ply 

    hook.Remove("DoAnimationEvent", "PlayerController:PreventAnimations")
    --hook.Remove("SetupMove", "PlayerController:SetupMove")
    hook.Remove("FinishMove", "PlayerController:DisableControllerMovment")
    hook.Remove("PlayerSwitchWeapon", "PlayerController:DisableWeaponSwitch")

    hook.Remove("Move", "PlayerController:ButtonControls")

    hook.Remove("CalcView", "PlayerController:CameraView")
    hook.Remove("CreateMove", "PlayerController:CameraMovment")

    hook.Remove("StartCommand", "PlayerController:NetSendCommands")
    hook.Remove("PlayerBindPress", "PlayerController:OverrideControllerBinds")
    hook.Remove("PlayerBindPress", "PlayerController:DisableTargetBinds")

    hook.Remove("HUDPaint", "PlayerController:DrawHelpHUD")
    hook.Remove("TTTRenderEntityInfo", "PlayerController:DrawTargetID")
    hook.Remove("HUDWeaponPickedUp", "PlayerController:WeaponPickupNotification")
    hook.Remove("HUDItemPickedUp", "PlayerController:ItemPickupNotification")
    hook.Remove("HUDAmmoPickedUp", "PlayerController:AmmoPickupNotification")

    self:__overrideFunctions(false)

    -- back to previous Sprint update function
    self:removeHUDHelp()
    self.updateSprintOverriden = false

    c_ply.controller = nil
    t_ply.controller = nil

    self.c_ply = nil
    self.t_ply = nil

    self.camera:Stop()
    self.camera = nil

    -- Update Status of Armor Icon, at player change.
    HandleArmorStatusIcons(t_ply)
end


-----------------------------------------------------
---------------- Overriding Functions ---------------
-----------------------------------------------------

-- Disable Binds for the target player    --  bind, pressed
function PlayerController.disableBinds( ply, cmd )
    if not (ply:IsControlled()) then return end

    -- if bind == "+attack" then
    --     --print("Player does an attack:")
    --     return true
    -- end

    cmd:ClearButtons()
    cmd:ClearMovement()

    --return true
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

    PlayerController.NetSendCl(PC_CL_WEAPON, wep:GetClass())
end

-- Override Binds
function PlayerController.overrideBinds( ply, bind, pressed )
    if not (ply:IsController()) then return end

    local controller = ply.controller

    print("Carrying out binds:")

    -- Next Weapon Slot / Camera Distance
    if bind == "invnext" and pressed then

        -- Change Camera Distance
        if input.IsKeyDown( KEY_LSHIFT ) then -- If shift is pressed, change camera distance
            controller.camera:ChangeOffset(10)

        -- Select Next Weapon
        else
            WSWITCH:SelectNext()
            SelectWeapon()
        end

        print("prevent Scrollup bind")
        return true

    -- Previous Weapon Slot
    elseif bind == "invprev" and pressed then
        -- Change Camera Distance
        if input.IsKeyDown( KEY_LSHIFT ) then -- If shift is pressed, change camera distance
            controller.camera:ChangeOffset(-10)

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
        --     PlayerController.NetSendCl(PC_CL_WEAPON, inv[idx][1]:GetClass())
        --     return true
        -- end

        print("prevent number bind")
        return true

    -- Q Button -> Drop Weapon
    elseif bind == "+menu" then
        PlayerController.NetSendCl(PC_CL_DROP_WEAPON, controller.t_ply:GetActiveWeapon())
        return true

    end
end

-- Button Controls
function PlayerController.buttonControls(ply, mv)

    if not ply:IsController() then return end
        -- end Control

    local controller = ply.controller

    if not input.IsKeyDown(KEY_LSHIFT) and input.WasKeyPressed(KEY_BACKSPACE) then
        if controller.back_pressed == false then
            print("End Player Control")
            controller.back_pressed = true
            net.Start("PlayerController:NetControl")
                net.WriteInt(PC_CL_END, 6)
            net.SendToServer()
        end

        return

    -- switch to next player
    elseif input.IsKeyDown(KEY_LSHIFT) and input.WasKeyPressed(KEY_BACKSPACE) then
        if controller.back_pressed == false then
            controller.back_pressed = true
            local t_i, c_i
            local alive_players = {}

            for i, p in pairs(player.GetAll()) do
                if p:Alive() then
                    alive_players[#alive_players + 1] = p
                    if p == controller.t_ply then t_i = #alive_players - 1
                    elseif p == controller.c_ply then c_i = #alive_players - 1 end
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
        if controller.e_pressed == false then
            controller.e_pressed = true
            local ent = controller.camera.GetViewTargetEntity()

            if IsValid(ent) and ent:IsPlayer() and ent:Alive() then
                if ent == controller.c_ply then
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

    controller.back_pressed = false
    controller.e_pressed = false

    return true

end

-- Draw Target ID to switch to other players:
function PlayerController.drawTargetID(tData)
    -- TODO: vieleicht unnötige Abfrage
    if not OldLocalPlayer():IsController() then return end

    local controller = OldLocalPlayer().controller

    local ent = tData:GetEntity()

    if not IsValid(ent) or not ent:IsPlayer() or not ent:Alive() then return end

    local h_string, h_color = util.HealthToString(ent:Health(), ent:GetMaxHealth())

    if ent == controller.c_ply then
        tData:SetSubtitle(
            ParT("target_end_PC", {usekey = Key("+use", "USE"), name = ent:Nick()})
        )
    else
        tData:SetSubtitle(
            ParT("target_switch_PC", {usekey = Key("+use", "USE"), name = ent:Nick()})
        )
    end

    tData:AddDescriptionLine(
        TryT(h_string),
        h_color
    )
    --tData:SetKeyBinding("+use")
end

function PlayerController:removeHUDHelp()
    self.HUDHelp = nil
end

function PlayerController:addHUDHelp()
    self.HUDHelp = {
        lines = {},
        max_length = 0
    }

    self:addHUDHelpLine(TryT("help_hud_end_PC"), "BACK") -- Key("+reload", "R")
    self:addHUDHelpLine(TryT("help_hud_switch_PC"), "SHIFT", "E" ) -- Key("+reload", "R")
    self:addHUDHelpLine(TryT("help_hud_next_PC"), "SHIFT", "BACK" ) -- Key("+reload", "R")
end

function PlayerController:addHUDHelpLine(text, key1, key2)
    local width = draw.GetTextSize(text, "weapon_hud_help")

    self.HUDHelp.lines[#self.HUDHelp.lines + 1] = {text = text, key1 = key1, key2 = key2}
    self.HUDHelp.max_length = math.max(self.HUDHelp.max_length, width)
end


-- Draws the help Hud for the active weapon
-- and draws the control panel
function PlayerController.drawHelpHUD()
    if not OldLocalPlayer():IsController() then return end

    local controller = OldLocalPlayer().controller

    local wep = controller.t_ply:GetActiveWeapon()
    if IsValid(wep) then
        controller.t_ply:GetActiveWeapon():DrawHUD()
    end

    controller:drawHelp()
end

function PlayerController:drawHelp()
    if not self.HUDHelp then return end

    local data = self.HUDHelp
    local lines = data.lines
    local x = ScrW() * 0.66 + data.max_length * 0.5
    local y_start = ScrH() - 25
    local y = y_start
    local delta_y = 25
    local valid_icon = false

    for i = #lines, 1, -1 do
        local line = lines[i]
        local drawn_icon = self:drawHelpLine(x, y, line.text, line.key1, line.key2)
        y = y - delta_y
        valid_icon = valid_icon or drawn_icon
    end

    if valid_icon then
        local line_x = x + 10
        draw.ShadowedLine(line_x, y_start + 2, line_x, y + 8, COLOR_WHITE)
    end
end

function PlayerController:drawHelpLine(x, y, text, key1, key2)
    local valid_icon = true

    if isstring(key1) and key2 == nil then
        self:drawKeyBox(x, y, key1)
    elseif isstring(key1) and isstring(key2) then
        local key2_width = draw.GetTextSize(key2, "weapon_hud_help_key")
        self:drawKeyBox(x-25-key2_width, y, key1)
        draw.ShadowedText("+", "weapon_hud_help", x-8-key2_width, y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        self:drawKeyBox(x, y, key2)
    else
        valid_icon = false
    end

    draw.ShadowedText(TryT(text), "weapon_hud_help", x + 20, y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

    return valid_icon
end

function PlayerController:drawKeyBox(x, y, key)
    local pad = 3
    local pad2 = pad * 2

    x = x - pad + 1
    y = y - pad2 * 0.5 + 1

    local key_box_w, key_box_h = draw.GetTextSize(key, "weapon_hud_help_key")

    key_box_w = key_box_w + 3 * pad
    key_box_h = key_box_h + pad2

    local key_box_x = x - key_box_w + 1.5 * pad
    local key_box_y = y - key_box_h + 0.5 * pad2

    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(key_box_x, key_box_y, key_box_w, key_box_h)
    draw.ShadowedText(key, "weapon_hud_help_key", x, y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    draw.OutlinedShadowedBox(key_box_x, key_box_y, key_box_w, key_box_h, 1, COLOR_WHITE)
end

-- Disable Pickup Notification for the c_ply
function PlayerController.pickupNotification()
    return false
end
