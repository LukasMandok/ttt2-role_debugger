PlayerCamera = PlayerCamera or {}
PlayerCamera.__index = PlayerCamera

setmetatable(PlayerCamera, {
    __call = function(cls, ...)
        print("Creating PlayerCamera")
        local obj = setmetatable({}, cls)
        obj:__init(...)
        return obj
    end,
})

function PlayerCamera:__init(c_ply, t_ply, view_flag)
    self.c_ply = c_ply
    self.t_ply = t_ply

    self.view_flag        = view_flag

    self.offset           = 100
    self.v_offset  = 5
    self.h_offset = 10

    -- THird Person Mode
    self.wasOn            = false
    self.inLerp           = 0
    self.outLerp          = 1


    self.view_angles     = self.t_ply:EyeAngles()
    if self.view_angles.pitch > 90 then
        self.view_angles.pitch = self.view_angles.pitch - 360
    end
    self.corrected_angles = self.view_angles

    --print("Set initial view_angles:", t_ply:EyeAngles())
    self.view_pos        = self.t_ply:GetShootPos()
    self.c_ply_angles    = self.c_ply:EyeAngles()

    if self.view_flag == PC_CAM_ROAMING then
        -- Start Roamin
    elseif self.view_flag == PC_CAM_THIRDPERSON then
        -- Start Thirdperson
    elseif self.view_flag == PC_CAM_SIMPLEFIRSTPERSON then
        self.viewmode = PlayerCamera.SimpleFirstPerson(self.c_ply, self.t_ply)
        --c_ply:SetViewEntity(t_ply)

    elseif self.view_flag == PC_CAM_FIRSTPERSON then
        -- start Real first person
    end
end


-- hook.Add("InitPostEntity","exclserver.player.ready",function()
--     timer.Simple(0,function()
--       RunConsoleCommand("excl_ready");
--     end)
-- end)

-- Taunt Camera, shamelessly stolen from the garrysmod base.

function GetRealEyeTrace(pos, ang, filter, offset)
    offset = offset or 10000
    local trace = {}
    trace.start = pos
    trace.endpos = pos + ang:Forward() * offset
    trace.filter = filter or {}
    return util.TraceLine(trace)
end


function PlayerCamera:ShouldDrawLocalPlayer( ply, on )
    return on or self.outLerp < 1
end

function PlayerCamera:GetCameraAngles()
    return self.view_angles
end

function PlayerCamera:GetCorrectedAngles()
    return self.corrected_angles
end

function PlayerCamera:ChangeOffset( d_offset )
    self.offset = self.offset + d_offset
end

function PlayerCamera:CorrectShotAngle()
    local view_trace = GetRealEyeTrace(self.view_pos, self.view_angles, {self.t_ply})
    self.corrected_angles = (view_trace.HitPos - self.t_ply:GetShootPos()):Angle()
end

function PlayerCamera:GetViewTargetEntity()
    local trace = GetRealEyeTrace(self.view_pos, self.view_angles, {self.t_ply})
    return trace.Entity
end

