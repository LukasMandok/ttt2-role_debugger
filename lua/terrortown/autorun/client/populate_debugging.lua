-- local materialIcon = Material("vgui/ttt/vskin/helpscreen/debugging_large")

-- -- Moved to end of cl_player_manager.lua 
-- local activated = CreateConVar( "ttt_rolemanager_activated", 1, FCVAR_ARCHIVE, "Activates the RoleManager", 0, 1 )
-- roleManager = nil

-- local function PopulateRolePanel(parent)

--     --if activated == false then return end

--     if activated:GetBool() == false then return end

--     -- create Role Manager Object if not created yet
--     roleManager = roleManager or RoleManager()

--     -- request new Role list from Server
--     roleManager:requestCurrentRoleList()


--     -- functions to cycle through comboboxes
--     local playerComboboxes = {}
--     local botComboboxes = {}
--     local playerLock = nil
--     local botLock = nil

--     local function setPlayerComboboxesLocked(bool)
--         roleManager.player_roles_locked = bool
--         for i,entry in pairs(playerComboboxes) do
--             entry["lock"]:setLocked(bool)
--         end
--     end


--     local function setBotComboboxesLocked(bool)
--         roleManager.bot_roles_locked = bool
--         for i,entry in pairs(botComboboxes) do
--             entry["lock"]:setLocked(bool)
--         end
--     end


--     local function setAllComboboxesLocked(bool)
--         roleManager.all_roles_locked = bool
--         playerLock:setLocked(bool)
--         botLock:setLocked(bool)

--         --setPlayerComboboxesLocked(bool)
--         --setBotComboboxesLocked(bool)
--     end


--     -- gets list with available Role Names and the translated one
--     local roleList = roleManager:getRoleList()

--     -----------------------------------------------
--     ------------------- GENERAL -------------------
--     -----------------------------------------------
--     local formControl = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_roles_control"))

--     local applyButton = formControl:MakeDoubleButton({
--         label1 = LANG.GetTranslation("debugging_roles_control_apply"),
--         OnClick1 = function(_)
--             --print("Apply Roles")
--             roleManager:clearRolesNextRound()
--             roleManager:applyPlayerRoles()
--             roleManager:applyBotRoles()
--         end,
--         label2 = LANG.GetTranslation("debugging_roles_control_apply_nr"),
--         OnClick2 = function(_)
--             --print("Apply Roles next round")
--             roleManager:applyPlayerRolesNextRound()
--             roleManager:applyBotRolesNextRound()
--         end,
--         OnReset = function(_)
--             roleManager:resetPlayerRoles()
--             roleManager:resetBotRoles()
--         end,
--         locked = roleManager.all_roles_locked,
--         OnLocked =  function(slf)
--             setAllComboboxesLocked(true)
--         end,
--         OnUnlocked =  function(slf)
--             setAllComboboxesLocked(false)
--         end,
--     })

--     local updateButton = formControl:MakeDoubleButton({
--         label1 = LANG.GetTranslation("debugging_roles_control_refresh"),
--         OnClick1 = function(_)
--             roleManager:setCurrentRoles()
--         end,
--         label2 = LANG.GetTranslation("debugging_roles_control_restart"),
--         OnClick2 = function(_)
--             --print("Restart Round")
--             roleManager.startNextRound()
--         end,
--     })

--     -----------------------------------------------
--     ------------------- PLAYERS -------------------
--     -----------------------------------------------

--     -- get list with human player Names
--     local playerList = roleManager:getPlayerList()

--     -- create Panel with List of human players
--     local formPlayer = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_roles_player"))
--     formPlayer:Dock(TOP)
--     local formPlayerList = vgui.CreateTTT2Container_extended(formPlayer)

