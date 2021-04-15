PlayerControl = PlayerControl or {}

-- FLAGGS

-- Server Network Flags
PC_SV_START = 1
PC_SV_END = 2
PC_SV_MESSAGE = 3
PC_SV_INVENTORY = 4
PC_SV_PLAYER = 5

-- Client Network Flags
PC_CL_WEAPON = 1
PC_CL_DROP_WEAPON = 2
PC_CL_INVENTORY = 3
PC_CL_MESSAGE = 4

-- SERVER ONLY
function PlayerControl.setupMove(ply, mv, cmd)
    if mv:KeyReleased( IN_SCORE ) then
        PlayerControl:EndControl()
    end



    -- if ply.controller and ply.controller["t_ply"]  then
    --     print("SetupMove")
    --     return true
    -- end
end


-- Disable Movment for the controlling player
function PlayerControl.disableMovment(ply, mv)
    if ply.controller and ply.controller["t_ply"]  then
        ply:SetFOV(ply.controller["t_ply"]:GetFOV())
        return true
    end
end

-- Disable Weapon Switch for the controlling Player
function PlayerControl.disableWeaponSwitch(ply, oldWep, newWep )
    print("Disable Weapon Switch:")
    if ply.controller and ply.controller["t_ply"]  then
        return true
    end
end

-- prevent the controller from bying something from the shop
-- relay in net message since this hook is not called when the controlling player does not have the rights to by an item
function PlayerControl.preventEquipmentOrder(ply, cls, is_item, credits)
    -- allow, ignoreCost, message = hook.Run("TTT2CanOrderEquipment")
    if ply.controller and ply.controller["t_ply"] then
        print("Prevent Controller from bying something:", ply:Nick())
        return false
    end
end

-- relay shop order from 
-- only works if the controller itself is allowed to buy this item



-- NETWORK VARIABLES

-- PlayerControl = PlayerControl or {}

-- local PLAYER = FindMetaTable("Player")

-- function PLAYER:SetupDataTables()
--     print("Called SetupDataTables by:", self:Name())
--     self:NetworkVar( "Angle", 0, "TargetViewAngle" )
-- end

-- hook.Add("Move", "PlayerController:DisableControllerMovment", function(ply, mv)

-- end)

-- hook.Add("InputMouseApply", "PlayerController:DisableControllerMouse", PlayerControl.disableMouse)

-- function GM:Move(ply, mv) 
--     if ply.controller and ply.controller["t_ply"] then
--         return true 
--     end
-- end

-- function GM:Move(ply, mv) 
--     if ply.controller and ply.controller["t_ply"] then
--         return true 
--     end
-- end