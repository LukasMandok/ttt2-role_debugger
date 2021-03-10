util.AddNetworkString( "RoleManagerPlayerConnected" )
util.AddNetworkString( "RoleManagerPlayerDisconnected" )
util.AddNetworkString( "RoleManagerBotConnected" )
util.AddNetworkString( "RoleManagerBotDisconnected" )

util.AddNetworkString( "RoleManagerCurrentRolesRequest" )
util.AddNetworkString( "RoleManagerCurrentRolesPlayer" )
util.AddNetworkString( "RoleManagerCurrentRolesBot" )

util.AddNetworkString( "RoleManagerApplyRole" )
util.AddNetworkString( "RoleManagerApplyRoleNextRound" )


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
net.Receive( "RoleManagerCurrentRolesRequest" , function (len, calling_ply)
    print("Server: Requesting Current Roles")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        net.Start("RoleManagerCurrentRolesPlayer")
        net.WriteInt(#player.GetHumans(), 10)
        for _,p in pairs(player.GetHumans()) do
            net.WriteString(p:Nick())
            net.WriteString(roles.GetByIndex(p:GetSubRole()).name)
        end
        net.Send(calling_ply)

        print("Server: Sending Bot Roles")
        net.Start("RoleManagerCurrentRolesBot")
        net.WriteInt(#player.GetBots(), 10)
        for _,p in pairs(player.GetBots()) do
            print("For Bot:", p:Nick(), "Send Role:", roles.GetByIndex(p:GetSubRole()).name)
            net.WriteString(p:Nick())
            net.WriteString(roles.GetByIndex(p:GetSubRole()).name)
        end
        net.Send(calling_ply)
    end
end)

-- Apply Roles
net.Receive("RoleManagerApplyRole", function (len, calling_ply)
    print("Server: Applying role.")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        local ply = net.ReadEntity()
        local role_name = net.ReadString()

        local role = roles.GetByName(role_name)
        if role.name != role_name then
            print("Server: Rolle " .. role_name .. " wurde nicht gefunden. Statdesse: " .. role.name)
        end
        local role_index = role.index
        local role_credits = role:GetStartingCredits()

        ply:SetRole(role_index)

        SendFullStateUpdate()
        --calling_ply:ChatPrint("You changed to '" .. role.name .. "' (index: " .. role_index .. ")")
        calling_ply:ChatPrint("Player: '" .. ply:Nick() .. "' role changed to " .. role_name .. ".")
    end
end)

net.Receive("RoleManagerApplyRoleNextRound", function (len, calling_ply)
    print("Server: Applying role next round.")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        local ply = net.ReadEntity()
        local role_name = net.ReadString()
        
        local sid64 = tostring(ply:SteamID64())

        print("STEMDI64", sid64)
        
        -- TODO: Abfrage durch ROLE_RANDOM.name, wenn das in einer shared file ist.
        if role_name == "random" then
            --if IsValid(roleselection.forcedRoles[sid64]) then
            roleselection.forcedRoles[sid64] = nil
            --end
        else
            local role = roles.GetByName(role_name)
            local role_index = role.index

            roleselection.forcedRoles[sid64] = role_index            
        end

        calling_ply:ChatPrint("Player: '" .. ply:Nick() .. "' has role " .. role_name .. " next round.")
    end
end)