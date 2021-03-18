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
end

function PlayerList:setRole(name, role)
    self.list[self.revList[name]]:setRole(role)
end

function PlayerList:setAllRoles(role)
    local role = role or ROLE_RANDOM.name
    for _,entry in pairs(self.list) do
        entry:setRole(role)
    end
end

-- set Roles in the list Player List to the current roles of the player this round
function PlayerList:setCurrentRoles()
    local len = self.exist_index or #self.list

    for i = 1, len do
        local old_role = self.list[i].role
        --print("Player:", self.list[i].name, "hat role", self.list[i].role, "ingame:", self.list[i].currentRole, "number:", self.list[i].ent:GetSubRole())
        --self.list[i].role = roles:GetByIndex(self.list[i].ent:GetSubRole()).name
        self.list[i].role = self.list[i].currentRole
        if old_role ~= self.list[i].role then
            self:displayRole(self.list[i].name)
        end
    end
end

-- TODO: Aus der PlayerList woanders hin verschieben
-- displays currently selected role for alle Player activ in the 
function PlayerList:displayAllRoles()
    local len = self.index or #self.list
    for i = 1, len do
        self:displayRole(self.list[i].name)
    end
end

-- TODO: Aus der PlayerList woanders hin verschieben
function PlayerList:displayRole(name)
    hook.Run("UpdateRoleSelection_" .. name)
end

-- updates currentRole in the Player List Entry
-- param: name (string) name of the player in the List
-- param: cur_role (string) current role that is set in the entry 
function PlayerList:updateCurrentRole(name, cur_role)
    --print("Set Current Role:", cur_role, "for player:", name)
    -- for n_c, n in pairs(self.currentNameList) do
    --     print("current Name:", n_c, "name:", n)
    -- end
    --print("Name:", name)
    --print("Index:", self.revList[name])
    self.list[self.revList[name]].currentRole = cur_role
end

function PlayerList:applyRoles(name)
    if IsValid(name) then
        self.list[self.revList[name]]:applyRole()
    else
        local len = self.index or #self.list
        for i = 1, len do
            self.list[i]:applyRole()
        end
    end
end

function PlayerList:applySeparateRoles(list)
    for i,entry in pairs(list) do
        entry:applyRole()
    end
end

function PlayerList:applyRoles_nr(name)
    if name then
        --print("Apply Role next round for:  " .. name )
        self.list[self.revList[name]]:applyRole_nr()
    else
        local len = self.index or #self.list
        --print("Apply Role next round for all.")
        for i = 1, len do
            self.list[i]:applyRole_nr()
        end
    end
end

function PlayerList:setLocked(name, bool)
    self.list[self.revList[name]]:setLocked(bool)
end

function PlayerList:getLocked(name)
    return self.list[self.revList[name]]:getLocked()
end

function PlayerList:applyLockedRoles(name)
    if name then
        if self.list[self.revList[name]]:getLocked() == true then
            print("Apply Locked Rote to:", name)
            self.list[self.revList[name]]:applyRole_nr()
        end
    else
        local len = self.index or #self.list
        print("Apply LOCKED Role next round for all!!!!")
        for i = 1, len do
            if self.list[i]:getLocked() == true then
                print("Apply Locked Rote to:", self.list[i].name)
                self.list[i]:applyRole_nr()
            end
        end
    end
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
    self.addNewEntity = {}
    self.processNextRound = {}

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
            --print("Adding existing Bot:", name, existingBots[i]:Nick())
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
end


-- get the current Name Used by the bot in the game
-- this might be something differend than in the bot manager, if the bot was created in another way.
-- param: (string) name of the bot in the botlist
-- return: name of the bot in the game
function BotList:getCurrentName(name)
    --print("getCurrentName(" .. name .. ") = " .. (self.list[self.revList[name]].currentName or "nil"))
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

-- TODO: Funktioniert nocht nicht - fehler mit CurrentName List
-- TODO: Scheint ebenfalls in der nächsten Runde aufgehoben zu sein.
-- deletes the old currentNameList and fills it with newly updated names in game
-- updates the currentName for every ListEntry
function BotList:updateCurrentNames()
    self.currentNameList = {}
    for i = 1, self.exist_index do
        local cur_name = self.list[i].ent:Nick()
        self.list[i].currentName = cur_name
        self.currentNameList[cur_name] = self.list[i].name
    end
end

-- updates the currently displayed amount of entries in the bot list
-- param: (int) length of the bot list  
function BotList:setLen(len)
    self.index = len
end

-- todo: Add Name Parameter
-- updates the spawn and delet status of the Bot entries according to the current position of the index
function BotList:updateStatus() -- oder updateSpawn oder refresh
    self.exist_index = #player:GetBots()

    -- all bots below the index and exist_index exist allready and dont need to be spawned or deleted
    for i = 1, math.min(self.index, self.exist_index) do
        self.list[i]:resetStatus()
    end

    for i = 1, #self.list do
        if i <= self.index and i <= self.exist_index then
            self.list[i]:resetStatus()

        elseif i > self.exist_index and i <= self.index then    -- If the index is larger than the amount of existing bots,
            self.list[i]:setSpawn()                             -- the status of all bots in between is set to spawning

        elseif i > self.index and i <= self.exist_index then    -- if the index is smaller than the amount of existing bots,
            self.list[i]:setDelete()                            -- flag the bots in between with the delete status

        else
            self.list[i]:resetStatus()
        end
    end

