print("Creating additional TTTFiles list")

--TTT2DIR_ext = "terrortown/gamemode/"

local additionalTTTFiles = {
    cl_vskin__vgui__dform__extended = {file = "cl_vskin/vgui/dform_ttt2_extended.lua", on = "client"}
}


--hook.Add("TTT2ModifyFiles", "Add additional Files", function(TTTFiles)

-- TODO: Ich bin mir nicht sicher, ob das so richtig ist, wenn das vor der eigentlichen sh_include.lua Datei aufgerufen wird, funktioniert das nicht.
print("Merging new TTTFies to the List.")
if TTTFiles != nil then
    table.Merge(TTTFiles, additionalTTTFiles)
    if SERVER then
        for _, inc in pairs(additionalTTTFiles) do
            if inc.on == "client" or inc.on == "shared" then
                print("sending additional tiles to Client.")
                AddCSLuaFile(TTT2DIR .. inc.on .. "/" .. inc.file)
            end
        end
    else 
        for _, inc in pairs(additionalTTTFiles) do
            if inc.on == "client" or inc.on == "shared" then
                print("including additional files on client side.")
                ttt_include("cl_vskin__vgui__dform__extended")
            end
        end
    end
end
--end) 