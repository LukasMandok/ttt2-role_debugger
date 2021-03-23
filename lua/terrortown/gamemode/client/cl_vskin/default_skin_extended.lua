-- @class SKIN
-- @section default_skin

local SKIN = {
	Name = "ttt2_default_extended"
}

local TryT = LANG.TryTranslation
local ParT = LANG.GetParamTranslation

local utilGetDefaultColor = util.GetDefaultColor
local utilGetChangedColor = util.GetChangedColor
local utilGetHoverColor = util.GetHoverColor
local utilGetActiveColor = util.GetActiveColor
local utilColorDarken = util.ColorDarken

local vskinGetBackgroundColor = vskin.GetBackgroundColor
local vskinGetAccentColor = vskin.GetAccentColor
local vskinGetDarkAccentColor = vskin.GetDarkAccentColor
local vskinGetShadowColor = vskin.GetShadowColor
local vskinGetTitleTextColor = vskin.GetTitleTextColor
local vskinGetScrollbarColor = vskin.GetScrollbarColor
local vskinGetShadowSize = vskin.GetShadowSize
local vskinGetHeaderHeight = vskin.GetHeaderHeight
local vskinGetBorderSize = vskin.GetBorderSize
local vskinGetCornerRadius = vskin.GetCornerRadius

local drawRoundedBox = draw.RoundedBox
local drawRoundedBoxEx = draw.RoundedBoxEx
local drawBox = draw.Box
local drawShadowedText = draw.ShadowedText
local drawFilteredShadowedTexture = draw.FilteredShadowedTexture
local drawOutlinedBox = draw.OutlinedBox
local drawFilteredTexture = draw.FilteredTexture
local drawSimpleText = draw.SimpleText
local drawLine = draw.Line
local drawGetWrappedText = draw.GetWrappedText
local drawGetTextSize = draw.GetTextSize

local alphaDisabled = 100

local colors = {}
local sizes = {}

-- register fonts
surface.CreateAdvancedFont("DermaTTT2Title", {font = "Trebuchet24", size = 26, weight = 300})
surface.CreateAdvancedFont("DermaTTT2TitleSmall", {font = "Trebuchet24", size = 18, weight = 600})
surface.CreateAdvancedFont("DermaTTT2MenuButtonTitle", {font = "Trebuchet24", size = 22, weight = 300})
surface.CreateAdvancedFont("DermaTTT2MenuButtonDescription", {font = "Trebuchet24", size = 14, weight = 300})
surface.CreateAdvancedFont("DermaTTT2SubMenuButtonTitle", {font = "Trebuchet24", size = 18, weight = 600})
surface.CreateAdvancedFont("DermaTTT2Button", {font = "Trebuchet24", size = 14, weight = 600})
surface.CreateAdvancedFont("DermaTTT2CatHeader", {font = "Trebuchet24", size = 16, weight = 900})
surface.CreateAdvancedFont("DermaTTT2Text", {font = "Trebuchet24", size = 16, weight = 300})
surface.CreateAdvancedFont("DermaTTT2TextLarge", {font = "Trebuchet24", size = 18, weight = 300})


hook.Add("TTT2UpdatedVSkin", "Update ttt2_default_extended Skin", function(oldSkinName, skinName)
    --print("Updateing this skin")

    derma.GetSkinTable()["ttt2_default_extended"]:UpdatedVSkin()
end)
---
-- Updates the @{SKIN}
-- @realm client
function SKIN:UpdatedVSkin()
	colors = {
		background = vskinGetBackgroundColor(),
		accent = vskinGetAccentColor(),
		accentHover = utilGetHoverColor(vskinGetAccentColor()),
		accentActive = utilGetActiveColor(vskinGetAccentColor()),
		accentText = utilGetDefaultColor(vskinGetAccentColor()),
		accentDark = vskinGetDarkAccentColor(),
		accentDarkHover = utilGetHoverColor(vskinGetDarkAccentColor()),
		accentDarkActive = utilGetActiveColor(vskinGetDarkAccentColor()),
		sliderInactive = utilGetChangedColor(vskinGetBackgroundColor(), 75),
		shadow = vskinGetShadowColor(),
		titleText = vskinGetTitleTextColor(),
		default = utilGetDefaultColor(vskinGetBackgroundColor()),
		content = utilGetChangedColor(vskinGetBackgroundColor(), 30),
		handle = utilGetChangedColor(vskinGetBackgroundColor(), 15),
		settingsBox = utilGetChangedColor(vskinGetBackgroundColor(), 150),
		helpBox = utilGetChangedColor(vskinGetBackgroundColor(), 20),
		helpBar = utilGetChangedColor(vskinGetBackgroundColor(), 80),
		helpText = utilGetChangedColor(utilGetDefaultColor(utilGetChangedColor(vskinGetBackgroundColor(), 20)), 40),
		settingsText = utilGetDefaultColor(utilGetChangedColor(vskinGetBackgroundColor(), 150)),
		scrollBar = vskinGetScrollbarColor(),
		scrollBarActive = utilColorDarken(vskinGetScrollbarColor(), 5)
	}

	sizes = {
		shadow = vskinGetShadowSize(),
		header = vskinGetHeaderHeight(),
		border = vskinGetBorderSize(),
		cornerRadius = vskinGetCornerRadius()
	}
