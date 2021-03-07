local materialIcon = Material("vgui/ttt/vskin/helpscreen/debugging")


-- Moved to end of cl_player_manager.lua 
--include("cl_player_manager.lua")
print("Initializing Role Manager")
--local roleManagerF


local roleManager

local function PopulateRolePanel(parent)

    roleManager = roleManager or RoleManager()
    --roleManager:refresh()

    local roleList = roleManager:getRoleList()
    local translatedRoleList = roleManager:getTranslatedRoleList()

    print("translatedRoleList:", unpack(translatedRoleList))

    roleManager:printRevList()

    -----------------------------------------------
    ------------------- PLAYERS -------------------
    -----------------------------------------------
    local playerList = roleManager:getPlayerList()
    --local playerRoles = roleManager:getPlayerRoles()

    local formPlayer = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_player_roles"))
    formPlayer:Dock(TOP)
    local formPlayerList = vgui.CreateTTT2Container_extended(formPlayer)

    for i = 1, #playerList do
        formPlayerList:MakeComboBox({
            label = playerList[i],
            choices = roleList,
            data = roleList,
            selectName = roleManager:getRoleOfPlayer(playerList[i]),
            default = ROLE_RANDOM.name,
            OnChange = function(_, _, value, data)
                print("Selected:", value)
            end
        })
    end

    formPlayer:AddItem(formPlayerList)


    ------------------------------------------------
    --------------------- BOTS ---------------------
    ------------------------------------------------
    local botList = roleManager:getBotList()
    local formBot = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_bot_roles"))
    formBot:Dock(TOP)
    local formBotList = vgui.CreateTTT2Container_extended(formBot)

    local function getBotLists(len)
        local index = roleManager:getBotLen()
        roleManager:changeBotList(len)

        return {unpack(roleManager:getBotList(), index + 1)}
    end

    local function displayBotList(botList)
        for i = 1, #botList do
            print("Bot Name:", botList[i])
            print("Bot Role:", roleManager:getRoleOfBot(botList[i]))

            formBotList:MakeComboBox({
                label = botList[i],
                choices = roleList,
                data = roleList,
                selectName = roleManager:getRoleOfBot(botList[i]),
                default = ROLE_RANDOM.name,
                OnChange = function(_, _, value, data)
                    print("Selected:", value)
                end
            })
        end
    end

    local botSlider = formBot:MakeButtonSlider({
        label = "Spawn Bots",
        min = 0,
        max = game.MaxPlayers() - #playerList,
        decimal = 0,
        initial = roleManager:getBotLen(),
        default = #player.GetBots(),
        OnChange = function(_, value)
            botListChange = getBotLists(value)
            formBotList:ClearAfter(value)
            displayBotList(botListChange)
        end, --TODO: Ganz selten ist mal eine Zahl vertauscht
        OnClick = function(_) end
    })

    formBot:AddItem(formBotList)
    displayBotList(botList)
end


local function PopulateClassPanel(parent)
end

local function PopulateWeaponPanel(parent)
end

HELPSCRN.populate["ttt2_debugging"] = function(helpData, id)
    local bindingsData = helpData:RegisterSubMenu(id)
    bindingsData:SetTitle(LANG.GetTranslation("menu_debugging_title"))
    bindingsData:SetDescription(LANG.GetTranslation("menu_debugging_description"))
    bindingsData:SetIcon(materialIcon)
end

HELPSCRN.subPopulate["ttt2_debugging"] = function(helpData, id)
    -- roles
    local roleData = helpData:PopulateSubMenu(id .. "_roles")
    roleData:SetTitle(LANG.GetTranslation("submenu_debugging_roles_title"))
    roleData:PopulatePanel(PopulateRolePanel)

    -- classes
    local classData = helpData:PopulateSubMenu(id .. "_classes")
    classData:SetTitle(LANG.GetTranslation("submenu_debugging_classes_title"))
    classData:PopulatePanel(PopulateClassPanel)

    -- weapons
    local wepData = helpData:PopulateSubMenu(id .. "_weapons")
    wepData:SetTitle(LANG.GetTranslation("submenu_debugging_weapons_title"))
    wepData:PopulatePanel(PopulateWeaponPanel)
end

hook.Add("TTT2ModifyHelpMainMenu", "Populate Help Main Menu with Debugging Panel", function(helpData)
    HELPSCRN.populate["ttt2_debugging"](helpData, "ttt2_debugging")
end)