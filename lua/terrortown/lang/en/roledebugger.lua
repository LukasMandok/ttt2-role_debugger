-- English language strings

local L = LANG.GetLanguageTableReference("en")

----- General -----
L["random"] = "Random"

----- Debuging Menu -----
L["menu_debugging_title"] = "Debugging"
L["menu_debugging_description"] = "Provides various debugging functions."
L["debugging_roles_activate"] = "Activate"

----------------------------
----- Debugging Roles ------
----------------------------
L["submenu_debugging_roles_title"] = "Roles"
L["submenu_debugging_random_role"] = "Random"


-- Control
L["header_debugging_roles_control"] = "Control"
L["debugging_roles_control_apply"] = "Apply roles"
L["debugging_roles_control_apply_nr"] = "Apply roles next round"
L["debugging_roles_control_refresh"] = "Refresh all roles"
L["debugging_roles_control_restart"] = "Restart round"


-- Player
L["header_debugging_roles_player"] = "Player roles"
L["debugging_roles_player_refresh"] = "Refresh player roles"

-- Bots
L["header_debugging_roles_bot"] = "Bot roles"
L["debugging_roles_bot_refresh"] = "Refresh bot roles"

----- Settings -----
L["header_debugging_roles_settings"] = "Settings"
L["debugging_roles_settings_auto_apply"] = "Apply roles automatically"
L["debugging_roles_settings_auto_apply_help"] = [[
Automatically activates the roles on the next round if a value is changed.]]

L["debugging_roles_settings_auto_refresh"] = "Refresh roles automatically"
L["debugging_roles_settings_auto_refresh_help"] = [[
Automatically refreshes the roles to the current assigned ones, 
if the debug menu is opened.]]

L["debugging_roles_settings_overhead_icon"] = "Overhead role icons"
L["debugging_roles_settings_overhead_icon_help"] = [[
Show overhead role icons during round.]]




----------------------------
---- Debugging Classes -----
----------------------------
L["submenu_debugging_classes_title"] = "Classes"



----------------------------
---- Debugging Weapons -----
----------------------------
L["submenu_debugging_weapons_title"] = "Weappons"



----------------------------
------ Debugging Bots ------
----------------------------
L["submenu_debugging_bots_title"] = "Bots"

----- Settings -----
L["header_debugging_bots_settings"] = "Settings"

L["debugging_bots_settings_moving"] = "Enable moving bots"


----------------------------
---- Controlling Players ---
----------------------------
L["submenu_debugging_controller_title"] = "Player control"

L["header_debugging_controller_player"] = "Player"
L["debugging_controller_simple_firstperson"] = "Simple First-Person"
L["debugging_controller_firstperson"] = "First-Person"
L["debugging_controller_thirdperson"] = "Third-Person"
L["debugging_controller_roaming"] = "Free roaming"

L["debugging_controller_net_mode"] = "[Serverside | Clientside] calculations"

L["debugging_controller_start"] = "Start player control"
L["debugging_controller_end"] = "End player control"