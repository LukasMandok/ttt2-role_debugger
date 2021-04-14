local function findPlayer(info)
    if not info or info == "" then return nil end

    for _,ply in pairs(player.GetAll()) do
        if tonumber(info) == ply:UserID() then
            return ply
        end

        if info == ply:SteamID() then
            return ply
        end

        if string.find(string.lower(ply:Nick()), string.lower(tostring(info)), 1, true) ~= nil then
            return ply
        end
    end

    return nil
end

/*---------------------------------------------------------------------------
Define PlayerControllerSpectate Class 
---------------------------------------------------------------------------*/

local PCSpectate = {}
PCSpectate.__index = PCSpectate

setmetatable(PCSpectate, {
    --__index = , super class
    __call = function (cls, ...)
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

util.AddNetworkString("PCSpectate")
util.AddNetworkString("PCSpectateTarget")
util.AddNetworkString("PCSpectate_PositionUpdate")
util.AddNetworkString("PCSpectate_EndSpectating")

/*---------------------------------------------------------------------------
Initialize with controlling and target player ans start Spectating for those players.
---------------------------------------------------------------------------*/
function PCSpectate:__init(c_ply, t_ply, realFirstPerson)
    local canSpectate = hook.Call("PCSpectate_canSpectate", nil, self.c_ply, self.t_ply) or true
    if canSpectate == false then return end

    if not IsValid(c_ply) or not IsValid(t_ply) then return end

    self.c_ply = c_ply
    self.t_ply = t_ply

    self.realFirstPerson = realFirstPerson or false

    self.isActive = true

    self:startSpectating()
end

function PCSpectate:startSpectating()

    self.c_ply.isSpectating = true
    self.c_ply.spectatePos = nil -- TODO: starting Position
    self.c_ply.spectateEnt = self.t_ply
    self.c_ply.PCSpectate = self

    self.c_ply:ExitVehicle()

    net.Start("PCSpectate")
        net.WriteBool(false) -- dont start with roaming
        net.WriteBool(self.realFirstPerson)
        if IsValid(self.t_ply) then
            net.WriteEntity(self.t_ply)
        end
    net.Send(self.c_ply)

    -- TODO: bruacht man wahrscheinlich nicht.
    -- if realFirstPerson == true then
    --     ply:SetViewEntity(target)
    -- end

    local targetText = IsValid(self.t_ply) and self.t_ply:IsPlayer() and (self.t_ply:Nick() .. " (" .. self.t_ply:SteamID() .. ")") or IsValid(self.t_ply) and "an entity" or ""
    self.c_ply:ChatPrint("You are now isSpectating " .. targetText)
    hook.Call("PCSpectate_start", nil, self.c_ply, self.t_ply)
end

-- Can be called on the 
function PCSpectate:endSpectating()
    print("End Spectating function")
    if self.isActive then 

        local c_ply = self.c_ply

        -- Set Player Info
        self.c_ply.isSpectating = nil
        self.c_ply.spectatePos = nil
        self.c_ply.PCSpectate = nil

        self.isActive = nil
        self.c_ply = nil
        self.t_ply = nil

        net.Start("PCSpectate_EndSpectating")
        net.Send(c_ply)
        
        hook.Run("PCSpectate_EndSpectating", c_ply)
    end
    --self.c_ply.PCSpectate = nil
end





local function SpectateVisibility(ply, viewEnt)
    if not ply.isSpectating then return end

    if IsValid(ply.spectateEnt) then
        AddOriginToPVS(ply.spectateEnt:IsPlayer() and ply.spectateEnt:GetShootPos() or ply.spectateEnt:GetPos())
    end

    if ply.spectatePos then
        AddOriginToPVS(ply.spectatePos)
    end
end
hook.Add("SetupPlayerVisibility", "PCSpectate", SpectateVisibility)



-- local function setSpectatePos_(ply, cmd, args)
--     if not (ply:IsAdmin() or ply:IsSuperAdmin()) then ply:ChatPrint("No Access!") return end

--     if not ply.isSpectating or not args[3] then return end
--     local x, y, z = tonumber(args[1] or 0), tonumber(args[2] or 0), tonumber(args[3] or 0)

--     ply.spectatePos = Vector(x, y, z)

--     -- A position update request implies that the spectator is not isSpectating another player (anymore)
--     ply.spectateEnt = nil
-- end
-- concommand.Add("_PCSpectatePosUpdate", setSpectatePos_)


local function setSpectatePos(ply, vec)
    if not ply.isSpectating then return end
    ply.spectatePos = vec
end

net.Receive("PCSpectate_PositionUpdate", function(_, ply)
    if ply:IsAdmin() or ply:IsSuperAdmin() then
        setSpectatePos(ply, net.ReadVector())
    else
        ply:ChatPrint("No Access!")
    end
end)




local vrad = DarkRP and GM.Config.voiceradius
local voiceDistance = DarkRP and GM.Config.voiceDistance * GM.Config.voiceDistance
local function playerVoice(listener, talker)
    if not listener.isActive then return end

    local canHearLocal, surround = GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)

    local spectateEnt = listener.spectateEnt
    if not IsValid(spectateEnt) or not spectateEnt:IsPlayer() then
        local spectatePos = IsValid(spectateEnt) and spectateEnt:GetPos() or listener.PCSpectatePos
        if not vrad or not spectatePos then return end

        -- Return whether the listener can hear the talker locally or distance smaller than 550
        return canHearLocal or spectatePos:DistToSqr(talker:GetShootPos()) < voiceDistance, surround
    end

    -- You can hear someone if your spectate target can hear them
    local canHear = GAMEMODE:PlayerCanHearPlayersVoice(spectateEnt, talker)

    -- you can always hear the person you're isSpectating
    return canHear or canHearLocal or spectateEnt == talker, surround
end
hook.Add("PlayerCanHearPlayersVoice", "PCSpectate", playerVoice)


-- ULX' !spectate command conflicts with mine
-- The concommand "ulx spectate" should still work.
local function fixAdminModIncompat()
    if ULib then
        ULib.removeSayCommand("!spectate")
    end

    if serverguard then
        serverguard.command:Remove("spectate")
    end
end
hook.Add("InitPostEntity", "PCSpectate", fixAdminModIncompat)







---- Access from outside:

-- start
function StartPCSpectate(c_ply, t_ply, realFirstPerson) 
    if t_ply == c_ply then c_ply:ChatPrint("Invalid target!") return end

    return PCSpectate(c_ply, t_ply, realFirstPerson)
end

-- end
function EndPCSpectate(c_ply)
    if c_ply.PCSpectate then
        c_ply.PCSpectate:endSpectating()
        --c_ply.PCSpectate = nil
    else
        print("!!!!  Player was not spectating yet.")
    end
end



---- Command Access

-- start
local function SpectateCommand(ply, cmd, args)
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then ply:ChatPrint("No Access!") return end

    local target = findPlayer(args[1])
    --if target == ply then ply:ChatPrint("Invalid target!") return end
    --PCSpectate(ply, target)

    StartPCSpectate(ply, target)
    
end
concommand.Add("PCSpectate", SpectateCommand)

net.Receive("PCSpectateTarget", function(_, ply)
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then ply:ChatPrint("No Access!") return end

    EndPCSpectate(ply)
    StartPCSpectate(ply, net.ReadEntity())
    --ply.PCSpectate = PCSpectate(ply, net.ReadEntity())
end)

local function playerSay(talker, message)
    local split = string.Explode(" ", message)
    print("Message;", split[1], split[2])

    if split[1] and (split[1] == "!spectate" or split[1] == "/spectate") then
        StartPCSpectate(talker, split[1], {split[2]})
        return ""
    end

end
hook.Add("PlayerSay", "PCSpectate", playerSay)



-- end
-- local function endSpectateCommand(ply, cmd, args)
--     print("End SPectation from Command", ply)
--     -- ply.PCSpectate:endSpectating()
--     -- ply.PCSpectate = nil

--     EndPCSpectate(ply)
-- end
-- concommand.Add("PCSpectate_StopSpectating", endSpectateCommand)

net.Receive("PCSpectate_EndSpectating", function (_,ply)
    print("Received:", PCSpectate_EndSpectating)
    if ply.isSpectating then
        EndPCSpectate(ply)
    end
end)


-- tp
local function TPToPos(ply, cmd, args)
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then ply:ChatPrint("No Access!") return end

    local x, y, z = string.match(args[1] or "", "([-0-9\\.]+),%s?([-0-9\\.]+),%s?([-0-9\\.]+)")
    local vx, vy, vz = string.match(args[2] or "", "([-0-9\\.]+),%s?([-0-9\\.]+),%s?([-0-9\\.]+)")
    local pos = Vector(tonumber(x), tonumber(y), tonumber(z))
    local vel = Vector(tonumber(vx or 0), tonumber(vy or 0), tonumber(vz or 0))

    if not args[1] or not x or not y or not z then return end

    ply:SetPos(pos)

    if vx and vy and vz then ply:SetVelocity(vel) end
    hook.Call("FTPToPos", nil, ply, pos)

end
concommand.Add("FTPToPos", TPToPos)