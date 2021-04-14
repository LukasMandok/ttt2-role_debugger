PlayerControl = PlayerControl or {}

-- FLAGGS

-- Server Network Flags
PC_SV_START = 1
PC_SV_END = 2
PC_SV_MESSAGE = 3
PC_SV_INVENTORY = 4

-- Client Network Flags
PC_CL_WEAPON = 1
PC_CL_DROP_WEAPON = 2
PC_CL_INVENTORY = 3

-- SERVER ONLY
function PlayerControl.setupMove(ply, mv, cmd)
    if mv:KeyReleased( IN_USE ) then
        PlayerControl:EndControl()
    end

    -- if ply.controller and ply.controller["t_ply"]  then
    --     print("SetupMove")
    --     return true
    -- end
end


-- Shared
function PlayerControl.disableMovment(ply, mv)
    if ply.controller and ply.controller["t_ply"]  then
        return true
    end
end

function PlayerControl.disableWeaponSwitch(ply, oldWep, newWep )
    print("Disable Weapon Switch:")
    if ply.controller and ply.controller["t_ply"]  then
        return true
    end
end





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