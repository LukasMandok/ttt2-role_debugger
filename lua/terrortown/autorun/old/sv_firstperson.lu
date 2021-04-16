local cvarStaticEnabled = CreateConVar("sv_fp_staticheight", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Statically adjust players' view heights to match their models")
local cvarHeightEnabled = CreateConVar("sv_fp_dynamicheight", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Dynamically adjust players' view heights to match their models")
local cvarHeightMin = CreateConVar("sv_fp_dynamicheight_min", 16, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Minimum view height")
local cvarHeightMax = CreateConVar("sv_fp_dynamicheight_max", 64, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Maximum view height")

FirstPerson = FirstPerson or {}

local bone_list = {
	"ValveBiped.Bip01_Neck1",
}

function FirstPerson:GetBone(ent)
	local bone = 0
	for _, v in ipairs(bone_list) do
		bone = ent:LookupBone(v) or 0
		if bone > 0 then
			ent._fp_headbone = bone
			return bone
		end
	end
	return bone
end

function FirstPerson:_debug_list_bones(ent)
	local bones = ent:GetBoneCount()
	local i = 0
	while i < bones do
		print(ent:GetBoneName(i))
		i = i + 1
	end
end

local function GetViewOffsetValue(ply, sequence, offset)

	local height

	local entity = ents.Create("base_anim")
	entity:SetModel(ply:GetModel())

	local bone = FirstPerson:GetBone(entity)

	entity:ResetSequence(sequence)

	entity:SetPoseParameter("move_x", ply:GetPoseParameter("move_x"))
	entity:SetPoseParameter("move_y", ply:GetPoseParameter("move_y"))

	if bone then
		height = entity:GetBonePosition(bone).z + (offset or 6)
	end

	entity:Remove()

	return height

end

local function UpdateView(ply)

	if cvarStaticEnabled:GetBool() and ply:GetInfoNum("cl_fp_staticheight", 1) == 1 then

		-- Find the height by spawning a dummy entity
		local height = GetViewOffsetValue(ply, "idle_all_01") or 64
		local crouch = GetViewOffsetValue(ply, "cidle_all") or 28

		-- Update player height
		local min = cvarHeightMin:GetInt()
		local max = cvarHeightMax:GetInt()

		ply:SetViewOffset(Vector(0, 0, math.Clamp(height, min, max)))
		ply:SetViewOffsetDucked(Vector(0, 0, math.Clamp(crouch, min, min)))
		ply.fp_ViewChanged = true

	elseif ply.fp_ViewChanged then

		ply:SetViewOffset(Vector(0, 0, 64))
		ply:SetViewOffsetDucked(Vector(0, 0, 28))

		ply.fp_ViewChanged = nil

	end

end

local function ShouldUpdateViewOffset(ply, seq, height)
	local mode = ply:GetInfoNum("cl_fp_dynamicheight", 1)
	if mode == 1 and height ~= ply.fp_height then
		return true
	elseif mode == 2 and height > ply.fp_height then
		return true
	end
	return seq ~= ply.fp_seq
end

local function UpdateViewOffset(ply)

	if not cvarHeightEnabled:GetBool() then return end

	if ply:GetInfoNum("cl_fp_dynamicheight", 1) == 0 then return end

	local seq = ply:GetSequence()

	local bone = ply._fp_headbone or FirstPerson:GetBone(ply)

	local height = 64

	local pos = Vector(0, 0, 0)

	if bone then

		pos = ply:GetBonePosition(bone)

		if pos == ply:GetPos() then
			pos = ply:GetBoneMatrix(bone):GetTranslation()
		end

		pos = pos - ply:GetPos()

		height = math.Round(pos.z + 14, 2)

	end

	if ShouldUpdateViewOffset(ply, seq, height) then

		local min = cvarHeightMin:GetInt()
		local max = cvarHeightMax:GetInt()
		ply:SetCurrentViewOffset(Vector(0, 0, math.Clamp(height, min, max)))

		ply.fp_seq = seq
		ply.fp_height = height

	end

end

local function UpdateTrueModel(ply)
	if ply:GetNWString("FirstPerson:TrueModel") ~= ply:GetModel() then
		ply:SetNWString("FirstPerson:TrueModel", ply:GetModel())
		UpdateView(ply)
	end
end

hook.Add("PlayerSpawn", "FirstPerson:PlayerSpawn", function(ply)
	ply._fp_headbone = nil
	UpdateTrueModel(ply)
end)

hook.Add("PlayerTick", "FirstPerson:PlayerTick", function(ply)
	UpdateTrueModel(ply)
	UpdateViewOffset(ply)
end)

local function ConVarChanged(_, _, _)
	for _, ply in pairs(player.GetAll()) do
		ply._fp_headbone = nil
		UpdateView(ply)
	end
end

cvars.AddChangeCallback("sv_fp_staticheight", ConVarChanged)
cvars.AddChangeCallback("sv_fp_dynamicheight", ConVarChanged)
cvars.AddChangeCallback("sv_fp_dynamicheight_min", ConVarChanged)
cvars.AddChangeCallback("sv_fp_dynamicheight_max", ConVarChanged)