if SERVER then
    resource.AddFile("materials/vgui/ttt/vskin/helpscreen/debugging.vmt")
    resource.AddFile("materials/vgui/ttt/vskin/helpscreen/debugging_large.vmt")
    resource.AddFile("materials/vgui/ttt/vskin/icon_lock_closed.vmt")
    resource.AddFile("materials/vgui/ttt/vskin/icon_lock_open.vmt")
    resource.AddFile("materials/vgui/ttt/vskin/icon_random.vmt")
    --resource.AddFile("materials/vgui/ttt/vskin/helpscreen/icon_lock_closed_large.vmt")
    --resource.AddFile("materials/vgui/ttt/vskin/helpscreen/icon_lock_open_large.vmt")
end

local additionalTTTFiles = {
    cl_vskin__default_skin_extended = {file = "cl_vskin/default_skin_extended.lua", on = "client"},
    cl_vskin__vgui__dbutton_toggle = {file = "cl_vskin/vgui/dbutton_ttt2_toggle.lua", on = "client"},
    cl_vskin__vgui__dmenuoption_roles = {file = "cl_vskin/vgui/dmenuoption_ttt2_roles.lua", on = "client"},
    cl_vskin__vgui__dmenu_roles = {file = "cl_vskin/vgui/dmenu_ttt2_roles.lua", on = "client"},
    cl_vskin__vgui__dcombobox_roles = {file = "cl_vskin/vgui/dcombobox_ttt2_roles.lua", on = "client"},
    cl_vskin__vgui__dcontainer = {file = "cl_vskin/vgui/dcontainer_ttt2.lua", on = "client"},
    cl_vskin__vgui__dform_extended = {file = "cl_vskin/vgui/dform_ttt2_extended.lua", on = "client"},
}


--hook.Add("TTT2ModifyFiles", "Add additional Files", function(TTTFiles)

if TTTFiles ~= nil then
    table.Merge(TTTFiles, additionalTTTFiles)
    if SERVER then
        for _, inc in pairs(additionalTTTFiles) do
            if inc.on == "client" or inc.on == "shared" then
                AddCSLuaFile(TTT2DIR .. inc.on .. "/" .. inc.file)
            end
        end
    else
        ttt_include( "cl_vskin__default_skin_extended" )
        ttt_include( "cl_vskin__vgui__dbutton_toggle" )
        ttt_include( "cl_vskin__vgui__dmenuoption_roles")
        ttt_include( "cl_vskin__vgui__dmenu_roles" )
        ttt_include( "cl_vskin__vgui__dcombobox_roles" )
        ttt_include( "cl_vskin__vgui__dcontainer" )
        ttt_include( "cl_vskin__vgui__dform_extended" )
    end
end