end

---
-- Draws the @{SKIN}'s frame
-- @param Panel panel
-- @param number w
-- @param number h
-- @realm client
function SKIN:PaintFrameTTT2(panel, w, h)
	if panel:GetPaintShadow() then
		DisableClipping(true)
		drawRoundedBox(sizes.shadow, -sizes.shadow, -sizes.shadow, w + 2 * sizes.shadow, h + 2 * sizes.shadow, colors.shadow)
		DisableClipping(false)
	end

	-- draw main panel box
	drawBox(0, 0, w, h, colors.background)

	-- draw panel header area
	drawBox(0, 0, w, sizes.header, colors.accent)
	drawBox(0, sizes.header, w, sizes.border, colors.accentDark)

	drawShadowedText(TryT(panel:GetTitle()), panel:GetTitleFont(), 0.5 * w, 0.5 * sizes.header, colors.titleText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
end


---
-- @param Panel panel
-- @param number w
-- @param number h
-- @realm client
function SKIN:PaintButtonTTT2(panel, w, h)
    
	local colorLine = colors.accentDark
	local colorBox = colors.accent
	local colorText = ColorAlpha(utilGetDefaultColor(colors.accent), 220)
	local shift = 0

	if not panel:IsEnabled() then
		local colorAccentDisabled = utilGetChangedColor(colors.default, 150)

		colorLine = utilColorDarken(colorAccentDisabled, 50)
		colorBox = utilGetChangedColor(colors.default, 150)
		colorText = ColorAlpha(utilGetDefaultColor(colorAccentDisabled), 220)
	elseif panel.Depressed or panel:IsSelected() or panel:GetToggle() then
		colorLine = colors.accentDarkActive
		colorBox = colors.accentActive
		colorText = ColorAlpha(utilGetDefaultColor(colors.accent), 220)
		shift = 1
	elseif panel.Hovered then
		colorLine = colors.accentDarkHover
		colorBox = colors.accentHover
		colorText = ColorAlpha(utilGetDefaultColor(colors.accent), 220)
	end

	drawBox(0, 0, w, h, colorBox) --colorBox
	drawBox(0, h - sizes.border, w, sizes.border, colorLine)

	drawShadowedText(
		string.upper(TryT(panel:GetText())),
		panel:GetFont(),
		0.5 * w,
		0.5 * (h - sizes.border) + shift,
		colorText,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	)
end

---
-- @param Panel panel
-- @param number w
-- @param number h
-- @realm client
function SKIN:PaintFormButtonIconTTT2(panel, w, h)
	local colorBoxBack = colors.settingsBox
	local colorBox = colors.accent
	local colorText = ColorAlpha(utilGetDefaultColor(colors.accent), 150)
	local shift = 0
	local pad = 6

	if not panel:IsEnabled() then
		colorBoxBack = ColorAlpha(colors.settingsBox, alphaDisabled)
		colorBox = ColorAlpha(colors.accent, alphaDisabled)
		colorText = ColorAlpha(utilGetDefaultColor(colors.accent), alphaDisabled)
	elseif panel.noDefault then
		colorBoxBack = colors.settingsBox
		colorBox = ColorAlpha(colors.accent, alphaDisabled)
		colorText = ColorAlpha(utilGetDefaultColor(colors.accent), alphaDisabled)
	elseif panel.Depressed or panel:IsSelected() or panel:GetToggle() then
		colorBoxBack = colors.settingsBox
		colorBox = colors.accentActive
		colorText = ColorAlpha(utilGetDefaultColor(colors.accent), 150)
		shift = 1
	elseif panel.Hovered then
		colorBoxBack = colors.settingsBox
		colorBox = colors.accentHover
		colorText = ColorAlpha(utilGetDefaultColor(colors.accent), 150)
	end

	--drawRoundedBoxEx(sizes.cornerRadius, 0, 0, w, h, colorBoxBack, false, true, false, true)
	drawRoundedBox(sizes.cornerRadius, 1, 1, w - 2, h - 2, colorBox)

	drawFilteredShadowedTexture(pad, pad + shift, w - 2 * pad, h - 2 * pad, panel.material, colorText.a, colorText)
end



function SKIN:PaintFormButtonLockTTT2(panel, w, h, separate)
    local colorBoxBack = colors.settingsBox
	local colorBox = colors.accent
	local colorText = ColorAlpha(utilGetDefaultColor(colors.accent), 150)
	local shift = 0
	local pad = 6

	if not panel:IsEnabled() then
		colorBoxBack = ColorAlpha(colors.settingsBox, alphaDisabled)
		colorBox = ColorAlpha(colors.accent, alphaDisabled)
        colorText = ColorAlpha(utilGetDefaultColor(colors.accent), alphaDisabled)
	elseif panel.noDefault then
		colorBoxBack = colors.settingsBox
		colorBox = ColorAlpha(colors.accent, alphaDisabled)
		colorText = ColorAlpha(utilGetDefaultColor(colors.accent), alphaDisabled)
	elseif panel.Depressed or panel:IsSelected() or panel:GetToggle() then
		colorBoxBack = colors.settingsBox
		--colorBox = colors.accentActive
        colorBox = ColorAlpha(Color(230, 77, 77), 255)
		colorText = ColorAlpha(utilGetDefaultColor(colors.accent), 150)
		shift = 1
	elseif panel.Hovered then
		colorBoxBack = colors.settingsBox
		colorBox = colors.accentHover
		colorText = ColorAlpha(utilGetDefaultColor(colors.accent), 150)
	end

    if (panel.separate == nil or panel.separate == false) then
	    drawRoundedBoxEx(sizes.cornerRadius, 0, 0, w, h, colorBoxBack, false, false, false, false)
    end
	drawRoundedBox(sizes.cornerRadius, 1, 1, w - 2, h - 2, colorBox)

	drawFilteredShadowedTexture(pad, pad + shift, w - 2 * pad, h - 2 * pad, panel.material, colorText.a, colorText)
end


---
-- @param Panel panel
-- @param number w
-- @param number h
-- @realm client
function SKIN:PaintLabelTTT2(panel, w, h)
    local colorLine = utilGetChangedColor(colors.background, 50)
	local colorText = utilGetChangedColor(colors.default, 50)
	local paddingX = 10
	local paddingY = 10

	drawBox(0, 0, w, h, colors.background)
	drawBox(0, h-4 , w, h-1, colorLine)

	drawShadowedText(
		string.upper(TryT(panel:GetText())),
		panel:GetFont(),
		0.5 * w,
		0.5 * h,
		colorText,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	)

    -- local colorText = colors.settingsText
    -- local colorBox = colors.settingsBox

	-- drawSimpleText(
	-- 	TryT(panel:GetText()),
	-- 	panel:GetFont(),
	-- 	0.5 * w,
	-- 	0.5 * h,
	-- 	utilGetChangedColor(colors.default, 40),
	-- 	TEXT_ALIGN_CENTER, -- TEXT_ALIGN_LEFT
	-- 	TEXT_ALIGN_CENTER
	-- )
end



function SKIN:PaintMenuTTT2(panel, w, h)
	--drawBox(0, 0, w, h, colors.content)
    
    local colorBox = colors.settingsBox
	local colorHandle = colors.handle

	if not panel:IsEnabled() then
		colorBox = ColorAlpha(colors.settingsBox, alphaDisabled)
		colorHandle = ColorAlpha(colors.handle, alphaDisabled)
	end

	drawRoundedBoxEx(sizes.cornerRadius, 0, 0, w, h, colorBox, false, true, false, true)
	drawRoundedBox(sizes.cornerRadius, 1, 1, w - 2, h - 2, colorHandle)
end


function SKIN:PaintMenuColumTTT2(panel, w, h)
    local colorOutline = utilGetChangedColor(colors.default, 170)
	drawOutlinedBox(0, 0, w, h, 1, colorOutline)
end


function SKIN:PaintMenuOptionTTT2(panel, w, h)
    local colorBoxBack = colors.settingsBox
	local colorBox = colors.handle 
	local colorText = utilGetChangedColor(utilGetDefaultColor(colors.handle), 50)
	local shift = 0
	local pad = 6


    if not panel:IsEnabled() and not panel.selected then
		--colorBoxBack = ColorAlpha(colors.settingsBox, alphaDisabled)
		--colorBox = ColorAlpha(colors.settingsBox, alphaDisabled)
        colorText = ColorAlpha(colorText, alphaDisabled)
    elseif panel.selected then
        --colorBox = ColorAlpha(colors.accentHover, 50)
        colorBoxBack = ColorAlpha(colors.accentHover, 200)--colors.settingsBox

        drawRoundedBoxEx(sizes.cornerRadius, 0, 0, w, h, colorBoxBack, false, true, false, true)
		drawRoundedBox(sizes.cornerRadius, 2, 2, w - 4, h - 4, colorBox)

        colorText = ColorAlpha(utilGetActiveColor(colorText), 200)
    end
    if panel.Hovered then
        --colorBox = colors.accentHover
        colorBoxBack = colors.settingsBox

        drawRoundedBoxEx(sizes.cornerRadius, 0, 0, w, h, colorBoxBack, false, true, false, true)
		drawRoundedBox(sizes.cornerRadius, 2, 2, w - 4, h - 4, colorBox)

		colorText = ColorAlpha(utilGetHoverColor(colorText), 200)
	end

    --drawRoundedBox(sizes.cornerRadius, 1, 1, w - 2, h - 2, colorBox)
    
    drawSimpleText(
		TryT(panel:GetText()),
		panel:GetFont(),
		0.5 * w,
		0.5 * h,
		colorText, --utilGetChangedColor(colors.default, 40),
		TEXT_ALIGN_CENTER, -- TEXT_ALIGN_LEFT
		TEXT_ALIGN_CENTER
	)

end




-- REGISTER DERMA SKIN
derma.DefineSkin(SKIN.Name, "TTT2 default skin for all vgui elements", SKIN)
