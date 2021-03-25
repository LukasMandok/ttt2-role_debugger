PlayerControl = PlayerControl or {}

util.AddNetworkString("playerControllerStartControl")
util.AddNetworkString("playerControllerNet")

net.Receive("playerControllerStartControl", function (len, calling_ply)
    if (calling_ply:IsAdmin() or calling_ply:IsSuperAdmin()) then
        target_ply = net.ReadEntity()
        PlayerControl.StartControl(calling_ply, target_ply)
    end
end)

function PlayerControl.NetSend(ply, tbl)
    net.Start("playerControllerNet")
        net.WriteTable(tbl)
    net.Send(ply)
end

function PlayerControl.StartControl(c_ply, t_ply)

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
    StartPCSpectate(c_ply, t_ply, false) --OBS_MODE_IN_EYE
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




    -- Override for the controlled Person
    elseif  ply.controller and ply.controller["c_ply"] then
        local t_ply = ply
        local c_ply = ply.controller["c_ply"]

        if not IsValid(c_ply) then return end

    end

end