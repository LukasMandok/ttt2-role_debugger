-- FirstPerson = FirstPerson or {
--     ply = nil,

-- 	-- Animation/Rendering
-- 	entity = nil,
-- 	skelEntity = nil,
-- 	lastTick = 0,

-- 	-- Variables to detect change in model state
-- 	model = nil,
-- 	bodyGroups = nil,
-- 	materials = nil,
-- 	skin = nil,
-- 	material = nil,
-- 	color = nil,

-- 	-- Variables to detect change in pose state
-- 	weapon = nil,
-- 	sequence = nil,
-- 	reloading = false,

-- 	-- Pose-dependent variables
-- 	pose = "",
-- 	viewOffset = Vector(0, 0, 0),
-- 	neckOffset = Vector(0, 0, 0),
-- 	vehicleAngle = 0,

-- 	-- Model-dependent variables
-- 	ragdollSequence = nil,
-- 	idleSequence = nil,

-- 	-- API variables
-- 	apiBoneHide = {}
-- }

-- local bone_list = {
-- 	"ValveBiped.Bip01_Neck1",
-- }

-- function FirstPerson:GetBone(ent)
-- 	local bone = 0
-- 	for _, v in ipairs(bone_list) do
-- 		bone = ent:LookupBone(v) or 0
-- 		if bone > 0 then
-- 			ent._fp_headbone = bone
-- 			return bone
-- 		end
-- 	end
-- 	return bone
-- end

-- function FirstPerson:_debug_list_bones(ent)
-- 	local bones = ent:GetBoneCount()
-- 	local i = 0
-- 	while i < bones do
-- 		print(ent:GetBoneName(i))
-- 		i = i + 1
-- 	end
-- end

-- -- timer.Simple(0, function()

-- -- 	--Fix for https://steamcommunity.com/sharedfiles/filedetails/?id=1187366110
-- -- 	hook.Remove("PlayerSpawn", "Mae_Viewheight_Offeset")

-- -- end)