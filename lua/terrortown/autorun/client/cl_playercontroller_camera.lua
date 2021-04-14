PlayerControl = PlayerControl or {}

-- hook.Add("InitPostEntity","exclserver.player.ready",function()
--     timer.Simple(0,function()
--       RunConsoleCommand("excl_ready");
--     end)
-- end)

-- Taunt Camera, shamelessly stolen from the garrysmod base.
function PlayerControl.Camera(c_ply, t_ply, thirdperson, isRoaming)
    print("Create Camer:", c_ply, t_ply, thirdperson, isRoaming)

    local CAM = {}

    -- 
    local c_ply            = c_ply
    local t_ply            = t_ply

    local isRoaming        = isRoaming or false
    local thirdperson      = thirdperson or false

    local offset           = 128

    -- THird Person Mode
    local WasOn            = false

    local CustomAngles     = Angle( 0, 0, 0 )
    local PlayerLockAngles = nil

    local InLerp           = 0
    local OutLerp          = 1

    CAM.Init = function( self )
        if not isRoaming and not thirdperson then
            print("Init FIrst Person")
            --c_ply:SetViewEntity(t_ply)
            --c_ply:SetObserverMode(OBS_MODE_IN_EYE)
        elseif not isRoaming and thirdperson then
            --c_ply:SetViewEntity(nil)
        else
            --c_ply:SetViewEntity(nil)
        end 
    end

    CAM:Init()
    

    CAM.ShouldDrawLocalPlayer = function( self, ply, on )
        return on or OutLerp < 1
    end

    CAM.GetCameraAngle = function( self )
        return CustomAngles
    end

    CAM.ChangeOffset = function( self, d_offset )
        offset = offset + d_offset
    end

    CAM.CalcView = function( self, c_view, ply, on )

        local view = c_view
        if not isRoaming then
            -- IF THIRD PERSON
            if thirdperson then

                view.origin = t_ply:GetShootPos() -- getThirdPersonPos(t_ply)
                view.angles = t_ply:EyeAngles()

                if ( !ply:Alive() ) then on = false end

                if ( WasOn ~= on ) then
                    if ( on ) then InLerp = 0 end
                    if ( !on ) then OutLerp = 0 end
                    WasOn = on
                end

                if ( !on && OutLerp >= 1 ) then
                    print("Set Custom Angles:", view.angles)
                    CustomAngles = view.angles * 1
                    PlayerLockAngles = nil
                    InLerp = 0
                    return
                end

                if ( PlayerLockAngles == nil ) then return end
                trace = {}
                trace.start  = view.origin
                trace.endpos = view.origin - CustomAngles:Forward() * offset
                trace.filter = player.GetAll()

                trace = util.TraceLine(trace)
                local TargetOrigin = trace.HitPos + trace.HitNormal*2

                if ( InLerp < 1 ) then
                    InLerp = InLerp + FrameTime() * 5.0
                    view.origin = LerpVector( InLerp, view.origin, TargetOrigin )
                    view.angles = LerpAngle( InLerp, PlayerLockAngles, CustomAngles )
                    return true
                end

                if ( OutLerp < 1 ) then
                    OutLerp = OutLerp + FrameTime() * 3.0
                    view.origin = LerpVector( 1-OutLerp, view.origin, TargetOrigin )
                    view.angles = LerpAngle( 1-OutLerp, PlayerLockAngles, CustomAngles )
                    return true
                end

                view.angles = CustomAngles * 1
                view.origin = TargetOrigin
                return true

            -- ELSE FIRST PERSON
            else
                if !on then
                    CustomAngles = t_ply:EyeAngles()
                    on = true
                end

                view.origin = t_ply:GetShootPos() + CustomAngles:Forward() * offset / 10
                view.angles = CustomAngles

                return true
            end

        -- IF Roaming
        else
            print("Calc roaming view")
            return
        end
    end
    CAM.CreateMove = function( self, cmd, ply, on )

        if ( !ply:Alive() ) then on = false end
        if ( !on ) then return end

        if ( PlayerLockAngles == nil ) then
            PlayerLockAngles = CustomAngles * 1
        end

        --
        -- Rotate our view
        --
        --if thirdperson then
            -- CustomAngles.pitch  = math.Clamp(CustomAngles.pitch + cmd:GetMouseY() * 0.01 -90, 90)
            -- CustomAngles.yaw    = CustomAngles.yaw        - cmd:GetMouseX() * 0.01
        --else
        CustomAngles.pitch  = math.Clamp(CustomAngles.pitch + cmd:GetMouseY() * 0.01, -90, 90)
        CustomAngles.yaw    = CustomAngles.yaw        - cmd:GetMouseX() * 0.01
        --end
        --
        -- Lock the player's controls and angles
        --
        cmd:SetViewAngles( PlayerLockAngles )

        net.Start("PlayerController:TargetAngle")
            net.WriteAngle(CustomAngles)
        net.SendToServer()

        --cmd:ClearButtons()
        --cmd:ClearMovement()

        return true

    end


    return CAM
end







-- hook.Add("CreateMove","ES.Taunt.HandleMove",function()
-- 	--return true --if LocalPlayer():IsPlayingTaunt() then return true end
-- end)

-- hook.Add("ShouldDrawLocalPlayer","ES.Taunt.HandleThirdPerson",function()
-- 	if camera:ShouldDrawLocalPlayer( LocalPlayer(), true ) then return true end -- LocalPlayer():IsPlayingTaunt()
-- end)
