print("Client Side - Debugging Panel")

local materialIcon = Material("vgui/ttt/vskin/helpscreen/debugging")

local function PopulateRolesPanel(parent)
	local form = vgui.CreateTTT2Form(parent, "header_roleselection")

	local roles = roles.GetList()

	for i = 1, #roles do
		local v = roles[i]

		if ConVarExists("ttt_avoid_" .. v.name) then
			local rolename = v.name

			form:MakeCheckBox({
				label = rolename,
				convar = "ttt_avoid_" .. rolename
			})
		end
	end

	form:Dock(TOP)
end


HELPSCRN.populate["ttt2_debugging"] = function(helpData, id)
	local bindingsData = helpData:RegisterSubMenu(id)

	bindingsData:SetTitle("menu_debugging_title")
	bindingsData:SetDescription("menu_debugging_description")
	bindingsData:SetIcon(materialIcon)
end

HELPSCRN.subPopulate["ttt2_debugging"] = function(helpData, id)
	-- roles
	local roleData = helpData:PopulateSubMenu(id .. "_roles")

	roleData:SetTitle("submenu_debugging_roles_title")
	generalData:PopulatePanel(PopulateRolesPanel)
end