--     -- create ComboBox for every player to select a role from the roleList
--     for i = 1, #playerList do
--         local combobox, lock = formPlayerList:MakeComboBox_Roles({
--             label = playerList[i],
--             choices = roleList,
--             data = roleManager:getRoleCategories(),
--             selectName = roleManager:getRoleOfPlayer(playerList[i]),
--             default = RD_ROLE_RANDOM.name,
--             locked = roleManager:getPlayerLocked(playerList[i]),
--             OnChange = function(_, _, value, data, flag)
--                 roleManager:setPlayerRole(playerList[i], value)

--                 if roleManager.auto_apply:GetBool() == true then
--                     roleManager.apply_next_round = true
--                     roleManager:applyPlayerRolesNextRound(playerList[i])
--                 end
--             end,
--             OnUpdate = function(_, _, value, data)
--                 roleManager:setPlayerRole(playerList[i], value)
--             end,
--             OnLocked =  function(slf)
--                 roleManager:setPlayerLocked(playerList[i], true)
--             end,
--             OnUnlocked =  function(slf)
--                 roleManager:setPlayerLocked(playerList[i], false)
--             end,
--             OnRemove = function()
--                 --roleManager:setPlayerLocked(playerList[i], false)
--                 --print("Removing hook for", playerList[i] )
--                 hook.Remove("UpdateRoleSelection_" .. playerList[i], "Update Role Selection " .. playerList[i])
--             end,
--         })

--         -- Fill up List with comboboxes
--         playerComboboxes[playerList[i]] = {["combo"] = combobox, ["lock"] = lock}

--         hook.Add("UpdateRoleSelection_" .. playerList[i], "Update Role Selection " .. playerList[i], function(customRole)
--             local role = customRole or roleManager:getRoleOfPlayer(playerList[i])
--             combobox:UpdateOptionName(role)
--         end)

--     end

--     local updateButton, _, lock = formPlayer:MakeDoubleButton({
--         label1 = LANG.GetTranslation("debugging_roles_player_refresh"),
--         OnClick1 = function(_)
--             roleManager:setCurrentPlayerRoles()
--         end,
--         OnReset = function(_)
--             roleManager:resetPlayerRoles()
--         end,
--         locked = roleManager.player_roles_locked,
--         OnLocked =  function(slf)
--             setPlayerComboboxesLocked(true)
--         end,
--         OnUnlocked =  function(slf)
--             setPlayerComboboxesLocked(false)
--         end,
--     })

--     playerLock = lock

--     formPlayer:AddItem(formPlayerList)


--     ------------------------------------------------
--     --------------------- BOTS ---------------------
--     ------------------------------------------------

--     -- get List with bots on the server
--     local botList = roleManager:getBotList()

--     -- create Panel with List of bots
--     local formBot = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_roles_bot"))
--     formBot:Dock(TOP)
--     local formBotList = vgui.CreateTTT2Container_extended(formBot)

--     -- param:  len - len of the new botList 
--     --  updates the length of the bot list
--     --  and returns the entries that are visible now, if the length was extended
--     -- return: table (new botList) from the position of the (prev index + 1) on 
--     local function getAddedBotListsEntries(len)
--         local index = roleManager:getBotLen()
--         roleManager:changeBotListLen(len)

--         -- TODO: 
--         --print("index:", index)
--         --print("whole list:", unpack(roleManager:getBotList()))
--         --print("return:", unpack( {unpack(roleManager:getBotList(), index + 1)}))

--         return {unpack(roleManager:getBotList(), index + 1)}
--     end

