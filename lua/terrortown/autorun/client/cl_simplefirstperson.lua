PlayerControl = PlayerControl or {}

function PlayerControl.SimpleFirstPerson(c_ply, t_ply)
    local SimpleFirstPerson = {}

    local c_ply = c_ply
    local t_ply = t_ply
        --playermodel = nil,
    local invisibleBones = {}

    --local t_ang = self.t_ply:EyeAngles()
    --local c_ang = GetViewAngles() --or t_ang
    --local view_pos = self.t_ply:GetShootPos()

    -- Make Bone and all child bones invisible by shrinking them down to 0
    local function setBoneInvisible(bone)
        -- call function for all Child Bones
        for _,child in pairs(t_ply:GetChildBones(bone)) do
            setBoneInvisible(child)
        end

        -- fill in list with previous scal factors
        if not invisibleBones[bone] then
            invisibleBones[bone] = t_ply:GetManipulateBoneScale(bone)
        end

        -- shrink bones down to invisible
        t_ply:ManipulateBoneScale(bone, Vector(0,0,0))
    end

    SimpleFirstPerson.init = function()
        -- make hat invisible
        local hat = t_ply:LookupBone("ValveBiped.Bip01_Head1") or 6
        setBoneInvisible(hat)
    end

    SimpleFirstPerson.init()

    SimpleFirstPerson.CalcView = function(view, t_ply)
        -- Set Position
        local hat = t_ply:LookupBone("ValveBiped.Bip01_Head1") or 6
        local hatpos,_ = t_ply:GetBonePosition(hat)

        if hatpos ~= nil then
            view.origin = hatpos + view.angles:Up() * 5
        end

        view.znear = 1
        --view.zfar = 

        return view
    end

    -- Correct Shoot Angle for the Controlled Player according Crosshair of the controlling Player
    -- SimpleFirstPerson.CorrectShotAngle = function(origin, angles, t_ply)
    --     local view_trace = GetRealEyeTrace(origin, angles, nil, {t_ply})
    --     return (view_trace.HitPos - t_ply:GetShootPos()):Angle()
    -- end


    SimpleFirstPerson.SetBonesVisible = function(self)
        for bone, fac in pairs(invisibleBones) do
            --print("Setting Bone to visible:", bone)
            t_ply:ManipulateBoneScale(bone, fac)
            invisibleBones[bone] = nil
        end
    end

    SimpleFirstPerson.Stop = function(self)
        self:SetBonesVisible()
        c_ply = nil
        t_ply = nil
        invisibleBones = nil
    end

    return SimpleFirstPerson

end
