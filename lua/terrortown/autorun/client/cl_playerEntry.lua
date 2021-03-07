-----------------------------------------------------
-------------------- PlayerEntry --------------------
-----------------------------------------------------

PlayerEntry = {}
PlayerEntry.__index = PlayerEntry

setmetatable(PlayerEntry, {
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

function PlayerEntry:__init(data)
    print("creating PlayerEntry with role", data.role)
    self.name = data.name
    self.ent = data.ent or nil
    self.role = data.role or ROLE_RANDOM.name
    self.class = data.class or CLASS_RANDOM.name
end

function PlayerEntry:getName()
    return self.name
end

function PlayerEntry:getRole()
    return self.role
end

function PlayerEntry:setRole(role)
    self.role = role
end

function PlayerEntry:applyRole(role)
    --
end

function PlayerEntry:applyRole_nr(role)
    --
end


------------------------------------------------------
---------------------- BotEntry ----------------------
------------------------------------------------------

-- Inherits from PlayerEntry
BotEntry = {}
BotEntry.__index = BotEntry

setmetatable(BotEntry, {
    __index = PlayerEntry,
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

function BotEntry:__init(data)
    PlayerEntry.__init(self, data)
    self.spawn = data.spawn or false
    self.delete = data.spawn or false
end

function BotEntry:Reset()
    self.spawn = false
    self.delete = false
end

function BotEntry:setSpawn()
    self.spawn = true
    self.delete = false
end

function BotEntry:setDelete()
    self.spawn = false
    self.delete = true
end


function BotEntry:spawn()
    print("Spawn Bot:", self.name)
    -- send Hook, to create nextbot 
    --self.ent = player.CreateNextBot( self.name )

    -- TODO: Rolle setzen
    self:Reset()
end

function BotEntry:delete()
    print("Remove Bot:", self.name)
    -- send Hook, to delete nextbot

    self:Reset()
end

function BotEntry:disableMoving()

end
