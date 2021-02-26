print("Creating additional TTTFiles list")

TTT2DIR_ext = "terrortown/gamemode/"

local additionalTTTFiles = {
    cl_vskin__vgui__dform__extended = {file = "cl_vskin/vgui/dform_ttt2_extended.lua", on = "client"}
}


hook.Add("TTT2ModifyFiles", "Add additional Files", function(TTTFiles)
    print("Merging new TTTFies to the List.")
    table.Merge(TTTFiles, additionalTTTFiles)
    if SERVER then
        for _, inc in pairs(additionalTTTFiles) do
            if inc.on == "client" or inc.on == "shared" then
                AddCSLuaFile(TTT2DIR .. inc.on .. "/" .. inc.file)
            end
        end
    end
end) 