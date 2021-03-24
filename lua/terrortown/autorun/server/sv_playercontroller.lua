PlayerControl = PlayerControl or {}

util.AddNetworkString("playerControlStartControl")

net.Receive("playerControlStartControl", function (len, calling_ply)
    if (calling_ply:IsAdmin() or calling_ply:IsSuperAdmin()) then
        target_ply = net.ReadEntity()
        playercontroller.startControl(calling_ply, target_ply)
    end
end)

function PlayerControl:startControl()

end