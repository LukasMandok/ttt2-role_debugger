------------------------------------------------------
--------------------- PlayerList ---------------------
------------------------------------------------------

-- PlayerList class inherits from EntryList
local PlayerList = {}
PlayerList.__index = PlayerList

setmetatable(PlayerList, {
    __index = EntryList,
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

function PlayerList:__init(init)
    EntryList.__init(self, init)
end

-- function PlayerList:getNames()
--     local len = self.index or self.exist_index or #self.list
--     -- TODO: mit revList umsetzen

--     print("Länge:", len)
--     print("self.index", self.index)
--     local names = {}
--     for i = 1, len do
--         names[i] = self.list[i]:getName()
--     end
--     return names
-- end

-- get currently set Roles of the Entries of the Player List
-- return: arrys of names with the player roles
function PlayerList:getRoles()
    local len = self.index or #self.list
    -- TODO: mit revList umsetzen

    local roles = {}
    -- for i = 1, len do
    --     roles[i] = self.list[i]:getRole()
    -- end
    for i, n, id in pairsByKey(self.revList, len) do
        roles[i] = self.list[id]:getRole()
    end
    return roles
end

-- param: name of the player 
--   get the role of a specified player
-- return: name of the role, or false if the player does not exist
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

-- set Roles in the list Player List to the current roles of the player this round
function PlayerList:setCurrentRoles()
    local len = self.exist_index
    --for i = 1, #self.list do
    --    print("Bot List:", self.list[i].name)
    --end
    print("Len ist:", len)
    for i = 1, len do
        local old_role = self.list[i].role
        print("Player:", self.list[i].name, "hat role", self.list[i].role, "ingame:", self.list[i].currentRole, "number:", self.list[i].ent:GetSubRole())
        --self.list[i].role = roles:GetByIndex(self.list[i].ent:GetSubRole()).name
        self.list[i].role = self.list[i].currentRole
        if old_role != self.list[i].role then
            hook.Run("UpdateRoleSelection_" .. self.list[i].name)
        end
    end
end

-- updates currentRole in the Player List Entry
-- param: name (string) name of the player in the List
-- param: cur_role (string) current role that is set in the entry 
function PlayerList:updateCurrentRole(name, cur_role)
    print("Set Current Role:", cur_role, "for player:", name)
    self.list[self.revList[name]].currentRole = cur_role
end

-----------------------------------------------------
--------------------- HumanList ---------------------
-----------------------------------------------------

-- HumanList class inherits from PlayerList
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

-- initializes Human Player List and adds all players currently on the server
function HumanList:__init(init)
    PlayerList.__init(self, init)

    local players = player.GetHumans()
    for i = 1, #players do
        self:addPlayer(players[i]:Nick(), players[i], ROLE_RANDOM.name)
    end

    --print("Init RevList of Human")
    --self:__initRevList()
end

-- add Player to the HumanList and add entry in revList with given index
function HumanList:addPlayer(name, ent, role)
    --print("add Player:", name, "with role:", role)
    if not self.revList[name] then
        local id = #self.list + 1
        self.list[id] = PlayerEntry({
                name = name,
                ent = ent,
                role = role--roles:GetByIndex(players[i]:GetRole()).name
            })
        self.revList[name] = id
    end
end

-- adds all human players that are on the server to the human player list if missing
-- (it calls the addPlayer function)
-- TODO: Wenn spieler Disconnecten, muss der Eintrag entfernt werden.
function HumanList:refresh()
    self:__initRevList()
    local players = player.GetHumans()
    for _,p in ipairs(players) do
        if not self.revList[p:Nick()] then
            self:addPlayer(p:Nick(), p, ROLE_RANDOM.name)
        end
    end
end


-----------------------------------------------------
---------------------- BotList ----------------------
-----------------------------------------------------

-- Problem: der index ist eine position in der echten liste
-- aber die Namenslist ist anhand der revers List erzeugt ...
-- beide haben im falle der BotList eigentlich immer die gleiche Reihenfolge
-- das könnte aber trotzdem zu Problemen führen

-- BotList class inherits from PlayerList
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

-- initializes Bot List and calls __initExistingBots function
-- exist_index: Amount of existing bots on the server
-- index: Curentlly selected amount of bots to be displayed in the bot list (and spawned)
function BotList:__init(init)
    PlayerList.__init(self, init)

    self.max = game.MaxPlayers()
    self.exist_index = 0
    self.index = 0

    self.currentNameList = {}

    self:__initExistingBots()
    self:__initRevList()
end

-- creates a bot List with a number of entries given by the maximal available Player slots on the server
-- adds existing bots as entity to the first list entries
--
-- TODO: Namen der bereits vorhandenen Bots berücksichtigen:
--      - Echte Namen der Bots in Klammern anzeigen. und in nächster Runde durch anders benannten Bot ersetzen
function BotList:__initExistingBots()
    local existingBots = player.GetBots()
    -- local existingBotNames = {}
    -- for i,v in ipairs(player.GetBots()) do
    --     existingBotNames[v:Nick()] = i
    -- end
    
    self.exist_index = #existingBots
    self.index = #existingBots

    for i = 1, self.max do
        local name = "Bot" .. string.format("%02d", i)
        if i <= self.exist_index then
            print("Adding existing Bot:", name, existingBots[i]:Nick())
            self.currentNameList[existingBots[i]:Nick()] = name
            self.list[i] = BotEntry({
                name = name,
                currentName = existingBots[i]:Nick(),
                ent = existingBots[i],
                role = ROLE_RANDOM.name, --roles:GetByIndex(bots[i]:GetRole()).name,
                spawn = false,
                delete = false})
        else
            self.list[i] = BotEntry({
                name = name,
                ent = nil,
                role = ROLE_RANDOM.name,
                spawn = false,
                delete = false})
        end
    end
    -- Version, die die Einträge entsprechend der Namen in die Liste einordnet
    -- Bots mit hohen Namen kommen dementsprechend nicht mehr vor.

    -- print("initializing existing bots with role:", ROLE_RANDOM.name)
    -- for i = 1, self.max do
    --     n = "Bot" .. string.format("%02d", i)

    --     if existingBotNames[n] then
    --         local index = existingBotNames[n]
    --         print("existing bot:", n, "with index:", index, "und i:", i)
    --         self.list[i] = BotEntry({
    --              name = n,
    --              currentName = existingBots[index]:Nick(),
    --              ent = existingBots[index],
    --              role = ROLE_RANDOM.name, --roles:GetByIndex(bots[i]:GetRole()).name,
    --              spawn = false,
    --              delete = false})
    --     else
    --         self.list[i] = BotEntry({
    --              name = "Bot" .. string.format("%02d", i),
    --              ent = nil,
    --              role = ROLE_RANDOM.name,
    --              spawn = false,
    --              delete = false})
    --     end
    -- end

    -- old system that assigns existing bots to the first entries in the list
        
end


-- get the current Name Used by the bot in the game
-- this might be something differend than in the bot manager, if the bot was created in another way.
-- param: (string) name of the bot in the botlist
-- return: name of the bot in the game
function BotList:getCurrentName(name)
    print("getCurrentName(" .. name .. ") = " .. (self.list[self.revList[name]].currentName or "nil"))
    return self.list[self.revList[name]].currentName
end

-- get 
-- return: (table) names of the bots ingame with indices in the botList 
-- {name = id, ...}
-- TODO: ändere CurrentNameList in zuordnung von Namen
function BotList:getCurrentNameList()
    return self.currentNameList
    -- local names = {}
    -- for i, entry in pairs(self.list()) do
    --     if self.list[i].currentName then
    --         names[entry.currentName] = i
    --     end
    -- end
    -- return names
end

-- updates the currently displayed amount of entries in the bot list
-- param: (int) length of the bot list  
function BotList:setLen(len)
    self.index = len
end

-- updates the spawn and delet status of the Bot entries according to the current position of the index
function BotList:updateStatus() -- oder updateSpawn oder refresh
    self.exist_index = #player:GetBots()

    -- all bots below the index and exist_index exist allready and dont need to be spawned or deleted
    for i = 1, math.min(self.index, self.exist_index) do
        self.list[i]:resetStatus()
    end

    -- If the index is larger than the amount of existing bots,
    -- the status of all bots in between is set to spawning
    if self.index > self.exist_index then
        for i = self.exist_index, self.index do
            self.list[i]:setSpawn()
        end
    -- if the index is smaller than the amount of existing bots,
    -- flag the bots in between with the delete status
    elseif self.index < self.exist_index then
        for i = self.index, new_len, -1 do
            self.list[i]:setDelete()
        end
    end
end

-- updates the current existing bot index
function BotList:refresh()
    self.exist_index = #player:GetBots()
    self.index = self.exist_index
end

-- Adding a new Bot Entry to the list

-- TODO: die funktion wird aufgerufen, bevor der Spieler überhaupt vom Bot zur verfügung steht.
function BotList:addEntity(cur_name)
    print("++++++++++ Adding new Bot to the list.", cur_name)
    print("Bot List:", unpack(player:GetBots()))

    --local old_exist_index = self.exist_index
    self.exist_index = #player:GetBots()

    --local len = math.max(old_exist_index, self.exist_index)

    local ent = nil
    for _,e in pairs(player:GetBots()) do
        if e:Nick() == cur_name then
            ent = e
        end
    end

    -- TODO: vielleicht muss man hier noch ein bisschen mehr machen, 
    -- als einfach nur den nächsten exist_index + 1 zu verwenden 
    -- z.B. prüfen, ob der Bot schon besetzt ist.
    if not self.currentNameList[cur_name] and ent != nil then
        local i = getArrayLen(self.currentNameList) + 1
        print("neuer Index:", i)
        if i > 0 then
            print("Entity of previous bot:", self.list[i-1].ent)
        end
        self.list[i]:addEntity(ent, cur_name)
        self.currentNameList[cur_name] = self.list[i].name -- add index to current name list
        print("Entity", self.list[i].ent, "of current bot:", self.list[i].name)
    end
end


function BotList:removeEntity(cur_name)
    print("---------- Removing Bot from the list.")
    self.exist_index = #player:GetBots()

    if self.currentNameList[cur_name] then
        local i = self.revList[self.currentNameList[cur_name]]
        print("Entity of current bot:", self.list[i].ent)
        self.list[i]:removeEntity()
        self.currentNameList[cur_name] = nil -- remove index from current name list
    end
end