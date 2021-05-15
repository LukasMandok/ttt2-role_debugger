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
    self.all_roles_locked = false
    self.player_roles_locked = false
    self.bot_roles_locked = false 

    -- Settings
    self.auto_apply = CreateConVar( "ttt_rolemanager_auto_apply", 1, FCVAR_ARCHIVE, "Automatically activates the roles on the next round if a value is changed.", 0, 1 )
    self.auto_refresh = CreateConVar( "ttt_rolemanager_auto_refresh", 0, FCVAR_ARCHIVE, "Automatically updates the roles, if the debug menu is opened.", 0, 1 )

    self.overhead_role_icons = CreateConVar( "ttt_rolemanager_overhead_icons", 1, FCVAR_ARCHIVE, "Show overhead role icons during round.", 0, 1 )
    -------------- Communication --------------

    -- Request Convars at beginning
    -- net.Start("RoleManagerRequestBoolConvar")
    --     net.WriteString("bot_zombie")
    -- net.SendToServer()

    -- net.Receive("RoleManagerGetBoolConvar", function ()
    --     local convar = net.ReadString()
    --     if convar == "bot_zombie" then
    --         self.moving_bots = net.ReadBool()
    --     end
    -- end)

    net.Receive("RoleManagerPlayerConnected", function ()
        local name = net.ReadString()
        self.playerList:refresh()
    end)

    net.Receive("RoleManagerPlayerDisconnected", function ()
        local name = net.ReadString()
        self.playerList:refresh()
    end)

    net.Receive("RoleManagerBotConnected", function ()
        local cur_name = net.ReadString()
        timer.Simple(0.01, function ()
            print("Bot " .. cur_name .. " connected.")
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
        --local current_roles = {}
        for i = 1, len do
            local name = net.ReadString()
            local cur_role = net.ReadString()

            self.playerList:updateCurrentRole(name, cur_role)
        end
    end)

    net.Receive("RoleManagerCurrentRolesBot", function ()
        local len = net.ReadInt(10)
        --local current_roles = {}
        for i = 1, len do
            local cur_name = net.ReadString()
            local cur_role = net.ReadString()

            local name = self.botList:getCurrentNameList()[cur_name]
            self.botList:updateCurrentRole(name, cur_role)
        end
    end)

    ----------- Hooks

    -- Hook to update currentroles at round start
    hook.Add("TTTBeginRound", "Update Roles at round start", function ()
        self.requestCurrentRoleList()
        --self.apply_next_round = false -- reset apply next round to 0
    end)

    -- Hook to create Players if self.apply_next_round ist set before the roles are distributed
    hook.Add("TTTPrepareRound", "Create Bots before round start", function()
        -- Apply Roles of locked Player
        self:applyPlayerLockedRoles()
        self:applyBotLockedRoles()

        -- Apply Roles of newly created bots
        if self.apply_next_round == true then
            self.botList:spawnEntities() -- self.botList.processNextRound)

            self.botList:updateStatus()

            timer.Simple(2, function ()
                self.botList:applySeparateRoles(self.botList.processNextRound)
                self.botList.processNextRound = {}
            end)
            timer.Simple(2, function ()   -- TODO: Timer anpassen
                self:requestCurrentRoleList()
            end)
        end

        apply_next_round = false  -- reset apply next round to false
        timer.Simple(3, function()
            self.botList:respawnEntities()
        end)
    end)

    -- Draw player Icons
    hook.Add("PostDrawTranslucentRenderables", "Draw Overhead Role Icons",  function( bDepth, bSkybox )
        if self.overhead_role_icons:GetBool() == true and (GAMEMODE.round_state == ROUND_ACTIVE or GAMEMODE.round_state == ROUND_POST) then
            self:drawOverHeadRoleIcon()
        end
    end)
end

