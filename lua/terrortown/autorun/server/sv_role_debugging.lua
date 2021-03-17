util.AddNetworkString( "RoleManagerPlayerConnected" )
util.AddNetworkString( "RoleManagerPlayerDisconnected" )
util.AddNetworkString( "RoleManagerBotConnected" )
util.AddNetworkString( "RoleManagerBotDisconnected" )

util.AddNetworkString( "RoleManagerCurrentRolesRequest" )
util.AddNetworkString( "RoleManagerCurrentRolesPlayer" )
util.AddNetworkString( "RoleManagerCurrentRolesBot" )

util.AddNetworkString( "RoleManagerChangeBotName" )
util.AddNetworkString( "RoleManagerSpawnBot" )
util.AddNetworkString( "RoleManagerSpawnBotThisRound" )
util.AddNetworkString( "RoleManagerRespawnBot" )
util.AddNetworkString( "RoleManagerDeleteBot" )

util.AddNetworkString( "RoleManagerApplyRole" )
util.AddNetworkString( "RoleManagerApplyRoleNextRound" )
util.AddNetworkString( "RoleManagerClearRolesNextRound" )


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
            print("For Bot:", p:Nick(), "Set Role:", roles.GetByIndex(p:GetSubRole()).name)
            net.WriteString(p:Nick())
            net.WriteString(roles.GetByIndex(p:GetSubRole()).name)
        end
        net.Send(calling_ply)
    end
end)

-- Renaming Bots

-- TODO: This is not working and not used at the moment
-- local PlayerNameOrNick = debug.getregistry().Player
-- PlayerNameOrNick.RealName = PlayerNameOrNick.Nick
-- PlayerNameOrNick.Nick = function(self) if self ~= nil then return self:GetNWString("PlayerName", self:RealName()) else return "" end end
-- PlayerNameOrNick.Name = PlayerNameOrNick.Nick
-- PlayerNameOrNick.GetName = PlayerNameOrNick.Nick

-- net.Receive("RoleManagerChangeBotName", function (len, calling_ply)
--     print("Server: Updating Bot Names.")
--     if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
--         local target_ply = net.ReadEntity()
--         local name = net.ReadString()
--         target_ply:SetNWString("PlayerName", name)
--     end
-- end)

-- Spawn Bot
net.Receive("RoleManagerSpawnBot", function (len, calling_ply)
    print("Server: Spawning Bot.")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        local spawn_name = net.ReadString()
        player.CreateNextBot( spawn_name )
    end
end)

-- functino to find a corpse
function corpse_find(v)
    for _, ent in pairs(ents.FindByClass("prop_ragdoll")) do
        if ent.uqid == v:UniqueID() and IsValid(ent) then
            return ent or false
        end
    end
end

-- function zto remove a corpse
function corpse_remove(corpse)
    CORPSE.SetFound(corpse, false)

    if string.find(corpse:GetModel(), "zm_", 6, true) then
        player.GetByUniqueID(corpse.uqid):TTT2NETSetBool("body_found", false)
        corpse:Remove()
        SendFullStateUpdate()
    elseif corpse.player_ragdoll then
        player.GetByUniqueID(corpse.uqid):TTT2NETSetBool("body_found", false)
        corpse:Remove()
        SendFullStateUpdate()
    end
end

local function respawn(calling_ply, target_ply)
    if GetRoundState() == 1 then
        print("!!!Round has not yet begun.")
    elseif target_ply:Alive() and not target_ply:IsSpec() then
        print("!!!The Player " .. target_ply:Nick() .. " is already alive.")

    -- if player ayer is alive but a spectator or the player is dead
    elseif (target_ply:Alive() and target_ply:IsSpec()) then
        print("!!!respawning spectator player.")
        target_ply:ConCommand("ttt_spectator_mode 0")

        timer.Create("respawntpdelay", 0.1, 0, function()
            local spawnEntity = spawn.GetRandomPlayerSpawnEntity(target_ply)
            local spawnPos = spawnEntity:GetPos()
            local spawnEyeAngle = spawnEntity:EyeAngles()

            local corpse = corpse_find(target_ply) -- remove corpse
            if corpse then
                corpse_remove(corpse)
            end

            target_ply:SpawnForRound(true) -- prepares a dead player to be respawnd

            target_ply:SetCredits(GetStartingCredits(target_ply:GetSubRoleData().abbr)) -- gives player credits

            target_ply:SetPos(spawnPos)
            target_ply:SetEyeAngles(spawnEyeAngle or Angle(0, 0, 0))

            if target_ply:Alive() then
                timer.Remove("respawntpdelay")
                return
            end
        end)
    elseif  not target_ply:Alive() then
        print("!!!respawning death player.")
        local spawnEntity = spawn.GetRandomPlayerSpawnEntity(target_ply)
        local spawnPos = spawnEntity:GetPos()
        local spawnEyeAngle = spawnEntity:EyeAngles()

        local corpse = corpse_find(target_ply) -- remove corpse
        if corpse then
            corpse_remove(corpse)
        end

        target_ply:SpawnForRound(true) -- prepares a dead player to be respawnd

        target_ply:SetCredits(GetStartingCredits(target_ply:GetSubRoleData().abbr)) -- gives player credits

        target_ply:SetPos(spawnPos)
        target_ply:SetEyeAngles(spawnEyeAngle or Angle(0, 0, 0))

    end

