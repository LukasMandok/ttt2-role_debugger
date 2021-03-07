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
    for k,v in pairs(self.list) do
        print("Add:", v.name, "to revlist with:", k)
        self.revList[v.name] = k
    end
end

function EntityList:getLen()
    return self.index or #self.list
end

function EntityList:getNames()
    local len = self.index or self.exist_index or #self.list

    print("Länge:", len)
    print("self.index", self.index)
    local names = {}
    for i = 1, len do
        names[i] = self.list[i].name
    end
    return names
end

function EntityList:getByName(name)
    if self.revList[name] then
        return self.list[self.revList[name]]
    else
        return false
    end
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
    for i = 1, #self.list do
        names[i] = self.list[i].translated
    end
    return names
end