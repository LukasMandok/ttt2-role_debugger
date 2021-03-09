ROLE_RANDOM = {id = -1, name = "random"}
CLASS_RANDOM = {id = -1, name = "random"}

RoleManager = {}
RoleManager.__index = RoleManager

setmetatable(RoleManager, {
    __call = function (cls)
        local obj = setmetatable({}, cls)
        obj:__init()
        return obj
    end,
})

function RoleManager:__init()
    self.playerList = HumanList()
    self.botList = BotList()

    self.roleList = RoleList()



    -- gameevent.Listen( "player_spawn" )
    -- hook.Add( "player_spawn", "player_connect_example", function(  )
    --     self.botList:refresh()
    --     self.playerList:refresh()

    --     -- if data.bot then
    --     --     RoleManager.botList:updateLen()
    --     --     print("Updating Bot List Länge")
    --     -- else
    --     --     RoleManager.playerList:refresh()
    --     -- end
    -- end )

    -- Player Connecting / Disconnecting

    net.Receive("RoleManagerPlayerConnected", function ()
        local name = net.ReadString()
        print("Client: Player " .. name .. " connected.")
    end)

    net.Receive("RoleManagerPlayerDisconnected", function ()
        local name = net.ReadString()
        print("Client: Player " .. name .. " disconnected.")
    end)

    net.Receive("RoleManagerBotConnected", function ()
        local cur_name = net.ReadString()
        timer.Simple(0.01, function ()
            self.botList:addEntity(cur_name)
        end)
        print("Client: Bot " .. cur_name .. " connected.")
    end)

    net.Receive("RoleManagerBotDisconnected", function ()
        local cur_name = net.ReadString()
        --timer.Simple(0.01, function ()  -- Der Timer wird hier wahrscheinlich nicht gebraucht
        self.botList:removeEntity(cur_name)
        --end)
        print("Client: Bot " .. cur_name .. " disconnected.")
    end)

    -- Role List
    net.Receive("RoleManagerCurrentRolesPlayer", function ()
        local len = net.ReadInt(10)
        local current_roles = {}
        for i = 1, len do
            --current_roles[net.ReadString()] = net.ReadString()
            local name = net.ReadString()
            local cur_role = net.ReadString()

            self.playerList:updateCurrentRole(name, cur_role)
        end
    end)

    net.Receive("RoleManagerCurrentRolesBot", function ()
        local len = net.ReadInt(10)
        local current_roles = {}
        for i = 1, len do
            -- current_roles[net.ReadString()] = net.ReadString()
            local cur_name = net.ReadString()
            local cur_role = net.ReadString()
            
            -- todo: ändere CurrenNameList in zuordnung von Namen, nicht der Indice.
            local name = self.botList:getCurrentNameList()[cur_name]
            print("Recive Role: ", cur_role, "for", cur_name, "which is:", id)
            print(self.botList[id])
            self.botList:updateCurrentRole(name, cur_role)
        end
    end)

end

-- Refresh at Panel Opening
function RoleManager:refresh()
    self.playerList:refresh()
    self.roleList:refresh()
end

function RoleManager:setCurrentRoles()
    self.playerList:setCurrentRoles()
    self.botList:setCurrentRoles()
    hook.run("update_bot_role_entries")
end

function RoleManager:updateCurrentRoles()
    self.playerList:updateCurrentRoles()
    self.botList:updateCurrentRoles()
end

function RoleManager:requestCurrentRoleList()
    print("Cliend: Sending Role Request")
    net.Start("RoleManagerCurrentRolesRequest")
    net.SendToServer()
end


-- Player

function RoleManager:getPlayerList()
    self.playerList:refresh()
    return self.playerList:getNames()
end

function RoleManager:getPlayerRoles()
    return self.playerList:getRoles()
end

function RoleManager:getRoleOfPlayer(name)
    return self.playerList:getRoleByName(name)
end

-- Bots

function RoleManager:getCurrentBotName(name)
    return self.botList:getCurrentName(name)
end

function RoleManager:changeBotListLen(len)
    self.botList:setLen(len)
end

function RoleManager:getBotList()
    return self.botList:getNames()
end

function RoleManager:getBotRoles()
    return self.botList:getRoles()
end

function RoleManager:getBotLen()
    return self.botList:getLen()
end

function RoleManager:getRoleOfBot(name)
    return self.botList:getRoleByName(name)
end

function RoleManager:setCurrentBotRoles()
    print("---- Setting current Bot Roles")
    self.botList:setCurrentRoles()
end

function RoleManager:applyBotRoles()
    self.botList:updateStatus()
end

-- Roles

function RoleManager:getRoleList()
    return self.roleList:getNames()
end

function RoleManager:getTranslatedRoleList()
    return self.roleList:getTranslatedNames()
end

function RoleManager:getRoleIcons()
    local icons = {}
    for i = 1, #self.roleList do
        icons[i] = self.roleList[i].icon
    end
    return icons
end


-- Additional

function RoleManager:testing()
    print("RoleManager Testausgang.")
end

-- Create global Object 