print("Client Side - Debugging Panel")
local materialIcon = Material("vgui/ttt/vskin/helpscreen/debugging.png")

local function PopulateRolesPanel(parent)
    local form1 = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_player_roles"))
    local form2 = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_bot_roles"))
    local playerList = {}
    local botList = {}

    -- create Liste with all installed Roles + A Random Role Entry
    local roleNames = {
        [1] = LANG.GetTranslation("submenu_debugging_random_role")
    }

    local roles = roles.GetList()

    for i = 1, #roles do
        roleNames[i + 1] = roles[i].name
    end

    --roleNames = table.Merge(roleNames, roles)
    print("Valide Rollen:", tostring(validRoles))
    -- Put active Players on the Map in List for real players and bots
    local players = player.GetAll()

    for i = 1, #players do
        local nick = players[i]:Nick()

        if (nick.sub(nick, 1, 3) == "bot") then
            -- add Player to bot list
            botList[#botlist + 1] = players[i]
        else
            -- add Player to player list
            playerList[#playerList + 1] = players[i]
        end
    end

    for _, p in pairs(playerList) do
        form1:MakeComboBox({
            label = p:Nick(),
            choices = roleNames,
            selectName = LANG.GetTranslation("submenu_debugging_random_role"),
            OnChange = function(_, _, value)
                print("Selected:", value)
            end
        })
    end

    --for i = 1, #roles do
    --    local v = roles[i]
    --    if ConVarExists("ttt_avoid_" .. v.name) then
    --        local rolename = v.name
    --        form1:MakeCheckBox({
    --            label = rolename,
    --            convar = "ttt_avoid_" .. rolename
    --        })
    --    end
    --end
    form1:Dock(TOP)
end

HELPSCRN.populate["ttt2_debugging"] = function(helpData, id)
    print("------------------- populate ttt2_debugging")
    print(tostring(helpData))
    local bindingsData = helpData:RegisterSubMenu(id)
    bindingsData:SetTitle(LANG.GetTranslation("menu_debugging_title"))
    bindingsData:SetDescription(LANG.GetTranslation("menu_debugging_description"))
    bindingsData:SetIcon(materialIcon)
end

HELPSCRN.subPopulate["ttt2_debugging"] = function(helpData, id)
    -- roles
    print("------------------- populate ttt2_debugging_role")
    local roleData = helpData:PopulateSubMenu(id .. "_roles")
    roleData:SetTitle(LANG.GetTranslation("submenu_debugging_roles_title"))
    roleData:PopulatePanel(PopulateRolesPanel)
end

hook.Add("TTT2ModifyHelpMainMenu", "Populate Help Main Menu with Debugging Panel", function(helpData)
    HELPSCRN.populate["ttt2_debugging"](helpData, "ttt2_debugging")
end)