function PlayerCamera:CalcView(view, ply, on )

    --local view = c_view

    -- if Third Person
    if view_flag == PC_CAM_THIRDPERSON then

        view.origin = self.t_ply:GetShootPos() -- getThirdPersonPos(t_ply)
        view.angles = self.t_ply:EyeAngles()

        --if ( !ply:Alive() ) then on = false end

        if ( self.wasOn ~= on ) then
            if ( on ) then self.inLerp = 0 end
            if ( !on ) then self.outLerp = 0 end
            self.wasOn = on
        end

        if ( !on and outLerp >= 1 ) then
            self.view_angles = view.angles * 1
            self.c_ply_angles = nil
            self.inLerp = 0
            return
        end

        if ( self.c_ply_angles == nil ) then return end
        local trace = {}
        trace.start  = view.origin + Vector(0, 0, self.v_offset) + self.view_angles:Right() * self.h_offset
        trace.endpos = view.origin + Vector(0, 0, self.v_offset) + self.view_angles:Right() * self.h_offset - self.view_angles:Forward() * self.offset
        trace.filter = {self.t_ply}

        trace = util.TraceLine(trace)
        self.view_pos = trace.HitPos + trace.HitNormal * 2

        if ( self.inLerp < 1 ) then
            self.inLerp = self.inLerp + FrameTime() * 5.0
            view.origin = LerpVector( self.inLerp, view.origin, self.view_pos )
            view.angles = LerpAngle( self.inLerp, self.c_ply_angles, self.view_angles )
            return true
        end

        if ( self.outLerp < 1 ) then
            self.outLerp = self.outLerp + FrameTime() * 3.0
            view.origin = LerpVector( 1-self.outLerp, view.origin, self.view_pos )
            view.angles = LerpAngle( 1-self.outLerp, self.c_ply_angles, self.view_angles )
            return true
        end

        -- if v_offset > 0 then
        --     view_angles = CAM.CompensateOffset(view_pos, view_angles)
        -- end

        view.angles = self.view_angles * 1
        view.origin = self.view_pos
        return true

    -- If Simple First Person
    elseif self.view_flag == PC_CAM_SIMPLEFIRSTPERSON then
        if !on then
            self.view_angles = self.t_ply:EyeAngles()
            self.view_pos = self.t_ply:GetShootPos()
            on = true
        end

        --view.origin = t_ply:GetShootPos() + view_angles:Up() * offset / 10
        view.angles = self.view_angles

        view = self.viewmode.CalcView(view, self.t_ply)

        self.view_angles = view.angles
        self.view_pos = view.origin

        return true

    -- If complex First Person
    elseif self.view_flag == PC_CAM_FIRSTPERSON then
        return

    -- If Roaming
    elseif self.view_flag == PC_CAM_ROAMING then
        print("Calc roaming view")
        return
    end
end


function PlayerCamera:CreateMove( cmd, ply, on )

    --if ( !ply:Alive() ) then on = false end
    if ( !on ) then return end

    if ( self.c_ply_angles == nil ) then
        self.c_ply_angles = self.c_ply:EyeAngles() --view_angles * 1
    end

    --
    -- Rotate our view
    --
    --if thirdperson then
        -- view_angles.pitch  = math.Clamp(view_angles.pitch + cmd:GetMouseY() * 0.01 -90, 90)
        -- view_angles.yaw    = view_angles.yaw        - cmd:GetMouseX() * 0.01
    --else
    self.view_angles.pitch  = math.Clamp(self.view_angles.pitch + cmd:GetMouseY() * 0.01, -85, 85)
    self.view_angles.yaw    = self.view_angles.yaw              - cmd:GetMouseX() * 0.01
    --end

    self.corrected_angles = self.view_angles

    if self.view_flag == PC_CAM_SIMPLEFIRSTPERSON or
        (self.view_flag == PC_CAM_THIRDPERSON and (self.v_offset ~= 0 or self.h_offset ~= 0)) then
        self:CorrectShotAngle()
    end

    -- net.Start("PlayerController:TargetAngle")
    --     net.WriteAngle(corrected_angles)
    -- net.SendToServer()

    --
    -- Lock the player's controls and angles
    --
    cmd:SetViewAngles( self.c_ply_angles )

    -- net.Start("PlayerController:TargetAngle")
    --     net.WriteAngle(view_angles)
    -- net.SendToServer()

    --cmd:ClearButtons()
    --cmd:ClearMovement()

    return true

end

function PlayerCamera:Stop()
    if self.viewmode ~= nil then
        self.viewmode:Stop()
    end
end


-- hook.Add("CreateMove","ES.Taunt.HandleMove",function()
-- 	--return true --if LocalPlayer():IsPlayingTaunt() then return true end
-- end)

-- hook.Add("ShouldDrawLocalPlayer","ES.Taunt.HandleThirdPerson",function()
-- 	if camera:ShouldDrawLocalPlayer( LocalPlayer(), true ) then return true end -- LocalPlayer():IsPlayingTaunt()
-- end)
