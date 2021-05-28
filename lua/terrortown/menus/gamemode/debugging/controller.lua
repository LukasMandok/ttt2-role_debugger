CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"

CLGAMEMODESUBMENU.priority = 50
CLGAMEMODESUBMENU.title = "submenu_debugging_controller_title"

local function PopulateControlPanel(parent)

    local playerList = player.GetAll()

    local playerListNames = {}
    local index_remove = nil
    for i = 1, #playerList do
        playerListNames[i] = playerList[i]:Nick()
        if playerListNames[i] == LocalPlayer():Nick() then
            index_remove = i
        end
    end
    if index_remove then
        table.remove(playerListNames, index_remove)
        table.remove(playerList, index_remove)
    end

    local formPlayer = vgui.CreateTTT2Form_extended(parent, "Control Players")
    formPlayer:Dock(TOP)

    local target_ply = playerList[1]
    local view_flag  = PC_CAM_SIMPLEFIRSTPERSON
    local net_flag   = PC_SERVERSIDE

    formPlayer:MakeComboBox({
        label = LANG.GetTranslation("header_debugging_controller_player"),
        choices = playerListNames,
        data = playerList,
        selectName = playerListNames[1],
        default = playerListNames[1],
        OnChange = function(_, _, value, data)
            target_ply = data
        end,
    })

    local sfp_check, fp_check, tp_check, r_check

    sfp_check = formPlayer:MakeCheckBox({
        label = LANG.GetTranslation("debugging_controller_simple_firstperson"),
        initial = true,
        default = true,
        OnChange = function(_, value)
            if value == true then
                view_flag = PC_CAM_SIMPLEFIRSTPERSON
                fp_check:SetValue(false)
                tp_check:SetValue(false)
                r_check:SetValue(false)
            end
        end,
    })

    fp_check = formPlayer:MakeCheckBox({
        label = LANG.GetTranslation("debugging_controller_firstperson") .. " (not implented yet)",
        initial = false,
        default = false,
        disabled = true,
        OnChange = function(_, value)
            if value == true then
                view_flag = PC_CAM_FIRSTPERSON
                sfp_check:SetValue(false)
                tp_check:SetValue(false)
                r_check:SetValue(false)
            end
        end,
    })

    tp_check = formPlayer:MakeCheckBox({
        label = LANG.GetTranslation("debugging_controller_thirdperson"),
        initial = false,
        default = false,
        OnChange = function(_, value)
            if value == true then
                view_flag = PC_CAM_THIRDPERSON
                sfp_check:SetValue(false)
                fp_check:SetValue(false)
                r_check:SetValue(false)
            end
        end,
    })

    r_check = formPlayer:MakeCheckBox({
        label = LANG.GetTranslation("debugging_controller_roaming") .. " (not implented yet)",
        initial = false,
        default = false,
        disabled = true,
        OnChange = function(_, value)
            if value == true then
                view_flag = PC_CAM_ROAMING
                sfp_check:SetValue(false)
                fp_check:SetValue(false)
                tp_check:SetValue(false)
            end
        end,
    })

    net_check = formPlayer:MakeCheckBox({
        label = LANG.GetTranslation("debugging_controller_net_mode"),
        initial = false,
        default = false,
        OnChange = function(_, value)
            if value == false then
                net_flag = PC_SERVERSIDE
            else
                net_flag = PC_CLIENTSIDE
            end
        end,
    })


    local controlButton = formPlayer:MakeDoubleButton({
        label1 = LANG.GetTranslation("debugging_controller_start"),
        OnClick1 = function(_)
            print("Start Control of Player:", target_ply:Nick())
            net.Start("PlayerController:NetControl")
                net.WriteUInt( PC_CL_START, 3)
                net.WriteEntity(target_ply)
                net.WriteUInt(view_flag, 2)
                net.WriteUInt(net_flag, 1)
            net.SendToServer()
        end,
        label2 = LANG.GetTranslation("debugging_controller_end"),
        OnClick2 = function(_)
            print("End Control")
            net.Start("PlayerController:NetControl")
                net.WriteUInt( PC_CL_END, 3)
            net.SendToServer()
        end,
    })

    local controlButton_debug = formPlayer:MakeDoubleButton({
        label1 = "(Debugging!) Bot1 Control LocalPlayer",
        OnClick1 = function(_)
            print("Start Control of Player:", target_ply:Nick())
            net.Start("PlayerController:NetControlTest")
                net.WriteUInt(view_flag, 2)
                net.WriteUInt(net_flag, 1)
            net.SendToServer()
        end
    })


end

function CLGAMEMODESUBMENU:Populate(parent)
    hook.Run("PopulateActivationButton")
    if PlayerController ~= nil then
        PopulateControlPanel(parent)
    end
end