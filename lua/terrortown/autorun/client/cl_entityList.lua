-- global function

-- Iterate over Key of a List in sorted (alphabetical) order
-- return i: iteration position
-- return k: key
-- return id: indice in list according to revList
function pairsByKey(revList, len, f)
    local len = len or #revList
    local keys = {}
    print("********* Bot:", revList["Bot02"])
    print("********* Role:", revList["survivalist"])
    print("********* Player:", revList["DevilsThumb"])

    for k in pairs(revList) do
        print("---------------------------------------- ", k)
        keys[#keys + 1] = k
    end
    table.sort(keys, f)

    print("keys", unpack(keys))

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

------------------------------------------------------
--------------------- EntityList ---------------------
------------------------------------------------------

EntityList = {}
EntityList.__index = EntityList

setmetatable(EntityList, {
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

function EntityList:__init(init)
    self.list = {}
    self.revList = {}
end

function EntityList:__initRevList()
    for i,v in ipairs(self.list) do
        print("Add:", v.name, "to revlist with:", i)
        self.revList[v.name] = i
    end
end

function EntityList:printRevList()
    print("++++++++ Revlist[1]", self.revList[1])
    print("++++++++ RevList:", unpack(self.revList))
end

-- getter functions
function EntityList:getLen()
    return self.index or #self.list
end

function EntityList:getNames()
    local len = self.index or self.exist_index or #self.list

    print("Länge:", len)
    print("self.index", self.index)
    local names = {}
    for i, n in pairsByKey(self.revList, len) do
        names[i] = n
    end
    -- for i = 1, len do
    --     names[i] = self.list[i].name
    -- end
    return names
end

function EntityList:getByName(name)
    if self.revList[name] then
        return self.list[self.revList[name]]
    else
        return false
    end
end

-- help functions
function EntityList:sortListByName()
    local function namesort(a, b) return a.name:lower() < b.name:lower() end
    table.sort(self.list, namesort)
end

------------------------------------------------------
---------------------- RoleList ----------------------
------------------------------------------------------

RoleList = {}
RoleList.__index = RoleList

setmetatable(RoleList, {
    __index = EntityList,
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

function RoleList:__init(init)
    EntityList.__init(self, init)

    self.list = {[1] = {name = ROLE_RANDOM.name}}
    self.list = {unpack(self.list), unpack(roles.GetList())}

    print("Init RevList of Roles")
    print("Rolelist:", unpack(self.list))
    self:__initRevList()
    print("######### revList of Roles", unpack(self.revList))
    self:__initTranslation()
end

function RoleList:__initTranslation()
    for i = 1, #self.list do
        print("get Translation of:", self.list[i].name)
        self.list[i].translated = LANG.GetTranslation(self.list[i].name)
    end
end

function RoleList:refresh()
    self.list = {[1] = {name = ROLE_RANDOM.name}}
    self.list = {unpack(self.list), unpack(roles.GetList())}

    print("Refresh RevList of Roles")
    print("Rolelist:", unpack(self.list))
    self:__initRevList()
    self:__initTranslation()
end

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

