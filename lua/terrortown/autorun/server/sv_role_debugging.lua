util.AddNetworkString( "RoleManagerPlayerConnected" )
util.AddNetworkString( "RoleManagerPlayerDisconnected" )
util.AddNetworkString( "RoleManagerBotConnected" )
util.AddNetworkString( "RoleManagerBotDisconnected" )

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