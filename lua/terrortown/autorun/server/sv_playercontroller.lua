-----------------------------------------------------
------------------- Player Control ------------------
-----------------------------------------------------

PlayerController = {}
PlayerController.__index = PlayerController

setmetatable(PlayerController, {
    __call = function(cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

-- PlayerController or {
--     -- TODO: Diese Zuweisung bringt wahrscheinlich nichts
--     c_ply = nil,
--     t_ply = nil,

--     isActive = false,

--     spectator = nil,
--     previous_wep = nil,

--     view_flag = nil,
-- }

function PlayerController:__init(c_ply, t_ply, view_flag)
    self:StartControl(c_ply, t_ply, view_flag)
end

-----------------------------------------------------
------------------- Communication -------------------
-----------------------------------------------------

--util.AddNetworkString("PlayerController:StartControl") -- obsolete
--util.AddNetworkString("PlayerController:EndControl") -- obsolete
util.AddNetworkString("PlayerController:NetControl")
util.AddNetworkString("PlayerController:NetToSV")
util.AddNetworkString("PlayerController:NetToCL")

util.AddNetworkString("PlayerController:TargetAngle")

-- General PlayerController Managment 
net.Receive("PlayerController:NetControl", function (len, calling_ply)
    local mode = net.ReadInt(6)

    -- if controller is already active 
    if calling_ply:IsController() then
        local controller = calling_ply.controller

        -- Start Player Controller
        if mode == PC_CL_START then
            local target_ply = net.ReadEntity()

            -- if aready controlling that person, or is that person
            if target_ply == controller.t_ply or target_ply == calling_ply then return end

            local view_flag = net.ReadInt(6)
            controller:EndControl()

            controller:StartControl(calling_ply, target_ply, view_flag)

        -- Stop Player Controller
        elseif mode == PC_CL_END then
            controller:EndControl()

        -- Switch t_ply in Player Controller
        elseif mode == PC_CL_SWITCH then
            local view_flag = calling_ply.controller.view_flag
            local target_ply = net.ReadEntity()

            print("Switching to player:", target_ply)
            controller:EndControl()

            controller:StartControl(calling_ply, target_ply, view_flag)
        else
            print(alling_ply:Nick() .. " is already controlling, but the control mode is not valid.")        
        end

    -- if calling player is not active controller yet 
    -- and has adming rights
    -- TODO: hook, für weitere sonstige Abfrage hinzufügen
    elseif calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        if mode == PC_CL_START then
            local target_ply = net.ReadEntity()
            local view_flag = net.ReadInt(6)

            -- create new PlayerController
            PlayerController(calling_ply, target_ply, view_flag)
        else
            print(calling_ply:Nick() .. " has not valid control mode.")
        end
    else
        print(calling_ply:Nick() .. " does not have the right to start a control.")
    end
end)

-------------- Overriding Network Communication --------------

function net.Incoming( len, client )

    local i = net.ReadHeader()
    local strName = util.NetworkIDToString( i ):lower()

    if client.controller and client.controller["t_ply"] then
        if  PC_SV_NET[strName] then            
            --print(strName)
            client = client.controller["t_ply"]
        end
    end

    if ( !strName ) then return end

    local func = net.Receivers[ strName ]
    if ( !func ) then return end

    -- len includes the 16 bit int which told us the message name
    len = len - 16

    func( len, client )
end


local OldSend = OldSend or net.Send

function net.Send(ply)
    if ply.controller and ply.controller["c_ply"] then
        --print("Addressat wird geändert")
        -- if  PC_TARGET_MESSAGES[strName] then            
        --     --print(strName)
        -- end
        local new_ply = ply.controller["c_ply"]

        OldSend( {ply, new_ply} )
        return
    end

    OldSend( ply )
end



-- -- TODO: integrate into NetCOntrol
-- net.Receive("PlayerController:StartControl", function (len, calling_ply)
--     if (calling_ply:IsAdmin() or calling_ply:IsSuperAdmin()) then
--         local target_ply = net.ReadEntity()
--         local view_flag = net.ReadInt(6)

--         --PlayerController:StartControl(calling_ply, target_ply, view_flag)
--     end
-- end)

-- net.Receive("PlayerController:EndControl", function (len, calling_ply)
--     if (calling_ply:IsAdmin() or calling_ply:IsSuperAdmin()) then -- or (calling_ply.controller and (calling_ply.controller["c_ply"]:IsAdmin() or calling_ply.controller["c_ply"]:IsSuperAdmin())) then
--         PlayerController:EndControl()
--     end
-- end)

function PlayerController.NetSend(ply, tbl)
    net.Start("PlayerController:NetToSV")
        net.WriteTable(tbl)
    OldSend(ply)
end

-----------------------------------------------------
----------------- Control Functions -----------------
-----------------------------------------------------

function PlayerController:StartControl(c_ply, t_ply, view_flag)

    if self.isActive then return end
    self.isActive = true

    -- Add Controlling Hooks
    hook.Add("StartCommand", "PlayerController:OverrideCommands", PlayerController.overrideCommands)
    hook.Add("DoAnimationEvent", "PlayerController:PreventAnimations", PlayerController.preventAnimations)
    --hook.Add("SetupMove", "PlayerController:SetupMove", PlayerController.preventAttacking)
    hook.Add("FinishMove", "PlayerController:DisableControllerMovment", PlayerController.disableMovment)

    hook.Add("PlayerDeath", "PlayerController:PlayerDied", PlayerController.playerDied)
    hook.Add("PlayerSwitchWeapon", "PlayerController:DisableWeaponSwitch", PlayerController.disableWeaponSwitch)
    hook.Add("WeaponEquip", "PlayerController:UpdateTargetInventory", function(wep, ply) PlayerController.updateInventory(ply, wep) end)
    hook.Add("PlayerDroppedWeapon", "PlayerController:UpdateTargetInventory", PlayerController.updateInventory)
    hook.Add("PlayerSwitchFlashlight", "PlayerController:ControlFlashlight", PlayerController.controlFlashlight)
    hook.Add("WeaponEquip", "PlayerController:ItemPickedUp", PlayerController.itemPickedUp) --PlayerCanPickupItem
    hook.Add("PlayerAmmoChanged", "PlayerController:AmmoPickedUp", PlayerController.ammoPickedUp)

    --hook.Add("TTT2CanOrderEquipment", "PlayerController:PreventEquipmentOrder", PlayerController.preventEquipmentOrder)

    self.sprintEnabled = GetConVar( "ttt2_sprint_enabled" )
    self.maxSprintMul = GetConVar( "ttt2_sprint_max" )

    -- replace receiver for Equipment ordering
    --net.Receive("TTT2OrderEquipment", PlayerController.NetOrderEquipmentOverride)
    --net.Receive("ttt2_switch_weapon", PlayerController.PickupWeaponOverride)
    --net.Receive("TTT2SprintToggle", PlayerController.SprintToggleOverride)

    -- Define Tables
    c_ply.controller = self
    self.c_ply = c_ply

    t_ply.controller = self
    self.t_ply = t_ply

    self.view_flag = view_flag

    -- Make Transition
    --self.spectator = StartPCSpectate(c_ply, t_ply, realFirstPerson)

    hook.Run("PlayerController:StartTransition", self.c_ply, self.t_ply)


    -- Send initial information to the clients
    PlayerController.NetSend(self.c_ply, {
        mode = PC_SV_START,
        player = self.t_ply,
        view_flag = view_flag,
        controlling = true,
    })

    PlayerController.NetSend(self.t_ply, {
        mode = PC_SV_START,
        player = self.c_ply,
        controlling = false
    })

    -- Set Some Network Variables:
    --self.t_ply:SetNWBool("PlayerController_Controlled", true)

    -- make controlling player unarmed
    --self.previous_wep = self.c_ply:GetActiveWeapon()
    --local unarmed = self.c_ply:GetWeapon("weapon_ttt_unarmed")
    --self.c_ply:SetActiveWeapon(unarmed)

    self.updateInventory(self.t_ply)

    -- update missing target player information on the controlling client
    timer.Create("UpdatePlayerInformation", 0.1, 0, function ()

        local wep = self.t_ply:GetActiveWeapon()

        local ammo = 0
        local clip = -1

        if IsValid(wep) then
            ammo = self.t_ply:GetAmmoCount(wep:GetPrimaryAmmoType())
            clip = wep:Clip1()
        end
        --
        --print("Wep:", wep, "ammotype:", ammotype, "ammo:", ammo, "clip:", clip)
        --print("sprintProgress:", self.t_ply.sprintProgress)

        --print("Sending Player:", self.t_ply, "to Client:", self.t_ply:GetSubRole())
        PlayerController.NetSend(self.c_ply, {
            mode = PC_SV_PLAYER,
            player = self.t_ply,
            role = self.t_ply:GetSubRole(),
            credits = self.t_ply:GetCredits(),
            drowning = nil,
            armor = self.t_ply.armor,
            clip = clip,
            ammo = ammo,
        })
    end)
end

function PlayerController:EndControl()
    -- Add Controlling Hooks
    if self.isActive then

        -- Delete Player Information Timer
        timer.Remove("UpdatePlayerInformation")
        -- Reset back to origional function
        --net.Receive("ttt2_switch_weapon", PlayerController.PickupWeaponDefault)

        -- reset previous wepon 
        -- TODO: not needed if attacking is disabled
        --self.c_ply:SetActiveWeapon(self.previous_wep)
        --self.previous_wep = nil

        hook.Remove("StartCommand", "PlayerController:OverrideCommands")
        hook.Remove("DoAnimationEvent", "PlayerController:PreventAnimations")
        --hook.Remove("SetupMove", "PlayerController:SetupMove")
        hook.Remove("FinishMove", "PlayerController:DisableControllerMovment")

        hook.Remove("PlayerDeath", "PlayerController:PlayerDied")
        hook.Remove("PlayerSwitchWeapon", "PlayerController:DisableWeaponSwitch")
        hook.Remove("WeaponEquip", "PlayerController:UpdateTargetInventory")
        hook.Remove("PlayerDroppedWeapon", "PlayerController:UpdateTargetInventory")
        hook.Remove("PlayerSwitchFlashlight", "PlayerController:ControlFlashlight")
        hook.Remove("WeaponEquip", "PlayerController:ItemPickedUp")
        hook.Remove("PlayerAmmoChanged", "PlayerController:AmmoPickedUp")

        --hook.Remove("TTT2CanOrderEquipment", "PlayerController:PreventEquipmentOrder")

        -- DO Some transition
        hook.Run("PlayerController:StopTransition", self.c_ply, self.t_ply)

        -- Send Message to CLients
        PlayerController.NetSend(self.c_ply, {
            mode = PC_SV_END,
        })

        PlayerController.NetSend(self.t_ply, {
            mode = PC_SV_END,
        })

        -- Rest Network Variables
        self.c_ply:SetNWInt("PlayerController_Buttons", 0)
        self.c_ply:SetNWInt("PlayerController_Impluse", 0)

        --self.t_ply:SetNWBool("PlayerController_Controlled", false) --TODO: Brauche ich das überhaupt?

        self.c_ply:SetCanWalk(true)

        -- Reset Entries in Players:
        self.c_ply.controller = nil
        self.t_ply.controller = nil

        self.c_ply = nil
        self.t_ply = nil

        --self.updateSprintOverriden = false

        self.isActive = nil
    end
end

-----------------------------------
------ Controller Funktions -------
-----------------------------------

-- 1. StartCommand     -> overrideCommands (SERVER)  -- Transfers Movement data to client and delets input
-- 2. CreateMove                           (CLIENT)  -- Not used (before send to server)
-- 3. CalcMainActivity -> preventAnimation (SHARED)  -- Prevents any animations being played for c_ply -> return nil
-- 4. SetupMove        -> SetupMove        (SERVER)  -- Allows to disable 
-- 5. Move

-- coverride Commands
function PlayerController.overrideCommands(ply, cmd)
    -- Override for the controling Person
    if ply:IsController() then
        local c_ply = ply

        c_ply:SetNWInt("PlayerController_Buttons", cmd:GetButtons())
        c_ply:SetNWInt("PlayerController_Impluse", cmd:GetImpulse())

        c_ply.controller["ForwardMove"] = cmd:GetForwardMove()
        c_ply.controller["SideMove"] = cmd:GetSideMove()
        c_ply.controller["UpMove"] = cmd:GetUpMove()

        c_ply.controller["MouseWheel"] = cmd:GetMouseWheel()
        c_ply.controller["MouseX"] = cmd:GetMouseX()
        c_ply.controller["MouseY"] = cmd:GetMouseY()

        cmd:ClearMovement()
        cmd:ClearButtons()

    -- Override for the controlled Person
    elseif ply:IsControlled() then
        local t_ply = ply
        local c_ply = ply.controller["c_ply"]

        if not IsValid(c_ply) then return end

        cmd:SetButtons(c_ply:GetNWInt("PlayerController_Buttons", 0))
        cmd:SetImpulse(c_ply:GetNWInt("PlayerController_Impluse", 0))

        cmd:SetForwardMove(c_ply.controller["ForwardMove"] or 0)
        cmd:SetSideMove(c_ply.controller["SideMove"] or 0)
        cmd:SetUpMove(c_ply.controller["UpMove"] or 0)

        cmd:SetMouseWheel(c_ply.controller["MouseWheel"] or 0)
        cmd:SetMouseX(c_ply.controller["MouseX"] or 0)
        cmd:SetMouseY(c_ply.controller["MouseY"] or 0)
    end
end

-- Terminates PlayerController if t_ply or c_ply dies
function PlayerController.playerDied(victim, inflictor, attacker)
    if victim:IsController() or victim:IsControlled() then
        victim.controller:EndControl()
    end
end

-- Update Target Inventory:
function PlayerController.updateInventory(ply, wep)
    if ply:IsControlled() then
        -- TODO: Error with Nick() not valid!)
        --print("SERVER: Updating Inventory:", ply:Nick(), "Hat ", wep, "aufgehoben. Send to:", ply.controller.c_ply:Nick())
        timer.Simple(0.1, function()
            PlayerController.NetSend(ply.controller.c_ply, {
                mode = PC_SV_INVENTORY,
                player = ply,
                inventory = ply:GetInventory()
            })
        end)
    end
end

-- Weapon / Item Pickup
function PlayerController.itemPickedUp( item, ply )
    if ply:IsControlled() then
        print("Send message to client")

        if items.IsItem(item.id) then
            PlayerController.NetSend(ply.controller.c_ply, {
                mode = PC_SV_PICKUP,
                player = ply,
                type = PC_PICKUP_ITEM,
                item = item
            })
        else
            PlayerController.NetSend(ply.controller.c_ply, {
                mode = PC_SV_PICKUP,
                player = ply,
                type = PC_PICKUP_WEAPON,
                weapon = item
            })
        end
    end
end

-- Ammo Pickup
function PlayerController.ammoPickedUp(ply, ammoID, oldCount, newCount)
    if ply:IsControlled() then
        local difference = newCount - oldCount
        if difference > 0 then
           local name = game.GetAmmoName( ammoID )
            PlayerController.NetSend(ply.controller.c_ply, {
                mode = PC_SV_PICKUP,
                player = ply,
                type = PC_PICKUP_AMMO,
                ammo = name,
                count = difference
            })
        end
    end
end

--- Communication
net.Receive("PlayerController:TargetAngle", function (len, ply)
    local angle = net.ReadAngle()
    --print("Setting Eye Angles", angle)
    if ply:IsController() then
        local t_ply = ply.controller.t_ply
        t_ply:SetEyeAngles(angle or t_ply:EyeAngles())
    end
end)

net.Receive("PlayerController:NetToCL", function (len, ply)
    local mode = net.ReadInt(6)

    -- If message from Controlling Player
    if ply:IsController() then

        local t_ply = ply.controller.t_ply

        -- Select Weapon
        if mode == PC_CL_WEAPON then
            local wep = net.ReadString()

            --print("Select Weapon:", wep)

            t_ply:SelectWeapon(wep)

        -- Drop Weapon
        elseif mode == PC_CL_DROP_WEAPON then
            local wep = net.ReadEntity()

            if wep.AllowDrop then
                --print("Drop Weapon.", wep)

                t_ply:DropWeapon(wep)
                -- TODO: Wird eigentlich bei Drop Weapon event ausgeführt. 
                -- Funktioniert aber noch nicht richtig.
                --PlayerController.updateInventory(t_ply)
            end

        -- Request Inventory:
        elseif mode == PC_CL_INVENTORY then
            --print("NetCl: Send inventory of Player: " .. t_ply:Nick() .. " to player: ", c_ply:Nick())
            PlayerController.updateInventory(t_ply)

        elseif mode == PC_CL_MESSAGE then
            print("Getting Message from wrong player")

        end

    -- if message from Target Player -- TODO: REMOVE
    -- Die Nachricht vom Bot kommt nicht an.
    elseif ply:IsControlled() then
        print("NetCl from t_ply.")
        if mode == PC_CL_MESSAGE then
            print("Got Message from Target Player:")
        end
    end
end)


-- Override Server Communication from TTT2 Standard

-- Override Equipment Ordering to Forward to t_ply
-- ATTENTION: THIS changes the definition of the 
-- function PlayerController.NetOrderEquipmentOverride(len, ply)
--     local cls = net.ReadString()

--     if PlayerController.t_ply and ply == PlayerController.c_ply then
--         print("OrdereEquipment custom from:", ply:Nick())

--         concommand.Run( PlayerController.t_ply, "ttt_order_equipment", {cls} )
--     else
--         -- TODO: Error with passiv items!
--         concommand.Run( ply, "ttt_order_equipment", {cls}  )
--     end
-- end


--net.Receive("ttt2_switch_weapon", function(_, ply)

-- function PlayerController.PickupWeaponOverride(_, ply)
--     print("overridden Weapon Pickup")
--     if PlayerController.t_ply and ply == PlayerController.c_ply then
--         ply = PlayerController.t_ply
--     end

--     -- player and wepaon must be valid
--     if not IsValid(ply) or not ply:IsTerror() or not ply:Alive() then return end

--     -- handle weapon switch
--     local tracedWeapon = ply:GetEyeTrace().Entity

--     if not IsValid(tracedWeapon) or not tracedWeapon:IsWeapon() then return end

--     -- do not pickup weapon if too far away
--     if ply:GetPos():Distance(tracedWeapon:GetPos()) > 100 then return end

--     ply:SafePickupWeapon(tracedWeapon, nil, nil, true) -- force pickup and drop blocking weapon as well
-- end

-- -- Sprind override
-- function PlayerController.SprintToggleOverride(_, ply)
--     if PlayerController.t_ply and ply == PlayerController.c_ply then
--         ply = PlayerController.t_ply
--     end
--     -- sprintEnabled:GetBoll()
--     if not PlayerController.sprintEnabled:GetBool() or not IsValid(ply) then return end

--     local bool = net.ReadBool()

--     ply.oldSprintProgress = ply.sprintProgress
--     ply.sprintMultiplier = bool and (1 + PlayerController.maxSprintMul:GetFloat()) or nil
--     ply.isSprinting = bool
-- end

-- TODO: REMOVE Default PICKUP
-- function PlayerController.PickupWeaponDefault(_, ply)
    
--     -- player and wepaon must be valid
-- 	if not IsValid(ply) or not ply:IsTerror() or not ply:Alive() then return end

-- 	-- handle weapon switch
-- 	local tracedWeapon = ply:GetEyeTrace().Entity

-- 	if not IsValid(tracedWeapon) or not tracedWeapon:IsWeapon() then return end

-- 	-- do not pickup weapon if too far away
-- 	if ply:GetPos():Distance(tracedWeapon:GetPos()) > 100 then return end

-- 	ply:SafePickupWeapon(tracedWeapon, nil, nil, true) -- force pickup and drop blocking weapon as well
-- end




-- local function ConCommandOrderEquipment(ply, cmd, args)
-- 	if #args ~= 1 then return end

-- 	OrderEquipment(ply, args[1])
-- end
-- concommand.Add("ttt_order_equipment", ConCommandOrderEquipment)


-- function PlayerController.finishMove(ply, mv)
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


