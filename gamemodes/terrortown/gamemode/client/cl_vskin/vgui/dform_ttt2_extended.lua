print("****************** Include dform_ttt2_extended.lua")

---
-- @class PANEL
-- @section DFormTTT2

local PANEL = {}

DEFINE_BASECLASS("DFormTTT2")




derma.DefineControl("DFormTTT2_extended", "", PANEL, "DFormTTT2")

function vgui.CreateTTT2Form_extended(parent, name)
	local form = vgui.Create("DFormTTT2_extended", parent)

	form:SetName(name)
	form:Dock(TOP)

	return form
end