end

function getRandomRole(avoidRoles)
    local availablePlayers = roleselection.GetSelectablePlayers(player.GetAll())
    local allAvailableRoles = roleselection.GetAllSelectableRolesList(#availablePlayers)
    local selectableRoles = roleselection.GetSelectableRolesList(#availablePlayers, allAvailableRoles)
    local availableRoles = {}
    local roleCount = {}

    for i = 1, #availablePlayers do
        local rd = availablePlayers[i]:GetSubRoleData()
        roleCount[rd] = (roleCount[rd] or 0) + 1
    end

    for roleData, roleAmount in pairs(selectableRoles) do
        print("RoleData:", roleData)
        print("roleAmount:", roleAmount)
        --if (not avoidRoles or not avoidRoles[roleData]) and (not roleCount[roleData] or roleCount[roleData] < roleAmount) then
        if (not roleCount[roleData] or roleCount[roleData] < roleAmount) then
            availableRoles[#availableRoles + 1] = roleData.index
        end
    end

    if #availableRoles < 1 then return end

    return availableRoles[math.random(#availableRoles)]
end


-- Spawn Bot in the same round
net.Receive("RoleManagerSpawnBotThisRound", function (len, calling_ply)
    print("Server: Spawning Bot this round.")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        local spawn_name = net.ReadString()
        target_ply = player.CreateNextBot( spawn_name )
        respawn(calling_ply, target_ply)
    end
end)

-- Respawn Bot
net.Receive("RoleManagerRespawnBot", function (len, calling_ply)
    print("Server: Respawning Bot.")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        local target_ply = net.ReadEntity()
        local spawn_name = net.ReadString()
        target_ply:Kick("Respawning Bot with different Name.")
        player.CreateNextBot( spawn_name )
    end
end)

-- Delete Bot
net.Receive("RoleManagerDeleteBot", function (len, calling_ply)
    print("Server: Seleting Bot.")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        local target_ply = net.ReadEntity()
        target_ply:Kick("Removed Bot.")
    end
end)

-- Apply Roles
net.Receive("RoleManagerApplyRole", function (len, calling_ply)
    print("Server: Applying role.")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        local ply = net.ReadEntity()
        local role_name = net.ReadString()

        local role = roles.GetByName(role_name)
        local role_index = role.index

        if role.name ~= role_name then
            --role_index = getRandomRole()
            --role = roles.GetByIndex(role_index)
            print("Server: Rolle " .. role_name .. " wurde nicht gefunden. Statdesse wird die Rolle nicht festgelegt.")
        else
            local role_credits = role:GetStartingCredits()

            ply:SetRole(role_index)
            ply:SetCredits(role_credits)
        end

        

        SendFullStateUpdate()
        --calling_ply:ChatPrint("You changed to '" .. role.name .. "' (index: " .. role_index .. ")")
        calling_ply:ChatPrint("Player: '" .. ply:Nick() .. "' role changed to " .. role_name .. ".")
    end
end)

net.Receive("RoleManagerApplyRoleNextRound", function (len, calling_ply)
    print("Server: Applying role next round.")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        local target_ply = net.ReadEntity()
        local role_name = net.ReadString()

        local sid64 = tostring(target_ply:SteamID64())

        print("STEMDI64", sid64)

        -- TODO: Abfrage durch ROLE_RANDOM.name, wenn das in einer shared file ist.
        if role_name == "random" then
            print("Apply Random ROle")
            --if IsValid(roleselection.finalRoles[sid64]) then
            roleselection.finalRoles[target_ply] = nil -- sid64] = nil
            --end
        else
            local role = roles.GetByName(role_name)
            local role_index = role.index
            print("Aplly Role:", role_name, role_index, "to player", target_ply)

            roleselection.finalRoles[target_ply] = role_index --sid64] = role_index
            print(roleselection.finalRoles[target_ply])--sid64])
        end

        calling_ply:ChatPrint("Player: '" .. target_ply:Nick() .. "' has role " .. role_name .. " next round.")
    end
end)

net.Receive("RoleManagerClearRolesNextRound", function (len, calling_ply)
    print("Server: Clear Roles for next round.")
    if calling_ply:IsAdmin() or calling_ply:IsSuperAdmin() then
        -- TODO: vielleicht lieber alle Elemente auf nil setzen, anstelle eine Neue referenz zuordnern
        for k,v in pairs(roleselection.finalRoles) do
             roleselection.finalRoles[k] = nil
        end
    end
end)