--     -- param: (table) The Bot entries that need to be added to the already displayed ones.
--     --  Displays the given entries in the list in a panel and adds a Combo Selestion for 
--     --  each bot to select a role.
--     --  The current combobox selection is only extended.
--     --  The slider below is used to remove entries from the list.
--     local function displayBotList(newBotListEntries)
--         for i = 1, #newBotListEntries do
--             local combobox, lock = formBotList:MakeComboBox_Roles({
--                 label = newBotListEntries[i],
--                 addition = roleManager:getCurrentBotName(newBotListEntries[i]),
--                 choices = roleList,
--                 data = roleManager:getRoleCategories(),
--                 selectName = roleManager:getRoleOfBot(newBotListEntries[i]),
--                 default = RD_ROLE_RANDOM.name,
--                 locked = roleManager:getBotLocked(newBotListEntries[i]),
--                 OnChange = function(_, _, value, data)
--                     roleManager:setBotRole(newBotListEntries[i], value)
--                     if roleManager.auto_apply:GetBool() == true then
--                         roleManager.apply_next_round = true
--                         roleManager:applyBotRolesNextRound(newBotListEntries[i])
--                     end
--                 end,
--                 OnUpdate = function(_, _, value, data)
--                     roleManager:setBotRole(newBotListEntries[i], value)
--                 end,
--                 OnLocked =  function(slf)
--                     roleManager:setBotLocked(newBotListEntries[i], true)
--                 end,
--                 OnUnlocked =  function(slf)
--                     roleManager:setBotLocked(newBotListEntries[i], false)
--                 end,
--                 OnRemove = function()
--                     --roleManager:setBotLocked(newBotListEntries[i], false)
--                     botComboboxes[newBotListEntries[i]] = nil
--                     --print("Removing hook for", newBotListEntries[i] )
--                     hook.Remove("UpdateRoleSelection_" .. newBotListEntries[i], "Update Role Selection " .. newBotListEntries[i])
--                 end,
--             })

--             botComboboxes[newBotListEntries[i]] = {["combo"] = combobox, ["lock"] = lock}

--             hook.Add("UpdateRoleSelection_" .. newBotListEntries[i], "Update Role Selection " .. newBotListEntries[i], function(customRole)
--                 local role = customRole or roleManager:getRoleOfBot(newBotListEntries[i])
--                 combobox:UpdateOptionName(role)
--             end)

--         end
--     end

--     -- Creates a slider that allows to change the amount of bots displayed in the 
--     -- List of Bots above.
--     -- Removes all entries above if the values of the slider is reduced.
--     local botSlider, lock = formBot:MakeButtonSlider({
--         label = LANG.GetTranslation("debugging_roles_bot_refresh"),
--         min = 0,
--         max = game.MaxPlayers() - #playerList,
--         decimal = 0,
--         initial = roleManager:getBotLen(),
--         default = #player.GetBots(),
--         OnChange = function(_, value)
--             botListChange = getAddedBotListsEntries(value)
--             formBotList:ClearAfter(value)
--             displayBotList(botListChange)
--         end,
--         OnClick = function(_)
--             roleManager:setCurrentBotRoles()
--         end,
--         OnReset = function(_)
--             roleManager:resetBotRoles()
--             --roleManager:setCurrentBotRoles()
--         end,
--         locked = roleManager.bot_roles_locked,
--         OnLocked =  function(slf)
--             setBotComboboxesLocked(true)
--         end,
--         OnUnlocked =  function(slf)
--             setBotComboboxesLocked(false)
--         end,
--     })

--     botLock = lock

--     formBot:AddItem(formBotList)
--     displayBotList(botList)

--     ------------------------------------------------
--     ------------------- Settings -------------------
--     ------------------------------------------------

--     -- create Panel with List of bots
--     local formSettings = vgui.CreateTTT2Form_extended(parent, LANG.GetTranslation("header_debugging_roles_settings"), false)
--     formSettings:Dock(TOP)

--     -- creates some options
--     formSettings:MakeHelp({
--         label = "debugging_roles_settings_auto_apply_help"
--     })

--     -- formSettings:MakeCheckBox({
--     --     label = LANG.GetTranslation("debugging_roles_settings_auto_apply"),
--     --     initial = roleManager.auto_apply:GetBool(),
--     --     default = roleManager.auto_apply:GetBool(),
--     --     OnChange = function(_, value)
--     --         roleManager.auto_apply = value
--     --     end,
--     -- })

