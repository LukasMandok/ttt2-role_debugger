ROLE_RANDOM = {id = -1, name = "random"}
CLASS_RANDOM = {id = -1, name = "random"}

print("Creating Role")

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
    print("####### RoleManager Init()")
    self.playerList = HumanList()
    self.botList = BotList()

    self.roleList = RoleList()

    gameevent.Listen( "player_spawn" )
    hook.Add( "player_spawn", "player_connect_example", function(  )
        self.botList:resetIndex()
        self.playerList:refresh()

        -- if data.bot then
        --     RoleManager.botList:updateLen()
        --     print("Updating Bot List Länge")
        -- else
        --     RoleManager.playerList:refresh()
        -- end
    end )

end

-- Refresh at Panel Opening
function RoleManager:refresh()
    self.playerList:refresh()
    self.roleList:refresh()
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