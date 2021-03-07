------------------------------------------------------
--------------------- PlayerList ---------------------
------------------------------------------------------
local PlayerList = {}
PlayerList.__index = PlayerList

setmetatable(PlayerList, {
    __index = EntityList,
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

function PlayerList:__init(init)
    EntityList.__init(self, init)
end

function PlayerList:getNames()
    local len = self.index or self.exist_index or #self.list

    print("Länge:", len)
    print("self.index", self.index)
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
    if self.revList[name] then
        return self.list[self.revList[name]]:getRole()
    else
        return false
    end

    -- print("Get  Role ny name", name)
    -- for i = 1, #self.list do
    --     if self.list[i].name == name then
    --         return self.list[i].role
    --     end
    -- end
    -- return false
end

-- function PlayerList:getByName(name)
--     for i = 1, #self.list do
--         if self.list[i].name == name then
--             return self.list[i]
--         end
--     end
--     return false
-- end

function PlayerList:updateRoles()
    len = self.exist_index or #self.list
    for i = 1, len do
        self.list[i].role = roles:GetByIndex(self.list[i].ent:GetRole()).name
        print("Player:", self.list[i].name, "hat role", self.list[i].role)
    end
end

-- help functions
function PlayerList:sortListByName()
    local function namesort(a, b) return a.name:lower() < b.name:lower() end
    table.sort(self.list, namesort)
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
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
    -- __newindex = function()

    -- end,
})

function HumanList:__init(init)
    PlayerList.__init(self, init)

    local players = player.GetHumans()
    for i = 1, #players do
        self:addPlayer(players[i]:Nick(), players[i], ROLE_RANDOM.name)
    end

    print("Init RevList of Human")
    self:__initRevList()
end

function HumanList:addPlayer(name, ent, role)
    print("add Player:", name, "with role:", role)
    self.list[#self.list + 1] = PlayerEntry({
            name = name,
            ent = ent,
            role = role--roles:GetByIndex(players[i]:GetRole()).name
        })
end

function HumanList:refresh()
    self:__initRevList()
    local players = player.GetHumans()
    for i = 1, #players do
        if self:getByName(players[i]:Nick()) == false then
            self:addPlayer(players[i]:Nick(), players[i], ROLE_RANDOM.name)
        end
    end
    self:sortListByName()
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
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

function BotList:__init(init)
    PlayerList.__init(self, init)

    self.max = game.MaxPlayers()
    self.exist_index = 0
    self.index = 0

    self:initExistingBots()
    print("Init RevList of Bots")
    self:__initRevList()
end

function BotList:initExistingBots()
    local bots = player.GetBots()
    self.exist_index = #bots
    self.index = #bots

    print("initializing existing bots with role:", ROLE_RANDOM.name)
    for i = 1, self.max do
        if i <= self.exist_index then
            self.list[i] = BotEntry({
                name = bots[i]:Nick(),
                ent = bots[i],
                role = ROLE_RANDOM.name, --roles:GetByIndex(bots[i]:GetRole()).name,
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

function BotList:resetIndex()
    self.exist_index = #player:GetBots()
    self.index = self.exist_index
end

function BotList:updateStatus() -- oder updateSpawn oder refresh
    self.exist_index = #player:GetBots()

    for i = start, math.min(self.index, self.exist_index) do
        self.list[i]:Reset()
    end

    if self.index > self.exist_index then
        for i = self.exist_index, self.index do
            self.list[i]:SetSpawn()
        end
    elseif self.index < self.index then
        for i = self.index, new_len, -1 do
            self.list[i]:SetDelete()
        end
    end
end