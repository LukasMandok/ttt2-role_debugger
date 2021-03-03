ROLE_RANDOM = {id = -1, name = LANG.GetTranslation("submenu_debugging_random_role")}
CLASS_RANDOM = {id = -1, name = LANG.GetTranslation("submenu_debugging_random_role")}

RoleManager = {}
RoleManager.__index = RoleManager

setmetatable(RoleManager, {
    __call = function (cls)
        local self = setmetatable({}, cls)
        self:__init()
        return self
    end,
})

function RoleManager:__init()
    print("####### RoleManager Init()")
    self.playerList = HumanList()
    self.botList = BotList()

    self.roleList = {[1] = {name = ROLE_RANDOM.name}}
    self.roleList = {unpack(self.roleList), unpack(roles.GetList())}

    gameevent.Listen( "player_connect" ) -- funkioniert nicht
    gameevent.Listen( "player_spawn" )
    hook.Add( "player_spawn", "player_connect_example", function( data )
        print("Hook got called: player_connect", data.bot)
        self.botList:updateLen()
        self.playerList:refresh()

        -- if data.bot then
        --     RoleManager.botList:updateLen()
        --     print("Updating Bot List Länge")
        -- else
        --     RoleManager.playerList:refresh()
        -- end
    end )

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

function RoleManager:changeBotList(len)
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

-- Roles

function RoleManager:getRoleList()
    local names = {}
    for i=1, #self.roleList do
        names[i] = self.roleList[i].name
    end 
    return names
end

function RoleManager:getRoleIcons()
    local icons = {}
    for i=1, #self.roleList do
        icons[i] = self.roleList[i].icon
    end 
    return icons
end


-- Additional

function RoleManager:testing()
    print("RoleManager Testausgang.")
end 
