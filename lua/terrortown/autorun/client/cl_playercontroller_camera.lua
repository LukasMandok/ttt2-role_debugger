PlayerControl = PlayerControl or {}

-- hook.Add("InitPostEntity","exclserver.player.ready",function()
--     timer.Simple(0,function()
--       RunConsoleCommand("excl_ready");
--     end)
-- end)

-- Taunt Camera, shamelessly stolen from the garrysmod base.

function GetRealEyeTrace(pos, ang, offset, filter)
    offset = offset or 10000
    local trace = {}
    trace.start = pos
    trace.endpos = pos + ang:Forward() * offset
    trace.filter = filter or {}
    return util.TraceLine(trace)
end

function PlayerControl.Camera(c_ply, t_ply, view_flag)
    print("Create Camer:", c_ply, t_ply, view_flag)

    local CAM = {}

    -- 
    local c_ply            = c_ply
    local t_ply            = t_ply

    local view_flag        = view_flag
    local viewmode         = nil

    local offset           = 100
    local vertical_offset  = 5
    local horizontal_offset = 10

    -- THird Person Mode
    local wasOn            = false

    local view_angles     = t_ply:EyeAngles()
    if view_angles.pitch > 90 then
        view_angles.pitch = view_angles.pitch - 360
    end
    --print("Set initial view_angles:", t_ply:EyeAngles())
    local view_pos        = t_ply:GetShootPos()
    local c_ply_angles    = c_ply:EyeAngles()

    local inLerp           = 0
    local outLerp          = 1

    CAM.Init = function()
        if view_flag == PC_CAM_ROAMING then

        elseif view_flag == PC_CAM_THIRDPERSON then

        elseif view_flag == PC_CAM_SIMPLEFIRSTPERSON then
            print("Init First Person")
            viewmode = PlayerControl.SimpleFirstPerson(c_ply, t_ply)
            --c_ply:SetViewEntity(t_ply)

        elseif view_flag == PC_CAM_FIRSTPERSON then

        end
    end

    CAM:Init()


    CAM.ShouldDrawLocalPlayer = function( self, ply, on )
        return on or outLerp < 1
    end

    CAM.GetCameraAngle = function( self )
        return view_angles
    end

    CAM.ChangeOffset = function( self, d_offset )
        offset = offset + d_offset
    end

    CAM.CorrectShotAngle = function( origin, angles )
        local view_trace = GetRealEyeTrace(origin, angles, nil, {t_ply})
        return (view_trace.HitPos - t_ply:GetShootPos()):Angle()
    end

    CAM.CalcView = function( self, view, ply, on )

        --local view = c_view

        -- if Third Person
        if view_flag == PC_CAM_THIRDPERSON then

            view.origin = t_ply:GetShootPos() -- getThirdPersonPos(t_ply)
            view.angles = t_ply:EyeAngles()

            if ( !ply:Alive() ) then on = false end

            if ( wasOn ~= on ) then
                if ( on ) then inLerp = 0 end
                if ( !on ) then outLerp = 0 end
                wasOn = on
            end

            if ( !on and outLerp >= 1 ) then
                print("Set Custom Angles:", view.angles)
                view_angles = view.angles * 1
                c_ply_angles = nil
                inLerp = 0
                return
            end

            if ( c_ply_angles == nil ) then return end
            trace = {}
            trace.start  = view.origin + Vector(0, 0, vertical_offset) + view_angles:Right() * horizontal_offset
            trace.endpos = view.origin + Vector(0, 0, vertical_offset) + view_angles:Right() * horizontal_offset - view_angles:Forward() * offset
            trace.filter = {t_ply}

            trace = util.TraceLine(trace)
            view_pos = trace.HitPos + trace.HitNormal * 2

            if ( inLerp < 1 ) then
                inLerp = inLerp + FrameTime() * 5.0
                view.origin = LerpVector( inLerp, view.origin, view_pos )
                view.angles = LerpAngle( inLerp, c_ply_angles, view_angles )
                return true
            end

            if ( outLerp < 1 ) then
                outLerp = outLerp + FrameTime() * 3.0
                view.origin = LerpVector( 1-outLerp, view.origin, view_pos )
                view.angles = LerpAngle( 1-outLerp, c_ply_angles, view_angles )
                return true
            end

            -- if vertical_offset > 0 then
            --     view_angles = CAM.CompensateOffset(view_pos, view_angles)
            -- end

            view.angles = view_angles * 1
            view.origin = view_pos
            return true

        -- If Simple First Person
        elseif view_flag == PC_CAM_SIMPLEFIRSTPERSON then
            if !on then
                print("initial view angles:", t_ply:EyeAngles())
                view_angles = t_ply:EyeAngles()
                view_pos = t_ply:GetShootPos()
                on = true
            end

            print("view_angles:", view_angles)

            --view.origin = t_ply:GetShootPos() + view_angles:Up() * offset / 10
            view.angles = view_angles

            view = viewmode.CalcView(view, t_ply)

            view_angles = view.angles
            view_pos = view.origin

            return true

        -- If complex First Person
        elseif view_flag == PC_CAM_FIRSTPERSON then
            return

        -- If Roaming
        elseif view_flag == PC_CAM_ROAMING then
            print("Calc roaming view")
            return
        end
    end


    CAM.CreateMove = function( self, cmd, ply, on )

        if ( !ply:Alive() ) then on = false end
        if ( !on ) then return end

        if ( c_ply_angles == nil ) then
            c_ply_angles = c_ply:EyeAngles() --view_angles * 1
        end

        --
        -- Rotate our view
        --
        --if thirdperson then
            -- view_angles.pitch  = math.Clamp(view_angles.pitch + cmd:GetMouseY() * 0.01 -90, 90)
            -- view_angles.yaw    = view_angles.yaw        - cmd:GetMouseX() * 0.01
        --else
        view_angles.pitch  = math.Clamp(view_angles.pitch + cmd:GetMouseY() * 0.01, -85, 85)
        view_angles.yaw    = view_angles.yaw              - cmd:GetMouseX() * 0.01
        --end

        local corrected_angles = view_angles

        if view_flag == PC_CAM_SIMPLEFIRSTPERSON or 
          (view_flag == PC_CAM_THIRDPERSON and (vertical_offset ~= 0 or horizontal_offset ~= 0)) then
            corrected_angles = CAM.CorrectShotAngle(view_pos, view_angles)
        end

        net.Start("PlayerController:TargetAngle")
            net.WriteAngle(corrected_angles)
        net.SendToServer()

       --
        -- Lock the player's controls and angles
        --
        cmd:SetViewAngles( c_ply_angles )

        -- net.Start("PlayerController:TargetAngle")
        --     net.WriteAngle(view_angles)
        -- net.SendToServer()

        --cmd:ClearButtons()
        --cmd:ClearMovement()

        return true

    end

    CAM.Stop = function(self)
        if viewmode ~= nil then
            viewmode:Stop()
        end
    end

    return CAM
end







-- hook.Add("CreateMove","ES.Taunt.HandleMove",function()
-- 	--return true --if LocalPlayer():IsPlayingTaunt() then return true end
-- end)

-- hook.Add("ShouldDrawLocalPlayer","ES.Taunt.HandleThirdPerson",function()
-- 	if camera:ShouldDrawLocalPlayer( LocalPlayer(), true ) then return true end -- LocalPlayer():IsPlayingTaunt()
-- end)
