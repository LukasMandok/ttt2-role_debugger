local PANEL = {}

AccessorFunc( PANEL, "m_bBorder",			"DrawBorder" )
AccessorFunc( PANEL, "m_bDeleteSelf",		"DeleteSelf" )
AccessorFunc( PANEL, "m_iMinimumWidth",		"MinimumWidth" )
AccessorFunc( PANEL, "m_bDrawColumn",		"DrawColumn" )
AccessorFunc( PANEL, "m_iMaxHeight",		"MaxHeight" )

AccessorFunc( PANEL, "m_pOpenSubMenu",		"OpenSubMenu" )

function PANEL:Init()

	self:SetIsMenu( true )
	self:SetDrawBorder( true )
	self:SetPaintBackground( true )
	self:SetMinimumWidth( 100 )
	self:SetDrawOnTop( true )
	self:SetMaxHeight( ScrH() * 0.5 )
	self:SetDeleteSelf( true )

	self:SetPadding( 0 )

    self:SetSkin("ttt2_default_extended")

    self.Columns = {}

	-- Automatically remove this panel when menus are to be closed
	RegisterDermaMenuForClose( self )

end

function PANEL:AddPanel( pnl )

	self:AddItem( pnl )
	pnl.ParentMenu = self

end

-- TODO: Add Column
function PANEL:AddColumn( name )
    local column = vgui.Create( "DListLayout", self)
    column.Paint = function( p, w, h )
		derma.SkinHook( "Paint", "MenuColumTTT2", p, w, h )
	end
    column.PerformLayout = function(p) end
    --column:Dock(LEFT)

    local title = vgui.Create( "DLabelTTT2", column)
    title:SetSkin("default_ttt2_extended")
    title:SetTall(40)

    title:SetText( name )

    column:Add( title )

    -- TODO: Das ersetzen
    column:SetTall(300)
    column:SetWide(200)

    self:AddPanel(column)
    self.Columns[#self.Columns + 1] = column

    return column
end

function PANEL:AddOptionToColumn( name, column, selected, funcFunction )

	local pnl = vgui.Create( "DMenuOptionTTT2_roles", self )
	pnl:SetMenu( self )
	pnl:SetText( name )
    pnl.selected = selected

	if ( funcFunction ) then pnl.DoClick = funcFunction end

	column:Add( pnl )

	return pnl

end

function PANEL:AddOption( strText, funcFunction )

	local pnl = vgui.Create( "DMenuOptionTTT2_roles", self )
	pnl:SetMenu( self )
	pnl:SetText( strText )
	if ( funcFunction ) then pnl.DoClick = funcFunction end

	self:AddPanel( pnl )

	return pnl

end

-- function PANEL:AddCVar( strText, convar, on, off, funcFunction )

-- 	local pnl = vgui.Create( "DMenuOptionCVar", self )
-- 	pnl:SetMenu( self )
-- 	pnl:SetText( strText )
-- 	if ( funcFunction ) then pnl.DoClick = funcFunction end

-- 	pnl:SetConVar( convar )
-- 	pnl:SetValueOn( on )
-- 	pnl:SetValueOff( off )

-- 	self:AddPanel( pnl )

-- 	return pnl

-- end

function PANEL:AddSpacer( strText, funcFunction )

	local pnl = vgui.Create( "DPanel", self )
	pnl.Paint = function( p, w, h )
		derma.SkinHook( "Paint", "MenuSpacer", p, w, h )
	end

	pnl:SetTall( 1 )
	self:AddPanel( pnl )

	return pnl

end

-- function PANEL:AddSubMenu( strText, funcFunction )

-- 	local pnl = vgui.Create( "DMenuOption", self )
-- 	local SubMenu = pnl:AddSubMenu( strText, funcFunction )

-- 	pnl:SetText( strText )
-- 	if ( funcFunction ) then pnl.DoClick = funcFunction end

-- 	self:AddPanel( pnl )

-- 	return SubMenu, pnl

-- end

function PANEL:Hide()

	local openmenu = self:GetOpenSubMenu()
	if ( openmenu ) then
		openmenu:Hide()
	end

	self:SetVisible( false )
	self:SetOpenSubMenu( nil )

end

-- function PANEL:OpenSubMenu( item, menu )

-- 	-- Do we already have a menu open?
-- 	local openmenu = self:GetOpenSubMenu()
-- 	if ( IsValid( openmenu ) && openmenu:IsVisible() ) then

-- 		-- Don't open it again!
-- 		if ( menu && openmenu == menu ) then return end

-- 		-- Close it!
-- 		self:CloseSubMenu( openmenu )

-- 	end

-- 	if ( !IsValid( menu ) ) then return end

-- 	local x, y = item:LocalToScreen( self:GetWide(), 0 )
-- 	menu:Open( x - 3, y, false, item )

-- 	self:SetOpenSubMenu( menu )

-- end

-- function PANEL:CloseSubMenu( menu )

-- 	menu:Hide()
-- 	self:SetOpenSubMenu( nil )

-- end

function PANEL:Paint( w, h )

	if ( !self:GetPaintBackground() ) then return end

	derma.SkinHook( "Paint", "MenuTTT2", self, w, h )
	return true

end

function PANEL:ChildCount()
	return #self:GetCanvas():GetChildren()
end

function PANEL:GetChild( num )
	return self:GetCanvas():GetChildren()[ num ]
end

function PANEL:PerformLayout( w, h )

	--local w = self:GetMinimumWidth()

	-- Width of all Columns
    local w = 1
    local h = 0

	for k, col in pairs( self.Columns ) do
		local y = 1

	 	col:InvalidateLayout( true )
        col:SetPos(w, y)

        for _, pnl in pairs( col:GetChildren() ) do
            pnl:SetWide( col:GetWide() )
            pnl:SetPos( w, y )
            pnl:InvalidateLayout(true)

            y = y + pnl:GetTall()
        end

        w = w + col:GetWide()
        h = math.max(h, y)
	end

    for k, col in pairs( self.Columns ) do
        col:SetTall(h)
    end

	--for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
    -- 	pnl:InvalidateLayout( true )
	-- 	w = math.max( w, pnl:GetWide() )
	-- end

    w = math.max(w, self:GetMinimumWidth())
    h = math.min(h, self:GetMaxHeight())

	self:SetWide( w + 2 )
    self:SetTall( h + 2 )

	--local y = 0 -- for padding

	-- for k, pnl in pairs( self:GetCanvas():GetChildren() ) do

	-- 	pnl:SetWide( w )
	-- 	pnl:SetPos( 0, y )
	-- 	pnl:InvalidateLayout( true )

	-- 	y = y + pnl:GetTall()

	-- end

	--y = math.min( y, self:GetMaxHeight() )

	--self:SetTall( y )

	derma.SkinHook( "Layout", "Menu", self )

	DScrollPanel.PerformLayout( self, w, h )

end

--[[---------------------------------------------------------
	Open - Opens the menu.
	x and y are optional, if they're not provided the menu
		will appear at the cursor.
-----------------------------------------------------------]]
function PANEL:Open( x, y, skipanimation, ownerpanel )

	RegisterDermaMenuForClose( self )

	local maunal = x && y

	x = x or gui.MouseX()
	y = y or gui.MouseY()

	local OwnerHeight = 0
	local OwnerWidth = 0

	if ( ownerpanel ) then
		OwnerWidth, OwnerHeight = ownerpanel:GetSize()
	end

	self:InvalidateLayout( true )

	local w = self:GetWide()
	local h = self:GetTall()

	self:SetSize( w, h )

	if ( y + h > ScrH() ) then y = ( ( maunal && ScrH() ) or ( y + OwnerHeight ) ) - h end
	if ( x + w > ScrW() ) then x = ( ( maunal && ScrW() ) or x ) - w end
	if ( y < 1 ) then y = 1 end
	if ( x < 1 ) then x = 1 end

	local p = self:GetParent()
	if ( IsValid( p ) && p:IsModal() ) then
		-- Can't popup while we are parented to a modal panel
		-- We will end up behind the modal panel in that case

		x, y = p:ScreenToLocal( x, y )

		-- We have to reclamp the values
		if ( y + h > p:GetTall() ) then y = p:GetTall() - h end
		if ( x + w > p:GetWide() ) then x = p:GetWide() - w end
		if ( y < 1 ) then y = 1 end
		if ( x < 1 ) then x = 1 end

		self:SetPos( x, y )
	else
		self:SetPos( x, y )

		-- Popup!
		self:MakePopup()
	end

	-- Make sure it's visible!
	self:SetVisible( true )

	-- Keep the mouse active while the menu is visible.
	self:SetKeyboardInputEnabled( false )

end

--
-- Called by DMenuOption
--
function PANEL:OptionSelectedInternal( option )

	self:OptionSelected( option, option:GetText() )

end

function PANEL:OptionSelected( option, text )

	-- For override

end

function PANEL:ClearHighlights()

	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
		pnl.Highlight = nil
	end

end

function PANEL:HighlightItem( item )

	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
		if ( pnl == item ) then
			pnl.Highlight = true
		end
	end

end

derma.DefineControl( "DMenuTTT2_roles", "A Menu for Role Selection", PANEL, "DScrollPanelTTT2" )