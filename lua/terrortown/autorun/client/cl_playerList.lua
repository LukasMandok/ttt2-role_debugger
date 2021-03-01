------------------------------------------------------
--------------------- PlayerList ---------------------
------------------------------------------------------
local PlayerList = {}
PlayerList.__index = PlayerList

setmetatable(PlayerList, {
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:__init(...)
        return self
    end,
})

function PlayerList:__init(init)
    self.list = {}
end

function PlayerList:getLen()
    return self.index or #self.list
end

function PlayerList:getNames()
    local len = self.index or #self.list
    
    local names = {}
    for i = 1, len do
        names[i] = self.list[i]:getName()
    end
    return names
end

function PlayerList:getRoles()
    local len = self.index or #self.list
    
    local roles = {}
    for i = 1, len do
        roles[i] = self.list[i]:getRole()
    end
    return roles
end

function PlayerList:getRoleByName(name)
    for i = 1, #self.list do
        if self.list[i].name == name then
            return self.list[i].role
        end
    end
end

function PlayerList:getPlayerByName(name)
    for i = 1, #self.list do
        if self.list[i].name == name then
            return self.list[i]
        end
    end
end

-----------------------------------------------------
--------------------- HumanList ---------------------
-----------------------------------------------------

-- Inherits from PlayerList
HumanList = {}
HumanList.__index = HumanList

setmetatable(HumanList, {
    __index = PlayerList,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:__init(...)
        return self
    end,
})

function HumanList:__init(init)
    PlayerList.__init(self, init)

    local players = player.GetHumans()
    for i=1, #players do 
        self.list[i] = PlayerEntry({
            name = players[i]:Nick(),
            ent = players[i],
            role = roles:GetByIndex(players[i]:GetRole()).name
        })
    end
end


-----------------------------------------------------
---------------------- BotList ----------------------
-----------------------------------------------------

-- Inherits from PlayerList
BotList = {}
BotList.__index = BotList

setmetatable(BotList, {
    __index = PlayerList,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:__init(...)
        return self
    end,
})

function BotList:__init(init)
    PlayerList.__init(self, init)

    self.max = game.MaxPlayers()
    self.exist_index = 0
    self.index = 0

    self:initExistingBots()
end

function BotList:initExistingBots()
    local bots = player.GetBots()
    self.exist_index = #bots
    self.index = #bots

    for i=1, self.max do
        if i <= self.exist_index then
            self.list[i] = BotEntry({
                name = bots[i]:Nick(),
                ent = bots[i],
                role = roles:GetByIndex(bots[i]:GetRole()).name,
                spawn = false,
                delete = false})
        else 
            self.list[i] = BotEntry({
                name = "Bot" .. string.format("%02d", i),
                ent = nil,
                role = ROLE_RANDOM.name,
                spawn = false,
                delete = false})
        end
    end
end

-- function BotList:getNames()
--     return PlayerList.getNames(self, self.index)
-- end

function BotList:setLen(len)
    self.index = len
end

function BotList:update(start)
    local start = start or 1
    for i = start, math.min(self.index, self.exist_index) do
        self.list[i]:Reset()
    end

    if self.index > self.exist_index then
        for i = self.exist_index, self.index do
            self.list[i]:SetSpawn()
        end
    elseif new_len < self.index then
        for i = self.index, new_len, -1 do
            self.list[i]:SetDelete()
        end
    end
end