--     formSettings:MakeCheckBox({
--         label = LANG.GetTranslation("debugging_roles_settings_auto_apply"),
--         convar = "ttt_rolemanager_auto_apply", --roleManager.auto_apply,
--     })

--     formSettings:MakeHelp({
--         label = "debugging_roles_settings_auto_refresh_help"
--     })

--     -- formSettings:MakeCheckBox({
--     --     label = LANG.GetTranslation("debugging_roles_settings_auto_refresh"),
--     --     initial = roleManager.auto_refresh,
--     --     default = roleManager.auto_refresh,
--     --     OnChange = function(_, value)
--     --         roleManager.auto_refresh = value
--     --     end,
--     -- })

--     formSettings:MakeCheckBox({
--         label = LANG.GetTranslation("debugging_roles_settings_auto_refresh"),
--         convar = "ttt_rolemanager_auto_refresh", --roleManager.auto_refresh,
--     })

--     formSettings:MakeHelp({
--         label = "debugging_roles_settings_overhead_icon_help"
--     })

--     -- formSettings:MakeCheckBox({
--     --     label = LANG.GetTranslation("debugging_roles_settings_overhead_icon_help")
--     --     initial = roleManager.overhead_role_icons,
--     --     default = roleManager.overhead_role_icons,
--     --     OnChange = function(_, value)
--     --         roleManager.overhead_role_icons = value
--     --     end,
--     -- })

--     formSettings:MakeCheckBox({
--         label = LANG.GetTranslation("debugging_roles_settings_overhead_icon_help"),
--         convar = "ttt_rolemanager_overhead_icons", --roleManager.overhead_role_icons,
--     })

--     -- update List Entries
--     roleManager:refresh()
-- end

-- -- local function PopulateClassPanel(parent)
-- -- end

-- -- local function PopulateWeaponPanel(parent)
-- -- end

-- -- local function PopulateBotPanel(parent)
-- --    	local form = vgui.CreateTTT2Form(parent, LANG.GetTranslation("header_debugging_bots_settings"))

-- --     form:MakeCheckBox({
-- --         label = LANG.GetTranslation("debugging_bots_settings_moving"),
-- --         initial = roleManager.moving_bots,
-- --         default = roleManager.moving_bots,
-- --         OnChange = function(_, value)
-- --             roleManager.moving_bots = moving_bots
-- --             net.Start("RoleManagerSetBoolConvar")
-- --                 net.WriteString("bot_zombie")
-- --                 net.WriteBool(value)
-- --             net.SendToServer()
-- --         end,
-- --     })

-- -- end

-- local function PopulateControlPanel(parent)

--     local playerList = player.GetAll()

--     local playerListNames = {}
--     local index_remove = nil
--     for i = 1, #playerList do
--         playerListNames[i] = playerList[i]:Nick()
--         if playerListNames[i] == LocalPlayer():Nick() then
--             index_remove = i
--         end
--     end
--     if index_remove then
--         table.remove(playerListNames, index_remove)
--         table.remove(playerList, index_remove)
--     end

--     local formPlayer = vgui.CreateTTT2Form_extended(parent, "Control Players")
--     formPlayer:Dock(TOP)

--     local target_ply = playerList[1]
--     local view_flag  = PC_CAM_SIMPLEFIRSTPERSON
--     local net_flag   = PC_SERVERSIDE

--     formPlayer:MakeComboBox({
--         label = LANG.GetTranslation("header_debugging_controller_player"),
--         choices = playerListNames,
--         data = playerList,
--         selectName = playerListNames[1],
--         default = playerListNames[1],
--         OnChange = function(_, _, value, data)
--             target_ply = data
--         end,
--     })

--     local sfp_check, fp_check, tp_check, r_check

