local materialIcon = Material("vgui/ttt/vskin/helpscreen/debugging_large")

-- Moved to end of cl_player_manager.lua 

roleManager = nil

local function PopulateRolePanel(parent)

    -- create Role Manager Object if not created yet
    roleManager = roleManager or RoleManager()

    -- request new Role list from Server
    roleManager:requestCurrentRoleList()


    -- gets list with available Role Names and the translated one
    local roleList = roleManager:getRoleList()
    local translatedRoleList = roleManager:getTranslatedRoleList()

    -----------------------------------------------
    ------------------- GENERAL -------------------
    -----------------------------------------------
    --TODO: Übersetzung einfügen
    local formControl = vgui.CreateTTT2Form_extended(parent, "Control")

    local applyButton = formControl:MakeDoubleButton({
        label1 = "Apply Roles",
        OnClick1 = function(_)
            print("Apply Roles")
            roleManager:applyPlayerRoles()
            roleManager:applyBotRoles()
        end,

        label2 = "Apply Roles next round",
        OnClick2 = function(_)
            print("Apply Roles next round")
            roleManager:applyPlayerRolesNextRound()
            roleManager:applyBotRolesNextRound()
        end,
    })

    local updateButton = formControl:MakeDoubleButton({
        label1 = "Update Player Roles",
        OnClick1 = function(_)
            roleManager:setCurrentRoles()
        end,
        OnReset = function(_)
            roleManager:resetPlayerRoles()
            roleManager:resetBotRoles()
        end,
    })

    -----------------------------------------------
    ------------------- PLAYERS -------------------
    -----------------------------------------------

    -- get list with human player Names
    local playerList = roleManager:getPlayerList()

    -- create Panel with List of human players
    local formPlayer = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_player_roles"))
    formPlayer:Dock(TOP)
    local formPlayerList = vgui.CreateTTT2Container_extended(formPlayer)

    -- create ComboBox for every player to select a role from the roleList
    for i = 1, #playerList do
        local combobox = formPlayerList:MakeComboBox_Roles({
            label = playerList[i],
            choices = roleList,
            data = roleList,
            selectName = roleManager:getRoleOfPlayer(playerList[i]),
            default = ROLE_RANDOM.name,
            OnChange = function(_, _, value, data, flag)
                -- TODO: 
                if roleManager.auto_apply == true then
                    roleManager.apply_next_round = true
                    roleManager:applyPlayerRolesNextRound(playerList[i])
                end
                roleManager:setPlayerRole(playerList[i], value)
            end,
            OnUpdate = function(_, _, value, data)
                roleManager:setPlayerRole(playerList[i], value)
            end,
            OnRemove = function()
                --print("Removing hook for", playerList[i] )
                hook.Remove("UpdateRoleSelection_" .. playerList[i], "Update Role Selection " .. playerList[i])
            end,
        })

        hook.Add("UpdateRoleSelection_" .. playerList[i], "Update Role Selection " .. playerList[i], function(customRole)
            local role = customRole or roleManager:getRoleOfPlayer(playerList[i])
            --print("Update role to", role)
            --combobox:ChooseOptionName(role)
            combobox:UpdateOptionName(role)
        end)

    end

    local updateButton = formPlayer:MakeDoubleButton({
        label1 = "Update Player Roles",
        OnClick1 = function(_)
            roleManager:setCurrentPlayerRoles()
        end,
        OnReset = function(_)
            roleManager:resetPlayerRoles()
        end,
    })



    formPlayer:AddItem(formPlayerList)


    ------------------------------------------------
    --------------------- BOTS ---------------------
    ------------------------------------------------

    -- get List with bots on the server
    local botList = roleManager:getBotList()

    -- create Panel with List of bots
    local formBot = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_bot_roles"))
    formBot:Dock(TOP)
    local formBotList = vgui.CreateTTT2Container_extended(formBot)

    -- param:  len - len of the new botList 
    --  updates the length of the bot list
    --  and returns the entries that are visible now, if the length was extended
    -- return: table (new botList) from the position of the (prev index + 1) on 
    local function getAddedBotListsEntries(len)
        local index = roleManager:getBotLen()
        roleManager:changeBotListLen(len)

        return {unpack(roleManager:getBotList(), index + 1)}
    end

    -- param: (table) The Bot entries that need to be added to the already displayed ones.
    --  Displays the given entries in the list in a panel and adds a Combo Selestion for 
    --  each bot to select a role.
    --  The current combobox selection is only extended.
    --  The slider below is used to remove entries from the list.
    local function displayBotList(newBotListEntries)
        for i = 1, #newBotListEntries do
            local combobox = formBotList:MakeComboBox_Roles({
                label = newBotListEntries[i],
                addition = roleManager:getCurrentBotName(newBotListEntries[i]),
                choices = roleList,
                data = roleList,
                selectName = roleManager:getRoleOfBot(newBotListEntries[i]),
                default = ROLE_RANDOM.name,
                OnChange = function(_, _, value, data)
                    if roleManager.auto_apply == true then
                        roleManager.apply_next_round = true
                        roleManager:applyBotRolesNextRound(newBotListEntries[i])
                    end
                    roleManager:setBotRole(newBotListEntries[i], value)
                end,
                OnUpdate = function(_, _, value, data)
                    roleManager:setBotRole(newBotListEntries[i], value)
                end,
                OnRemove = function()
                    --print("Removing hook for", newBotListEntries[i] )
                    hook.Remove("UpdateRoleSelection_" .. newBotListEntries[i], "Update Role Selection " .. newBotListEntries[i])
                end,
            })

            -- TODO: Die Updates funktionieren noch nicht immer zuverlässig!
            hook.Add("UpdateRoleSelection_" .. newBotListEntries[i], "Update Role Selection " .. newBotListEntries[i], function(customRole)
                local role = customRole or roleManager:getRoleOfBot(newBotListEntries[i])
                --print("Update role to", role)
                --combobox:ChooseOptionName(role)
                combobox:UpdateOptionName(role)
            end)

        end
    end

    -- Creates a slider that allows to change the amount of bots displayed in the 
    -- List of Bots above.
    -- Removes all entries above if the values of the slider is reduced.
    --
    -- TODO: Update funktioniert nicht richtig, wenn der apply Button gedrückt wurde.
    -- TODO: Übersetzung einfügen
    -- TODO: Reset Button vom SLider setzt auch Rollen zurück
    local botSlider = formBot:MakeButtonSlider({
        label = "Update Bots",
        min = 0,
        max = game.MaxPlayers() - #playerList,
        decimal = 0,
        initial = roleManager:getBotLen(),
        default = #player.GetBots(),
        OnChange = function(_, value)
            botListChange = getAddedBotListsEntries(value)
            formBotList:ClearAfter(value)
            displayBotList(botListChange)
        end,
        OnClick = function(_)
            roleManager:setCurrentBotRoles()
        end,
        OnReset = function(_)
            roleManager:resetBotRoles()
            --roleManager:setCurrentBotRoles()
        end,
    })

    formBot:AddItem(formBotList)
    displayBotList(botList)

    ------------------------------------------------
    ------------------- Settings -------------------
    ------------------------------------------------

    -- create Panel with List of bots
    local formSettings = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_roles_settings"))
    formSettings:Dock(TOP)

    -- creates some options
    formSettings:MakeHelp({
        label = "debugging_settings_auto_apply_help"
    })

    formSettings:MakeCheckBox({
        label = LANG.GetTranslation("debugging_settings_auto_apply_testing"),
        initial = roleManager.auto_apply,
        default = roleManager.auto_apply,
        OnChange = function(_, value)
            roleManager.auto_apply = value
        end,
    })

    formSettings:MakeHelp({
        label = "debugging_settings_auto_refresh_help"
    })

    formSettings:MakeCheckBox({
        label = LANG.GetTranslation("debugging_settings_auto_refresh"),
        initial = roleManager.auto_refresh,
        default = roleManager.auto_refresh,
        OnChange = function(_, value)
            roleManager.auto_refresh = value
        end,
    })

    -- update List Entries
    roleManager:refresh()
end

local function PopulateClassPanel(parent)
end

local function PopulateWeaponPanel(parent)
end

local function PopulateBotPanel(parent)
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

    -- bots
    local botData = helpData:PopulateSubMenu(id .. "_bots")
    botData:SetTitle(LANG.GetTranslation("submenu_debugging_bots_title"))
    botData:PopulatePanel(PopulateBotPanel)
end

hook.Add("TTT2ModifyHelpMainMenu", "Populate Help Main Menu with Debugging Panel", function(helpData)
    HELPSCRN.populate["ttt2_debugging"](helpData, "ttt2_debugging")
end)