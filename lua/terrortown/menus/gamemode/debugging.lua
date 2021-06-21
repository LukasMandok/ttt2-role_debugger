--- @ignore

CLGAMEMODEMENU.base = "base_gamemodemenu"

CLGAMEMODEMENU.icon = Material("vgui/ttt/vskin/helpscreen/debugging_large")
CLGAMEMODEMENU.title = "menu_debugging_title"
CLGAMEMODEMENU.description = "menu_debugging_description"
CLGAMEMODEMENU.priority = 1

function CLGAMEMODEMENU:IsAdminMenu()
	return false
end

local function addActivationButton(roleData)
    local navPanel, contPanel
    for _,p in pairs(HELPSCRN.menuFrame:GetChildren()) do
        if p:GetName() == "DNavPanelTTT2" then
            navPanel = p

        elseif p:GetName() == "DContentPanelTTT2" then
            contPanel = p
        end
    end

    if navPanel and contPanel and roleData then
        local container = vgui.CreateTTT2Container_extended(navPanel)
        container:SetPaintBackground(false)
        container:Dock(BOTTOM)

        container:MakeCheckBox({
            label    = LANG.GetTranslation("debugging_roles_activate"),
            convar   = "ttt2_rolemanager_activated",
            OnChange = function(_, value)
                if value == false and roleManager then
                    roleManager:close()
                    roleManager = nil
                end
                --HELPSCRN:ShowSubMenu(parent.menuTbl[1])

                HELPSCRN:SetupContentArea(contPanel, roleData)
                HELPSCRN:BuildContentArea()
            end,
        })
        return container
    end

end

local function PopulateActivationButton(roleData)
    if HELPSCRN:GetOpenMenu() == "debugging_roles" and roleData then
        if not activate_Button or not activate_Button:IsValid() then
            activate_Button = addActivationButton(roleData)
        end
    elseif activate_Button and activate_Button:IsValid() then
        activate_Button:Remove()
        activate_Button = nil
    end

end

function CLGAMEMODEMENU:Initialize()
	hook.Add("TTT2OnHelpSubmenuClear", "Populate Activation Button", function (parent, currentMenuId, lastMenuData, submenuClass)
		-- if currentMenuId ~= "debugging" then return end 

		PopulateActivationButton(submenuClass)
	end)
end