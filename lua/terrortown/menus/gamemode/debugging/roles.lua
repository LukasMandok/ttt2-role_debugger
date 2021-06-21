CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"

CLGAMEMODESUBMENU.priority = 100
CLGAMEMODESUBMENU.title = "submenu_debugging_roles_title"

local function PopulateRolePanel(parent)

    -- create Role Manager Object if not created yet
    roleManager = roleManager or RoleManager()

    -- request new Role list from Server
    roleManager:requestCurrentRoleList()


    -- functions to cycle through comboboxes
    local playerComboboxes = {}
    local botComboboxes = {}
    local playerLock = nil
    local botLock = nil

    local function setPlayerComboboxesLocked(bool)
        roleManager.player_roles_locked = bool
        for i,entry in pairs(playerComboboxes) do
            entry["lock"]:setLocked(bool)
        end
    end


    local function setBotComboboxesLocked(bool)
        roleManager.bot_roles_locked = bool
        for i,entry in pairs(botComboboxes) do
            entry["lock"]:setLocked(bool)
        end
    end


    local function setAllComboboxesLocked(bool)
        roleManager.all_roles_locked = bool
        playerLock:setLocked(bool)
        botLock:setLocked(bool)

        --setPlayerComboboxesLocked(bool)
        --setBotComboboxesLocked(bool)
    end


    -- gets list with available Role Names and the translated one
    local roleList = roleManager:getRoleList()

    -----------------------------------------------
    ------------------- GENERAL -------------------
    -----------------------------------------------
    local formControl = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_roles_control"))

    local applyButton = formControl:MakeDoubleButton({
        label1 = LANG.GetTranslation("debugging_roles_control_apply"),
        OnClick1 = function(_)
            --print("Apply Roles")
            roleManager:clearRolesNextRound()
            roleManager:applyPlayerRoles()
            roleManager:applyBotRoles()
        end,
        label2 = LANG.GetTranslation("debugging_roles_control_apply_nr"),
        OnClick2 = function(_)
            --print("Apply Roles next round")
            roleManager:applyPlayerRolesNextRound()
            roleManager:applyBotRolesNextRound()
        end,
        OnReset = function(_)
            roleManager:resetPlayerRoles()
            roleManager:resetBotRoles()
        end,
        locked = roleManager.all_roles_locked,
        OnLocked =  function(slf)
            setAllComboboxesLocked(true)
        end,
        OnUnlocked =  function(slf)
            setAllComboboxesLocked(false)
        end,
    })

    local updateButton = formControl:MakeDoubleButton({
        label1 = LANG.GetTranslation("debugging_roles_control_refresh"),
        OnClick1 = function(_)
            roleManager:setCurrentRoles()
        end,
        label2 = LANG.GetTranslation("debugging_roles_control_restart"),
        OnClick2 = function(_)
            --print("Restart Round")
            roleManager.startNextRound()
        end,
    })

    -----------------------------------------------
    ------------------- PLAYERS -------------------
    -----------------------------------------------

    -- get list with human player Names
    local playerList = roleManager:getPlayerList()

    -- create Panel with List of human players
    local formPlayer = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_roles_player"))
    formPlayer:Dock(TOP)
    local formPlayerList = vgui.CreateTTT2Container_extended(formPlayer)

    -- create ComboBox for every player to select a role from the roleList
    for i = 1, #playerList do
        local combobox, lock = formPlayerList:MakeComboBox_Roles({
            label = playerList[i],
            choices = roleList,
            data = roleManager:getRoleCategories(),
            selectName = roleManager:getRoleOfPlayer(playerList[i]),
            default = RD_ROLE_RANDOM.name,
            locked = roleManager:getPlayerLocked(playerList[i]),
            OnChange = function(_, _, value, data, flag)
                roleManager:setPlayerRole(playerList[i], value)

                if roleManager.auto_apply:GetBool() == true then
                    roleManager.apply_next_round = true
                    roleManager:applyPlayerRolesNextRound(playerList[i])
                end
            end,
            OnUpdate = function(_, _, value, data)
                roleManager:setPlayerRole(playerList[i], value)
            end,
            OnLocked =  function(slf)
                roleManager:setPlayerLocked(playerList[i], true)
            end,
            OnUnlocked =  function(slf)
                roleManager:setPlayerLocked(playerList[i], false)
            end,
            OnRemove = function()
                --roleManager:setPlayerLocked(playerList[i], false)
                --print("Removing hook for", playerList[i] )
                hook.Remove("UpdateRoleSelection_" .. playerList[i], "Update Role Selection " .. playerList[i])
            end,
        })

        -- Fill up List with comboboxes
        playerComboboxes[playerList[i]] = {["combo"] = combobox, ["lock"] = lock}

        hook.Add("UpdateRoleSelection_" .. playerList[i], "Update Role Selection " .. playerList[i], function(customRole)
            local role = customRole or roleManager:getRoleOfPlayer(playerList[i])
            combobox:UpdateOptionName(role)
        end)

    end

    local updateButton, _, lock = formPlayer:MakeDoubleButton({
        label1 = LANG.GetTranslation("debugging_roles_player_refresh"),
        OnClick1 = function(_)
            roleManager:setCurrentPlayerRoles()
        end,
        OnReset = function(_)
            roleManager:resetPlayerRoles()
        end,
        locked = roleManager.player_roles_locked,
        OnLocked =  function(slf)
            setPlayerComboboxesLocked(true)
        end,
        OnUnlocked =  function(slf)
            setPlayerComboboxesLocked(false)
        end,
    })

    playerLock = lock

    formPlayer:AddItem(formPlayerList)


    ------------------------------------------------
    --------------------- BOTS ---------------------
    ------------------------------------------------

    -- get List with bots on the server
    local botList = roleManager:getBotList()

    -- create Panel with List of bots
    local formBot = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_roles_bot"))
    formBot:Dock(TOP)
    local formBotList = vgui.CreateTTT2Container_extended(formBot)

    -- param:  len - len of the new botList 
    --  updates the length of the bot list
    --  and returns the entries that are visible now, if the length was extended
    -- return: table (new botList) from the position of the (prev index + 1) on 
    local function getAddedBotListsEntries(len)
        local index = roleManager:getBotLen()
        roleManager:changeBotListLen(len)

        -- TODO: 
        --print("index:", index)
        --print("whole list:", unpack(roleManager:getBotList()))
        --print("return:", unpack( {unpack(roleManager:getBotList(), index + 1)}))

        return {unpack(roleManager:getBotList(), index + 1)}
    end

    -- param: (table) The Bot entries that need to be added to the already displayed ones.
    --  Displays the given entries in the list in a panel and adds a Combo Selestion for 
    --  each bot to select a role.
    --  The current combobox selection is only extended.
    --  The slider below is used to remove entries from the list.
    local function displayBotList(newBotListEntries)
        for i = 1, #newBotListEntries do
            local combobox, lock = formBotList:MakeComboBox_Roles({
                label = newBotListEntries[i],
                addition = roleManager:getCurrentBotName(newBotListEntries[i]),
                choices = roleList,
                data = roleManager:getRoleCategories(),
                selectName = roleManager:getRoleOfBot(newBotListEntries[i]),
                default = RD_ROLE_RANDOM.name,
                locked = roleManager:getBotLocked(newBotListEntries[i]),
                OnChange = function(_, _, value, data)
                    roleManager:setBotRole(newBotListEntries[i], value)
                    if roleManager.auto_apply:GetBool() == true then
                        roleManager.apply_next_round = true
                        roleManager:applyBotRolesNextRound(newBotListEntries[i])
                    end
                end,
                OnUpdate = function(_, _, value, data)
                    roleManager:setBotRole(newBotListEntries[i], value)
                end,
                OnLocked =  function(slf)
                    roleManager:setBotLocked(newBotListEntries[i], true)
                end,
                OnUnlocked =  function(slf)
                    roleManager:setBotLocked(newBotListEntries[i], false)
                end,
                OnRemove = function()
                    --roleManager:setBotLocked(newBotListEntries[i], false)
                    botComboboxes[newBotListEntries[i]] = nil
                    --print("Removing hook for", newBotListEntries[i] )
                    hook.Remove("UpdateRoleSelection_" .. newBotListEntries[i], "Update Role Selection " .. newBotListEntries[i])
                end,
            })

            botComboboxes[newBotListEntries[i]] = {["combo"] = combobox, ["lock"] = lock}

            hook.Add("UpdateRoleSelection_" .. newBotListEntries[i], "Update Role Selection " .. newBotListEntries[i], function(customRole)
                local role = customRole or roleManager:getRoleOfBot(newBotListEntries[i])
                combobox:UpdateOptionName(role)
            end)

        end
    end

    -- Creates a slider that allows to change the amount of bots displayed in the 
    -- List of Bots above.
    -- Removes all entries above if the values of the slider is reduced.
    local botSlider, lock = formBot:MakeButtonSlider({
        label = LANG.GetTranslation("debugging_roles_bot_refresh"),
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
        locked = roleManager.bot_roles_locked,
        OnLocked =  function(slf)
            setBotComboboxesLocked(true)
        end,
        OnUnlocked =  function(slf)
            setBotComboboxesLocked(false)
        end,
    })

    botLock = lock

    formBot:AddItem(formBotList)
    displayBotList(botList)

    ------------------------------------------------
    ------------------- Settings -------------------
    ------------------------------------------------

    -- create Panel with List of bots
    local formSettings = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_roles_settings"), false)
    formSettings:Dock(TOP)

    -- creates some options
    formSettings:MakeHelp({
        label = "debugging_roles_settings_auto_apply_help"
    })

    -- formSettings:MakeCheckBox({
    --     label = LANG.GetTranslation("debugging_roles_settings_auto_apply"),
    --     initial = roleManager.auto_apply:GetBool(),
    --     default = roleManager.auto_apply:GetBool(),
    --     OnChange = function(_, value)
    --         roleManager.auto_apply = value
    --     end,
    -- })

    formSettings:MakeCheckBox({
        label = LANG.GetTranslation("debugging_roles_settings_auto_apply"),
        convar = "ttt_rolemanager_auto_apply", --roleManager.auto_apply,
    })

    formSettings:MakeHelp({
        label = "debugging_roles_settings_auto_refresh_help"
    })

    -- formSettings:MakeCheckBox({
    --     label = LANG.GetTranslation("debugging_roles_settings_auto_refresh"),
    --     initial = roleManager.auto_refresh,
    --     default = roleManager.auto_refresh,
    --     OnChange = function(_, value)
    --         roleManager.auto_refresh = value
    --     end,
    -- })

    formSettings:MakeCheckBox({
        label = LANG.GetTranslation("debugging_roles_settings_auto_refresh"),
        convar = "ttt_rolemanager_auto_refresh", --roleManager.auto_refresh,
    })

    formSettings:MakeHelp({
        label = "debugging_roles_settings_overhead_icon_help"
    })

    -- formSettings:MakeCheckBox({
    --     label = LANG.GetTranslation("debugging_roles_settings_overhead_icon_help")
    --     initial = roleManager.overhead_role_icons,
    --     default = roleManager.overhead_role_icons,
    --     OnChange = function(_, value)
    --         roleManager.overhead_role_icons = value
    --     end,
    -- })

    formSettings:MakeCheckBox({
        label = LANG.GetTranslation("debugging_roles_settings_overhead_icon_help"),
        convar = "ttt_rolemanager_overhead_icons", --roleManager.overhead_role_icons,
    })

    -- update List Entries
    roleManager:refresh()
end


local activated = CreateConVar( "ttt2_rolemanager_activated", 1, FCVAR_ARCHIVE, "Activates the RoleManager", 0, 1 )

function CLGAMEMODESUBMENU:Populate(parent)

    if activated:GetBool() == false then return end

    PopulateRolePanel(parent)

end
