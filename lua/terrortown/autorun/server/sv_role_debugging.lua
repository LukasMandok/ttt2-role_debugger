util.AddNetworkString( "RoleManagerPlayerConnected" )
util.AddNetworkString( "RoleManagerPlayerDisconnected" )
util.AddNetworkString( "RoleManagerBotConnected" )
util.AddNetworkString( "RoleManagerBotDisconnected" )

util.AddNetworkString( "RoleManagerCurrentRolesRequest" )
util.AddNetworkString( "RoleManagerCurrentRolesPlayer" )
util.AddNetworkString( "RoleManagerCurrentRolesBot" )

-- Player connecting / disconnecting

gameevent.Listen( "player_connect" )
gameevent.Listen( "player_disconnect" )

hook.Add( "player_connect", "player_connect_example", function( data )
    if data.bot == false then
        net.Start("RoleManagerPlayerConnected")
        net.WriteString(data.name)
        net.Broadcast()
    else
        net.Start("RoleManagerBotConnected")
        net.WriteString(data.name)
        net.Broadcast()
    end

end)

hook.Add( "player_disconnect", "player_connect_example", function( data )
    if data.bot == false then
        net.Start("RoleManagerPlayerDisconnected")
        net.WriteString(data.name)
        net.Broadcast()
    else
        net.Start("RoleManagerBotDisconnected")
        net.WriteString(data.name)
        net.Broadcast()
    end

end)

-- Role List
net.Receive( "RoleManagerCurrentRolesRequest" , function (len, ply)
    print("Requesting Current Roles")
    if ply:IsAdmin() or ply:IsSuperAdmin() then
        net.Start("RoleManagerCurrentRolesPlayer")
        net.WriteInt(#player.GetHumans(), 10)
        for _,p in pairs(player.GetHumans()) do
            net.WriteString(p:Nick())
            net.WriteString(roles.GetByIndex(p:GetSubRole()).name)
        end
        net.Send(ply)

        print("Sending Bot Roles")
        net.Start("RoleManagerCurrentRolesBot")
        net.WriteInt(#player.GetBots(), 10)
        for _,p in pairs(player.GetBots()) do
            print("For Bot:", p:Nick(), "Send Role:", roles.GetByIndex(p:GetSubRole()).name)
            net.WriteString(p:Nick())
            net.WriteString(roles.GetByIndex(p:GetSubRole()).name)
        end
        net.Send(ply)
    end
end)