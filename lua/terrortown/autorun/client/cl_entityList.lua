-- global function

-- Iterate over Key of a List in sorted (alphabetical) order
-- return i: iteration position
-- return k: key
-- return id: indice in list according to revList
function pairsByKey(revList, len, f)
    local len = len or #revList
    local keys = {}

    for k in pairs(revList) do
        keys[#keys + 1] = k
    end
    table.sort(keys, f)

    local i = 0
    return function()
        i = i + 1
        if i <= len then
            return i, keys[i], revList[keys[i]]
        else
            return nil
        end
    end
end

function getArrayLen(array)
    local len = 0
    for i,k in pairs(array) do
        len = len + 1
    end
    return len
end

------------------------------------------------------
--------------------- EntryList ---------------------
------------------------------------------------------

-- EntryList class (Base Class for PlayerList)
EntryList = {}
EntryList.__index = EntryList

setmetatable(EntryList, {
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

-- initializes EntryList with an empty list and an empty reverse List
function EntryList:__init(init)
    self.list = {}
    self.revList = {}
end

-- initializes revers list with the given name of the entries
function EntryList:__initRevList()
    for i,v in ipairs(self.list) do
        self.revList[v.name] = i
    end
end

-- get index value if it exists or the length of the array
-- return: (int) length of arrys
function EntryList:getLen()
    return self.index or #self.list
end

-- get List of Names of the Entries in an alphabetic order
-- return: (table) alphabetically order list of names
function EntryList:getNames()
    local len = self.index or self.exist_index or #self.list

    local names = {}
    for i, n in pairsByKey(self.revList, len) do
        names[i] = n
    end
    -- for i = 1, len do
    --     names[i] = self.list[i].name
    -- end
    return names
end

-- returns Entry with the given name or false if the name does not exist
-- return: (PlayerEntry) or false   
function EntryList:getByName(name)
    if self.revList[name] then
        return self.list[self.revList[name]]
    else
        return false
    end
end

-- sorts the EntryList by the names of the entries
-- is not needed at the moment
function EntryList:sortListByName()
    local function namesort(a, b) return a.name:lower() < b.name:lower() end
    table.sort(self.list, namesort)
end

------------------------------------------------------
---------------------- RoleList ----------------------
------------------------------------------------------

-- RoleList class inherits from EntryList
RoleList = {}
RoleList.__index = RoleList

setmetatable(RoleList, {
    __index = EntryList,
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

-- initializes RoleList with an entry (random) 
-- and the roles that are available on the server
-- also adds a translation to every entry and creates an reversed list
-- TODO: Einie eigene Klasse schreiben, damit jeder Eintrag beim Initialisieren überssetz wird und ein Icon zugewiesen wird
function RoleList:__init(init)
    EntryList.__init(self, init)

    self.list = {[1] = {name = ROLE_RANDOM.name}}
    self.list = {unpack(self.list), unpack(roles.GetSortedRoles())}

    self:__initRevList()
    self:__initTranslation()
end

-- adds a translated name to every role entry 
function RoleList:__initTranslation()
    for i = 1, #self.list do
        self.list[i].translated = LANG.GetTranslation(self.list[i].name)
    end
end

-- initializes the RoleList again
function RoleList:refresh()
    self.list = {[1] = {name = ROLE_RANDOM.name}}
    self.list = {unpack(self.list), unpack(roles.GetSortedRoles())}

    self:__initRevList()
    self:__initTranslation()
end

-- get a list with the translated 
-- return: (table) translated names (not in alphabetical order)
-- TODO: should be alphabeticall
function RoleList:getTranslatedNames()
    local names = {}
    -- for i = 1, #self.list do
    --     names[i] = self.list[i].translated
    -- end
    for i, n in pairsByKey(self.revList) do
        names[i] = self.list[self.revList[n]].translated
    end
    return names
end

function RoleList:getRolesWithCategory()

end

-- TODO: GetRole Category: Innocent, Traitor, Neutral, Killers
function RoleList:getRoleCategory(role)
    
end

