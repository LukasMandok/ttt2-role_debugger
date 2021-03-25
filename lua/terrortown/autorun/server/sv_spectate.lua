util.AddNetworkString("PCSpectate")
util.AddNetworkString("PCSpectateTarget")

local function findPlayer(info)
    if not info or info == "" then return nil end
    local pls = player.GetAll()

    for k = 1, #pls do
        local v = pls[k]
        if tonumber(info) == v:UserID() then
            return v
        end

        if info == v:SteamID() then
            return v
        end

        if string.find(string.lower(v:Nick()), string.lower(tostring(info)), 1, true) ~= nil then
            return v
        end
    end

    return nil
end


local function startSpectating(ply, target, real_first_person)
    local canSpectate = hook.Call("PCSpectate_canSpectate", nil, ply, target)
    if canSpectate == false then return end

    ply.PCSpectatingEnt = target
    ply.PCSpectating = true

    ply:ExitVehicle()

    net.Start("PCSpectate")
        net.WriteBool(target == nil)
        net.WriteBool(real_first_person == true)
        if IsValid(ply.PCSpectatingEnt) then
            net.WriteEntity(ply.PCSpectatingEnt)
        end
    net.Send(ply)

    -- TODO: bruacht man wahrscheinlich nicht.
    -- if real_first_person == true then
    --     ply:SetViewEntity(target)
    -- end

    local targetText = IsValid(target) and target:IsPlayer() and (target:Nick() .. " (" .. target:SteamID() .. ")") or IsValid(target) and "an entity" or ""
    ply:ChatPrint("You are now spectating " .. targetText)
    hook.Call("PCSpectate_start", nil, ply, target)
end


function StartPCSpectate(calling_ply, target_ply, real_first_person) 
    if target_ply == calling_ply then calling_ply:ChatPrint("Invalid target!") return end

    startSpectating(calling_ply, target_ply, real_first_person)
end



local function Spectate(ply, cmd, args)
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then ply:ChatPrint("No Access!") return end

    local target = findPlayer(args[1])
    if target == ply then ply:ChatPrint("Invalid target!") return end

    startSpectating(ply, target)
end
concommand.Add("PCSpectate", Spectate)

net.Receive("PCSpectateTarget", function(_, ply)
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then ply:ChatPrint("No Access!") return end

    startSpectating(ply, net.ReadEntity())
end)



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



local function SpectateVisibility(ply, viewEnt)
    if not ply.PCSpectating then return end

    if IsValid(ply.PCSpectatingEnt) then
        AddOriginToPVS(ply.PCSpectatingEnt:IsPlayer() and ply.PCSpectatingEnt:GetShootPos() or ply.PCSpectatingEnt:GetPos())
    end

    if ply.PCSpectatePos then
        AddOriginToPVS(ply.PCSpectatePos)
    end
end
hook.Add("SetupPlayerVisibility", "PCSpectate", SpectateVisibility)



local function setSpectatePos(ply, cmd, args)
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then ply:ChatPrint("No Access!") return end

    if not ply.PCSpectating or not args[3] then return end
    local x, y, z = tonumber(args[1] or 0), tonumber(args[2] or 0), tonumber(args[3] or 0)

    ply.PCSpectatePos = Vector(x, y, z)

    -- A position update request implies that the spectator is not spectating another player (anymore)
    ply.PCSpectatingEnt = nil
end
concommand.Add("_PCSpectatePosUpdate", setSpectatePos)



local function endSpectate(ply, cmd, args)
    print("End Spectating")
    ply.PCSpectatingEnt = nil
    ply.PCSpectating = nil
    ply.PCSpectatePos = nil
    hook.Call("PCSpectate_stop", nil, ply)

    --ply:SetViewEntity(ply)
end
concommand.Add("PCSpectate_StopSpectating", endSpectate)



local vrad = DarkRP and GM.Config.voiceradius
local voiceDistance = DarkRP and GM.Config.voiceDistance * GM.Config.voiceDistance
local function playerVoice(listener, talker)
    if not listener.PCSpectating then return end

    local canHearLocal, surround = GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)

    local PCSpectatingEnt = listener.PCSpectatingEnt
    if not IsValid(PCSpectatingEnt) or not PCSpectatingEnt:IsPlayer() then
        local spectatePos = IsValid(PCSpectatingEnt) and PCSpectatingEnt:GetPos() or listener.PCSpectatePos
        if not vrad or not spectatePos then return end

        -- Return whether the listener can hear the talker locally or distance smaller than 550
        return canHearLocal or spectatePos:DistToSqr(talker:GetShootPos()) < voiceDistance, surround
    end

    -- You can hear someone if your spectate target can hear them
    local canHear = GAMEMODE:PlayerCanHearPlayersVoice(PCSpectatingEnt, talker)

    -- you can always hear the person you're spectating
    return canHear or canHearLocal or PCSpectatingEnt == talker, surround
end
hook.Add("PlayerCanHearPlayersVoice", "PCSpectate", playerVoice)



local function playerSay(talker, message)
    local split = string.Explode(" ", message)

    if split[1] and (split[1] == "!spectate" or split[1] == "/spectate") then
        Spectate(talker, split[1], {split[2]})
        return ""
    end

end
hook.Add("PlayerSay", "PCSpectate", playerSay)



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