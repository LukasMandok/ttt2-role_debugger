-----------------------------------------------------
-------------------- PlayerEntry --------------------
-----------------------------------------------------

-- PlayerEntity Class (Base Class)
PlayerEntry = {}
PlayerEntry.__index = PlayerEntry

setmetatable(PlayerEntry, {
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

-- param: (table) data for initialization
-- initializes a Player Entry with the given data (name, ent, role, class)
-- stadnard values for ent = nil, role = random, class = random
function PlayerEntry:__init(data)
    --print("creating PlayerEntry with role", data.role)
    self.name = data.name
    self.ent = data.ent or nil

    self.currentRole = nil
    self.role = data.role or ROLE_RANDOM.name
    self.role_locked = data.role_locked or false

    self.currentClass = nil
    self.class = data.class or CLASS_RANDOM.name
    self.class_locked = data.class_locked or false
end

-- return: Player Name
function PlayerEntry:getName()
    return self.name
end

-- return: Player Role
function PlayerEntry:getRole()
    return self.role
end

-- sets Role of the player in the list
function PlayerEntry:setRole(role)
    --print("         Setting role: " .. role .. " for player: " .. self.name )
    self.role = role
end

-- applys role to the entity of the player 
-- TODO: Was passiert mit Random Roles
function PlayerEntry:applyRole()
    local role_name = self.role

    print("Apply Role: " .. role_name .. " to player " .. self.name)
    print("Current role:", self.currentRole)
    if not IsValid(self.ent) then
        print("Entity von Player " .. self.name .. " existiert nicht.")
    elseif GetRoundState() == 1 or GetRoundState() == 2 then
        print("The Round has not yet been started! Applying role next round.")
        self:applyRole_nr()
    elseif not self.ent:Alive() then
        print("Player is not alive.")
    elseif self.currentRole == role_name then
        print("Der Spieler hat bereits diese Rolle")
    else
        net.Start("RoleManagerApplyRole")
        net.WriteEntity(self.ent)
        net.WriteString(role_name)
        net.SendToServer()
    end

end

-- applys role to the entity of the player next round
function PlayerEntry:applyRole_nr()
    local role_name = self.role
    print("Apply Role: " .. role_name .. " to player " .. self.name .. "Current role:", tostring(self.currentRole))
    if not IsValid(self.ent) then
        print("Entity von Player " .. self.name .. " existiert nicht.")
    else
        net.Start("RoleManagerApplyRoleNextRound")
            net.WriteEntity(self.ent)
            net.WriteString(role_name)
        net.SendToServer()
    end
end

function PlayerEntry:setLocked(bool)
    --print("Set Locked of: " .. self.name .. " to: " .. tostring(bool))
    self.role_locked = bool
end

function PlayerEntry:getLocked()
    --print("Get Locked of " .. self.name, tostring(self.role_locked))
    return self.role_locked
end

------------------------------------------------------
---------------------- BotEntry ----------------------
------------------------------------------------------

-- BotEntry Class  Inherits from PlayerEntry
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

-- initializes Bot entry with 2 additional entries
-- the spawn status and the delete status 
function BotEntry:__init(data)
    PlayerEntry.__init(self, data)
    self.currentName = data.currentName or nil  -- TODO: Wahrscheinlich wieder entfernen, wird sowieso nicht richtig benutzt.
    self.spawn = data.spawn or false
    self.delete = data.delete or false
end

-- reset status of the bot to the default values 
-- (spawn = false, delete = false)
function BotEntry:resetStatus()
    self.spawn = false
    self.delete = false
end

-- set spawn status to true and delete to false
function BotEntry:setSpawn()
    self.spawn = true
    self.delete = false
end

-- set spawn status to false and delete to true
function BotEntry:setDelete()
    self.spawn = false
    self.delete = true
end

-- adds a new entity to the entry and sets the Current name
function BotEntry:addEntity(ent, cur_name)
    self:resetStatus()
    self.ent = ent
    self.currentName = cur_name
end


-- adds a new entity to the entry and sets the Current name
function BotEntry:removeEntity()
    self:resetStatus()
    self.ent = nil
    self.currentName = nil
    self.currentRole = nil
end

-- function BotEntry:updateName()
--     print("Update Bot Entry Name")
--     net.Start("RoleManagerChangeBotName")
--         net.WriteEntity(self.ent)
--         net.WriteString(self.name)
--     net.SendToServer()
-- end

-- spawns a new entity of the bot
-- TODO: muss noch implementiert werden
-- TODO Funktion schreiben (vielleicht sollte addEntity nicht ausgeführt werden, da diese funktion durch das COnnecten des Bots ausgelöst wird)
function BotEntry:spawnEntity(spawn_name, this_round)
    print("Spawn Bot:", spawn_name)
    self.currentName = spawn_name
    if this_round == false then
        net.Start("RoleManagerSpawnBot")
            net.WriteString(spawn_name)
        net.SendToServer()
    else
        net.Start("RoleManagerSpawnBotThisRound")
            net.WriteString(spawn_name)
        net.SendToServer()
    end

    self:resetStatus()
end

-- TODO: Funktion schreien und implementieren
function BotEntry:respawnEntity()
    --self.currentName = spawn_name TODO: Muss an das machen? Eigentlich wird die Current Name List beim Spawn gesetzt.
    print("Repawn Bot:", self.name)
    net.Start("RoleManagerRespawnBot")
        net.WriteEntity(self.ent)
        net.WriteString(spawn_name)
    net.SendToServer()
end

-- deletes the entity of the bot entry
-- TODO: muss noch implementiert werden
function BotEntry:deleteEntity()
    print("Remove Bot:", self.name)
    self.currentName = nil
    net.Start("RoleManagerDeleteBot")
        net.WriteEntity(self.ent)
    net.SendToServer()

    self:resetStatus()
end


-- enables or disables the moving status of a bot 
-- TODO: status and function need to be implemented
function BotEntry:setMoving()

end
