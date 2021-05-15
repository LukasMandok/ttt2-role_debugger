-- German language strings

local L = LANG.GetLanguageTableReference("de")

----- General -----
L["random"] = "Zufällig"

----- Debuging Menu -----
L["menu_debugging_title"] = "Debuggen"
L["menu_debugging_description"] = "Stellt verschiedene Debugging Funktionen bereit."
L["debugging_roles_activate"] = "Einschalten"

----------------------------
----- Debugging Roles ------
----------------------------
L["submenu_debugging_roles_title"] = "Rollen"
L["submenu_debugging_random_role"] = "Zufällig"


-- Control
L["header_debugging_roles_control"] = "Konrolle"
L["debugging_roles_control_apply"] = "Rollen übernehmen"
L["debugging_roles_control_apply_nr"] = "Rollen nächste Runde übernehmen"
L["debugging_roles_control_refresh"] = "Alle Rollen aktualisieren"
L["debugging_roles_control_restart"] = "Runde neustarten"


-- Player
L["header_debugging_roles_player"] = "Spieler Rollen"
L["debugging_roles_player_refresh"] = "Spieler Rollen aktualisieren"

-- Bots
L["header_debugging_roles_bot"] = "Bot Rollen"
L["debugging_roles_bot_refresh"] = "Bot Rollen aktualisieren"

----- Settings -----
L["header_debugging_roles_settings"] = "Einstellungen"
L["debugging_roles_settings_auto_apply"] = "Rollen automatisch übernehmen"
L["debugging_roles_settings_auto_apply_help"] = [[
Übernimmt Rollen Änderungen automatisch für die nächste Runde.]]

L["debugging_roles_settings_auto_refresh"] = "Rollen automatisch aktuallisieren"
L["debugging_roles_settings_auto_refresh_help"] = [[
Aktuallisiert die Rollen automatisch zu den gerade festgelegten, 
wenn das Debugging Menü geöffnet wird.]]

L["debugging_roles_settings_overhead_icon"] = "Überkopf Rollen Icons"
L["debugging_roles_settings_overhead_icon_help"] = [[
Zeigt die Rollen der Spieler mit überkopf Icons während der Runde an.]]



----------------------------
---- Debugging Classes -----
----------------------------
L["submenu_debugging_classes_title"] = "Klassen"



----------------------------
---- Debugging Weapons -----
----------------------------
L["submenu_debugging_weapons_title"] = "Waffen"



----------------------------
------ Debugging Bots ------
----------------------------
L["submenu_debugging_bots_title"] = "Bots"

----- Settings -----
L["header_debugging_bots_settings"] = "Einstellungen"

L["debugging_bots_settings_moving"] = "Bot Bewegung einschalten"


----------------------------
---- Controlling Players ---
----------------------------
L["submenu_debugging_controller_title"] = "Spieler Kontrolle"

L["header_debugging_controller_player"] = "Spieler"
L["debugging_controller_simple_firstperson"] = "Einfache First-Person Perspektive"
L["debugging_controller_firstperson"] = "First-Person Perspektive"
L["debugging_controller_thirdperson"] = "Third-Person Perspektive"
L["debugging_controller_roaming"] = "Freie Kamera"

L["debugging_controller_net_mode"] = "[Serverside | Clientside] Berechnungen"

L["debugging_controller_start"] = "Starte Spieler Kontrolle"
L["debugging_controller_end"] = "Beende Spieler Kontrolle"