--     sfp_check = formPlayer:MakeCheckBox({
--         label = LANG.GetTranslation("debugging_controller_simple_firstperson"),
--         initial = true,
--         default = true,
--         OnChange = function(_, value)
--             if value == true then
--                 view_flag = PC_CAM_SIMPLEFIRSTPERSON
--                 fp_check:SetValue(false)
--                 tp_check:SetValue(false)
--                 r_check:SetValue(false)
--             end
--         end,
--     })

--     fp_check = formPlayer:MakeCheckBox({
--         label = LANG.GetTranslation("debugging_controller_firstperson") .. " (not implented yet)",
--         initial = false,
--         default = false,
--         disabled = true,
--         OnChange = function(_, value)
--             if value == true then
--                 view_flag = PC_CAM_FIRSTPERSON
--                 sfp_check:SetValue(false)
--                 tp_check:SetValue(false)
--                 r_check:SetValue(false)
--             end
--         end,
--     })

--     tp_check = formPlayer:MakeCheckBox({
--         label = LANG.GetTranslation("debugging_controller_thirdperson"),
--         initial = false,
--         default = false,
--         OnChange = function(_, value)
--             if value == true then
--                 view_flag = PC_CAM_THIRDPERSON
--                 sfp_check:SetValue(false)
--                 fp_check:SetValue(false)
--                 r_check:SetValue(false)
--             end
--         end,
--     })

--     r_check = formPlayer:MakeCheckBox({
--         label = LANG.GetTranslation("debugging_controller_roaming") .. " (not implented yet)",
--         initial = false,
--         default = false,
--         disabled = true,
--         OnChange = function(_, value)
--             if value == true then
--                 view_flag = PC_CAM_ROAMING
--                 sfp_check:SetValue(false)
--                 fp_check:SetValue(false)
--                 tp_check:SetValue(false)
--             end
--         end,
--     })

--     net_check = formPlayer:MakeCheckBox({
--         label = LANG.GetTranslation("debugging_controller_net_mode"),
--         initial = false,
--         default = false,
--         OnChange = function(_, value)
--             if value == false then
--                 net_flag = PC_SERVERSIDE
--             else
--                 net_flag = PC_CLIENTSIDE
--             end
--         end,
--     })


--     local controlButton = formPlayer:MakeDoubleButton({
--         label1 = LANG.GetTranslation("debugging_controller_start"),
--         OnClick1 = function(_)
--             print("Start Control of Player:", target_ply:Nick())
--             net.Start("PlayerController:NetControl")
--                 net.WriteUInt( PC_CL_START, 3)
--                 net.WriteEntity(target_ply)
--                 net.WriteUInt(view_flag, 2)
--                 net.WriteUInt(net_flag, 1)
--             net.SendToServer()
--         end,
--         label2 = LANG.GetTranslation("debugging_controller_end"),
--         OnClick2 = function(_)
--             print("End Control")
--             net.Start("PlayerController:NetControl")
--                 net.WriteUInt( PC_CL_END, 3)
--             net.SendToServer()
--         end,
--     })

--     local controlButton_debug = formPlayer:MakeDoubleButton({
--         label1 = "(Debugging!) Bot1 Control LocalPlayer",
--         OnClick1 = function(_)
--             print("Start Control of Player:", target_ply:Nick())
--             net.Start("PlayerController:NetControlTest")
--                 net.WriteUInt(view_flag, 2)
--                 net.WriteUInt(net_flag, 1)
--             net.SendToServer()
--         end
--     })


-- end

-- local function addActivationButton(parent, roleData)
--     local navPanel, contPanel
--     for _,p in pairs(HELPSCRN.menuFrame:GetChildren()) do
--         --print("name:", p:GetName())
--         if p:GetName() == "DNavPanelTTT2" then
--             navPanel = p

--         elseif p:GetName() == "DContentPanelTTT2" then
--             contPanel = p
--         end
--     end

--     if navPanel and contPanel and roleData then
--         local container = vgui.CreateTTT2Container_extended(navPanel)
--         container:SetPaintBackground(false)
--         container:Dock(BOTTOM)