function RoleManager:close()
    hook.Remove("TTTBeginRound", "Update Roles at round start")
    hook.Remove("TTTPrepareRound", "Create Bots before round start")
    hook.Remove("PostDrawTranslucentRenderables", "Draw Overhead Role Icons")
end

-----------------------------------------------------
---------------------- General ----------------------
-----------------------------------------------------

function RoleManager:refresh()
    self.playerList:refresh()
    self.botList:refresh()
    --self.roleList:refresh()

    if self.auto_refresh:GetBool() then
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
    net.Start("RoleManagerCurrentRolesRequest")
    net.SendToServer()
end

function RoleManager:startNextRound()
    net.Start("RoleManagerRestartRound")
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
    --self:clearRolesNextRound()
    --print("Applying Player Roles")
    -- Apply
    self.playerList:applyRoles(name)
end

function RoleManager:applyPlayerRolesNextRound(name)
    --print("Applying Player Roles next Round")
    self.playerList:applyRoles_nr(name)
    self.apply_next_round = true
end

function RoleManager:setPlayerLocked(name, bool)
    self.playerList:setLocked(name, bool)
end

function RoleManager:getPlayerLocked(name)
    return self.playerList:getLocked(name)
end

function RoleManager:applyPlayerLockedRoles()
    self.playerList:applyLockedRoles()
end


-----------------------------------------------------
------------------------ Bots -----------------------
-----------------------------------------------------

function RoleManager:setBotRole(name, role)
    self.botList:setRole(name, role)
end

function RoleManager:getCurrentBotName(name)
    return self.botList:getCurrentName(name)
end

function RoleManager:changeBotListLen(len)
    self.botList:setLen(len)
    self.botList:updateStatus()
    if roleManager.auto_apply:GetBool() == true then
        self.apply_next_round = true
    end
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


function RoleManager:applyBotRoles(name)
    --self:clearRolesNextRound()
    self.botList:spawnEntities(name, true)

    -- TODO: add name for updateStatus?
    self.botList:updateStatus()

    timer.Simple(2, function ()
        self.botList:applyRoles(name)
    end)
    timer.Simple(2, function ()   -- TODO: Timer anpassen
        self:requestCurrentRoleList()
    end)
end

function RoleManager:applyBotRolesNextRound(name)
    --print("+Applying Bot Roles next Round+", name)
    self.botList:updateStatus()
    self.botList:applyRoles_nr(name)
    self.apply_next_round = true
end

function RoleManager:clearRolesNextRound()
    net.Start("RoleManagerClearRolesNextRound")
    net.SendToServer()
    self.apply_next_round = false
end

function RoleManager:setBotLocked(name, bool)
    self.botList:setLocked(name, bool)
end

function RoleManager:getBotLocked(name)
    return self.botList:getLocked(name)
end

function RoleManager:applyBotLockedRoles()
    self.botList:applyLockedRoles()
end

-----------------------------------------------------
----------------------- Roles -----------------------
-----------------------------------------------------

function RoleManager:getRoleList()
    return self.roleList:getNames()
end

function RoleManager:getRoleCategories()
    return self.roleList:getCategories()
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

function RoleManager:drawOverHeadRoleIcon()
    -- Players
    local len = #self.playerList.list
    for i = 1, len do
        local role = self.playerList.list[i].currentRole
        if role and IsValid(self.playerList.list[i].ent) and self.playerList.list[i].ent:Alive() then
            local rd = self.roleList:getByName(role)
            DrawOverheadRoleIcon(self.playerList.list[i].ent, rd.iconMaterial, rd.color)
        end
    end

    -- Bots
    len = self.botList.exist_index
    for i = 1, len do
        local role = self.botList.list[i].currentRole
        if role and IsValid(self.botList.list[i].ent) and self.botList.list[i].ent:Alive() and self.botList.list[i].ent:IsSpec() == false then
            local rd = self.roleList:getByName(role)
            DrawOverheadRoleIcon(self.botList.list[i].ent, rd.iconMaterial, rd.color)
        end
    end
end