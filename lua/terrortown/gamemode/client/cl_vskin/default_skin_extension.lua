--[[ -- local SKIN = {
-- 	Name = "ttt2_default"
-- }

--DEFINE_BASECLASS("ttt2_default")
-- setmetatable( SKIN, {__index = getmetatable(derma.GetNamedSkin( "ttt2_default" ))})
--setmetatable( getmetatable(derma.GetNamedSkin( "ttt2_default" )), nil)

local SKIN = {}
setmetatable(SKIN, nil) --{__index = getmetatable(derma.GetNamedSkin( "ttt2_default" ))})

print("sldkjfhskdljfh skjadfh       Running again.")

---
-- @param Panel panel
-- @param number w
-- @param number h
-- @realm client
function SKIN:PaintContainerTTT2(panel, w, h)
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! New Skin")

	drawBox(0, 0, w, h, Color(200, 45, 52, 255))
	drawBox(0, h - sizes.border, w, sizes.border, colors.accent)
end

function SKIN:Testing()
    print("MAn kann jetzt mittels der anderen Methafunktion darauf zugreifen")
end

setmetatable(derma.GetNamedSkin( "ttt2_default" ), {__index = getmetatable(derma.GetNamedSkin( "ttt2_default" ))})


-- REGISTER DERMA SKIN
--derma.DefineSkin(SKIN.Name, "extension for TTT2 default skin", SKIN)

--hook.Add( "ForceDermaSkin", "relace default Skin", function()
--	return "ttt2_default_extension"
--end ) ]]