--         container:MakeCheckBox({
--             label    = LANG.GetTranslation("debugging_roles_activate"),
--             convar   = "ttt_rolemanager_activated",
--             OnChange = function(_, value)
--                 if value == false and roleManager then
--                     roleManager:close()
--                     roleManager = nil
--                 end
--                 --HELPSCRN:ShowSubMenu(parent.menuTbl[1])

--                 HELPSCRN:SetupContentArea(contPanel, roleData)
--                 HELPSCRN:BuildContentArea()
--             end,
--         })
--         return container
--     end

-- end

-- HELPSCRN.populate["ttt2_debugging"] = function(helpData, id)
--     local debuggingData = helpData:RegisterSubMenu(id)
--     debuggingData:SetTitle(LANG.GetTranslation("menu_debugging_title"))
--     debuggingData:SetDescription(LANG.GetTranslation("menu_debugging_description"))
--     debuggingData:SetIcon(materialIcon)
-- end

-- HELPSCRN.subPopulate["ttt2_debugging"] = function(helpData, id)
--     -- roles
--     local roleData = helpData:PopulateSubMenu(id .. "_roles")
--     roleData:SetTitle(LANG.GetTranslation("submenu_debugging_roles_title"))
--     roleData:PopulatePanel(PopulateRolePanel)

--     -- classes
--     -- local classData = helpData:PopulateSubMenu(id .. "_classes")
--     -- classData:SetTitle(LANG.GetTranslation("submenu_debugging_classes_title"))
--     -- classData:PopulatePanel(PopulateClassPanel)

--     -- -- weapons
--     -- local wepData = helpData:PopulateSubMenu(id .. "_weapons")
--     -- wepData:SetTitle(LANG.GetTranslation("submenu_debugging_weapons_title"))
--     -- wepData:PopulatePanel(PopulateWeaponPanel)

--     -- bots
--     -- local botData = helpData:PopulateSubMenu(id .. "_bots")
--     -- botData:SetTitle(LANG.GetTranslation("submenu_debugging_bots_title"))
--     -- botData:PopulatePanel(PopulateBotPanel)

--     -- control
--     if PlayerController ~= nil then
--         local controlData = helpData:PopulateSubMenu(id .. "_control")
--         controlData:SetTitle(LANG.GetTranslation("submenu_debugging_controller_title"))
--         controlData:PopulatePanel(PopulateControlPanel)
--     end

--     local activate_Button
--     hook.Add("TTT2OnHelpSubMenuClear", "Popupate Aktivation Button for Roles", function(parent, currentMenuId, lastMenuData, menuData)
--         --print("Calling TTT2OnHelpSubMenuClear", HELPSCRN:GetOpenMenu(), activate_Button)

--         --timer.Simple(0.1, function ()
--         -- print(lastMenuData, currentMenuId)
--         -- print("not lastMenuData:", not lastMenuData)
--         -- if lastMenuData then
--         --     --PrintTable(lastMenuData)
--         --     print(not lastMenuData, currentMenuId, lastMenuData.id)
--         -- end
--         if HELPSCRN:GetOpenMenu() == "ttt2_debugging_roles" then
--             if not activate_Button then
--                 --print("Add Activated Button")
--                 activate_Button = addActivationButton(helpData, roleData)
--             end
--         elseif activate_Button then
--             --print("Remove Activate Button")
--             activate_Button:Remove()
--             activate_Button = nil
--         end

--         -- if (not lastMenuData or HELPSCRN:GetOpenMenu() ~= lastMenuData.id) and  then
--         --     if activate_Button then
                
--         --     end
            
--         --     return false
--         -- end
--         --end)
--     end)

-- end

-- hook.Add("TTT2ModifyHelpMainMenu", "Populate Help Main Menu with Debugging Panel", function(helpData)
--     HELPSCRN.populate["ttt2_debugging"](helpData, "ttt2_debugging")
-- end)

