Manager = {}
Manager.__index = Manager

ROLE_RANDOM = {id = -1, name = LANG.GetTranslation("submenu_debugging_random_role")}
CLASS_RANDOM = {id = -1, name = LANG.GetTranslation("submenu_debugging_random_role")}

 
setmetatable(Manager, {
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:__init(...)
        return self
    end
})

function Manager:__init(init)
    print("####### Manager Init()")
    self.playerList = HumanList()
    self.botList = BotList()

    self.roleList = {[1] = {name = ROLE_RANDOM.name}}
    self.roleList = {unpack(self.roleList), unpack(roles.GetList())}
end

-- Player

function Manager:getPlayerList()
    return self.playerList:getNames()
end

function Manager:getPlayerRoles()
    return self.playerList:getRoles()
end

-- Bots

function Manager:changeBotList(len)
    self.botList:setLen(len)
end

function Manager:getBotList()
    return self.botList:getNames()
end

function Manager:getBotRoles()
    return self.botList:getRoles()
end

function Manager:getBotLen()
    return self.botList:getLen()
end

function Manager:getRoleOfBot(name)
    return self.botList:getRoleByName(name)
end

-- Roles

function Manager:getRoleList()
    local names = {}
    for i=1, #self.roleList do
        names[i] = self.roleList[i].name
    end 
    return names
end

function Manager:getRoleIcons()
    local icons = {}
    for i=1, #self.roleList do
        icons[i] = self.roleList[i].icon
    end 
    return icons
end


-- Additional

function Manager:testing()
    print("Manager Testausgang.")
end 