--     if self.index > self.exist_index then
--         print("Set Spawn")
--         for i = math.max(self.exist_index,1), self.index do
--             print(i)
--             self.list[i]:setSpawn()
--         end
--    elseif self.index < self.exist_index then
--         print("Set Delete", self.index)
--         for i = math.max(self.index, 1), self.exist_index do
--             print( i)
--             self.list[i]:setDelete()
--         end
--     end
end

-- updates the current existing bot index
function BotList:refresh()
    --print("Updating BotList indices")
    self.exist_index = #player:GetBots()
    self.index = self.exist_index
end

-- Adding a new Bot Entry to the list

-- TODO: die funktion wird aufgerufen, bevor der Spieler überhaupt vom Bot zur verfügung steht.
function BotList:addEntity(cur_name)
    --local old_exist_index = self.exist_index
    self.exist_index = #player:GetBots()

    --local len = math.max(old_exist_index, self.exist_index)

    local ent = nil
    for _,e in pairs(player:GetBots()) do
        if e:Nick() == cur_name then
            ent = e
        end
    end

    -- If the bot was created with the RoleManager and an entry in addNewEntity was created
    -- the new entity is added to the BotList Entry and the cur_name is removed from the addNewEntity List
    if self.addNewEntity[cur_name] and ent ~= nil then
        print("Add Entity from addNewEntityList", cur_name, self.addNewEntity[cur_name])
        local i = self.revList[self.addNewEntity[cur_name]]
        self.list[i]:addEntity(ent, cur_name)
        self.addNewEntity[cur_name] = nil
        self.currentNameList[cur_name] = self.list[i].name

    -- TODO: vielleicht muss man hier noch ein bisschen mehr machen, 
    -- als einfach nur den nächsten exist_index + 1 zu verwenden 
    -- z.B. prüfen, ob der Bot schon besetzt ist.
    elseif not self.currentNameList[cur_name] and ent ~= nil then
        local i = getArrayLen(self.currentNameList) + 1
        self.list[i]:addEntity(ent, cur_name)
        self.currentNameList[cur_name] = self.list[i].name -- add index to current name list
        --print("Entity", self.list[i].ent, "of current bot:", self.list[i].name)
    end
end

-- removing an entity from a botList entry
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

-- TODO: add Name Parameter
-- If the name of the entities is not changed, a bot name must be choosen, that is not in currentNames
function BotList:spawnEntities(name, this_round, separateList)
    list = separateList or self.list
    for i = 1, #list do
        print(list[i].name, "Spawn:", list[i].spawn, "Delete:", list[i].delete)
        if list[i].spawn == true then
            local spawn_name = list[i].name

            -- Change Bot Name, if it already exists
            num = getArrayLen(self.currentNameList) + 1
            while self.currentNameList[spawn_name] do
                spawn_name = "Bot" .. string.format("%02d", num)
                num = num + 1
            end

            print("######## Add entry to entity list: " .. spawn_name .. " = " .. list[i].name)
            self.addNewEntity[spawn_name] = list[i].name
            list[i]:spawnEntity(spawn_name, this_round)
            -- If the Name is already in the currentNameList, the addEntry function is not called: (if not self.currentNameList[cur_name] and ent ~= nil)
            self.currentNameList[spawn_name] = list[i].name

        elseif list[i].delete == true then
            print("###### Rrmove Entry:" .. list[i].name)
            self.currentNameList[list[i].currentName] = nil
            list[i]:deleteEntity()
        end
    end
end

function BotList:respawnEntities(name)
    if name then
        print("ReSpawn Enity:")
        self.list[self.revList[name]]:respawnEntity()
        self.addNewEntity[name] = name
    else
        for i = 1, self.exist_index do
            local name = self.list[i].name 
            if self.list[i].name ~= self.list[i].currentName then
                print(i, "Replacing: ", self.list[i].currentName, "by: ", name)
                self.list[i]:respawnEntity()
                self.addNewEntity[name] = name
            end
        end
    end
end

-- Setzt analog zum Player die Rollen für nächste Rund, falls die entities existieren.
-- Ansonsten wird eine Liste aufgefüllt, die zu begin der nächsten Vorbereitungsphase abgearbeitet wird.
function BotList:applyRoles_nr(name)
    if name then
        -- TODO: hier muss überprüft werden, ob der eintrag schon in der liste ist
        local i = self.revList[name]
        if IsValid(self.list[i].ent) then
            print("Apply Role next round for:  " .. name )
            self.list[i]:applyRole_nr()
        else
            print("Entity not created yet: store in table for next round for: " .. name)
            self.processNextRound[#self.processNextRound + 1] = self.list[i]
        end
    else
        self.processNextRound = {}
        local len = self.index or #self.list
        --print("Apply Role next round for all.")
        for i = 1, len do
            if IsValid(self.list[i].ent) then
                print("Apply Role next round")
                self.list[i]:applyRole_nr()
            else
                print("Entity not created yet: store in table for next round.")
                self.processNextRound[#self.processNextRound + 1] = self.list[i]
            end
        end
    end
end




-- TODO: Update Names bevor creating new entities.
-- function BotList:updateNames(name)
--     if name then
--         print("Change Name of Bot:  " .. name )
--         self.list[self.revList[name]]:updateName()
--     else
--         print("CHange Name of all Bots.")
--         for i = 1, self.exist_index do
--             self.list[i]:updateName()
--         end
--     end
-- end