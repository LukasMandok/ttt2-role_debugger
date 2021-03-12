-- TODO: in eine shared file, damit der Server das auch kennt.
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

    -- Status
    self.apply_next_round = false

    -- Settings
    self.auto_apply = true
    self.auto_refresh = false


    -------------- Communication

    -- Player Connecting / Disconnecting

    -- TODO: Add for Players
    net.Receive("RoleManagerPlayerConnected", function ()
        local name = net.ReadString()
    end)

    net.Receive("RoleManagerPlayerDisconnected", function ()
        local name = net.ReadString()
    end)

    net.Receive("RoleManagerBotConnected", function ()
        local cur_name = net.ReadString()
        timer.Simple(0.01, function ()
            self.botList:addEntity(cur_name)
        end)
        -- TODO: refresh list entries in the display
        -- timer.Simple(0.1, function ()
        --     roleManager:refresh()
        -- end)
    end)

    net.Receive("RoleManagerBotDisconnected", function ()
        local cur_name = net.ReadString()
        --timer.Simple(0.01, function ()  -- Der Timer wird hier wahrscheinlich nicht gebraucht
        self.botList:removeEntity(cur_name)
        --end)
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
            --print("Recive Role: ", cur_role, "for", cur_name, "which is:", id)
            self.botList:updateCurrentRole(name, cur_role)
        end
    end)

    ----------- Hooks

    -- Hook to update currentroles at round start
    hook.Add("TTTBeginRound", "Update Roles at round start", function ()
        self.requestCurrentRoleList()
        self.apply_next_round = false -- reset apply next round to 0
    end)

    -- Hook to create Players if self.apply_next_round ist set before the roles are distributed
    hook.Add("TTTPrepareRound", "Create Bots before round start", function()
        print("Hook: Preparation")
        if self.apply_next_round == true then
            self.botList:spawnEntities(self.botList.processNextRound)

            print("Applying Bot Roles")
            self.botList:updateStatus()

            timer.Simple(2, function ()
                print("?????????????????? Apply Roles")
                self.botList:applyRoles(self.botList.processNextRound)
                self.botList.processNextRound = {}
            end)
            timer.Simple(2, function ()   -- TODO: Timer anpassen
                print("??????????????????? Request CUrrent Role List")
                self:requestCurrentRoleList()
            end)
        end
    end)
end

-----------------------------------------------------
---------------------- General ----------------------
-----------------------------------------------------

function RoleManager:refresh()
    self.playerList:refresh()
    self.botList:refresh()
    self.roleList:refresh()

    if self.auto_refresh then
        roleManager:setCurrentRoles()
    end

    --self.botList:displayAllRoles()
    --self.playerList:displayAllRoles()
end

function RoleManager:setCurrentRoles()
    self.playerList:setCurrentRoles()
    self.botList:setCurrentRoles()
    self.botList:updateStatus()
end

function RoleManager:updateCurrentRoles()
    self.playerList:updateCurrentRoles()
    self.botList:updateCurrentRoles()
end

function RoleManager:requestCurrentRoleList()
    --print("Cliend: Sending Role Request")
    net.Start("RoleManagerCurrentRolesRequest")
    net.SendToServer()
end


-----------------------------------------------------
---------------------- Player -----------------------
-----------------------------------------------------

function RoleManager:setPlayerRole(name, role)
    self.playerList:setRole(name, role)
end

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

function  RoleManager:resetPlayerRoles()
    self.playerList:setAllRoles("random")
    self.playerList:displayAllRoles()
end

function RoleManager:setCurrentPlayerRoles()
    self.playerList:setCurrentRoles()
end

function RoleManager:applyPlayerRoles(name)
    print("Applying Player Roles")
    -- Apply
    self.playerList:applyRoles(name)
end

function RoleManager:applyPlayerRolesNextRound(name)
    print("Applying Player Roles next Round")
    self.playerList:applyRoles_nr(name)
end


-----------------------------------------------------
------------------------ Bots -----------------------
-----------------------------------------------------

function RoleManager:setBotRole(name, role)
    --print("   Rollen:", unpack(self.botList:getRoles()))
    self.botList:setRole(name, role)
end

function RoleManager:getCurrentBotName(name)
    return self.botList:getCurrentName(name)
end

function RoleManager:changeBotListLen(len)
    self.botList:setLen(len)
    self.botList:updateStatus()
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

function  RoleManager:resetBotRoles()
    self.botList:setAllRoles("random")
    self.botList:displayAllRoles()
end

function RoleManager:setCurrentBotRoles()
    --print("---- Setting current Bot Roles")
    -- TODO: zählt nicht als selectiert -> Rollen müssen isgesamt gesetz werden.
    self.botList:setCurrentRoles()
    self.botList:updateStatus()
end

-- TODO: add name for updateStatus?
function RoleManager:applyBotRoles(name)
    self:clearBotRolesNextRound()
    self.botList:spawnEntities(name, true)

    -- too 
    print("Applying Bot Roles")
    self.botList:updateStatus()

    timer.Simple(1, function ()
        print("?????????????????? Apply Roles")
        self.botList:applyRoles(name)
    end)
    timer.Simple(1, function ()   -- TODO: Timer anpassen
        print("??????????????????? Request CUrrent Role List")
        self:requestCurrentRoleList()
    end)
end

function RoleManager:applyBotRolesNextRound(name)
    print("+Applying Bot Roles next Round+", name)
    self.botList:updateStatus()
    self.botList:applyRoles_nr(name)
end

function RoleManager:clearBotRolesNextRound()
    net.Start("RoleManagerClearRolesNextRound")
    net.SendToServer()
    self.apply_next_round = false
end

-----------------------------------------------------
----------------------- Roles -----------------------
-----------------------------------------------------

function RoleManager:getRoleList()
    return self.roleList:getNames()
end

function RoleManager:getTranslatedRoleList()
    return self.roleList:getTranslatedNames()
end

-- TODO: RoleIcons in die RoleListe einfügen
function RoleManager:getRoleIcons()
    local icons = {}
    for i = 1, #self.roleList do
        icons[i] = self.roleList[i].icon
    end
    return icons
end