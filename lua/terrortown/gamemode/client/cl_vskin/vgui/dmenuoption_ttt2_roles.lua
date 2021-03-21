local PANEL = {}

AccessorFunc( PANEL, "m_pMenu", "Menu" )
AccessorFunc( PANEL, "m_bChecked", "Checked" )
AccessorFunc( PANEL, "m_bCheckable", "IsCheckable" )

function PANEL:Init()
	self:SetContentAlignment( 4 )
	self:SetTextInset( 32, 0 ) -- Room for icon on left
	self:SetChecked( false )

    self:SetSkin("ttt2_default_extended")
    self:SetFont("DermaTTT2Text")

    self.selected = false

    self.text = ""

	--self.material = material_off

	-- remove label and overwrite function
	self:SetText("")
	self.SetText = function(slf, text)
		slf.text = text
	end
end

function PANEL:GetText()
	return self.text
end

-- function PANEL:SetSubMenu( menu )

-- 	self.SubMenu = menu

-- 	if ( !IsValid( self.SubMenuArrow ) ) then

-- 		self.SubMenuArrow = vgui.Create( "DPanel", self )
-- 		self.SubMenuArrow.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "MenuRightArrow", panel, w, h ) end

-- 	end

-- end

-- function PANEL:AddSubMenu()

-- 	local SubMenu = DermaMenu( true, self )
-- 	SubMenu:SetVisible( false )
-- 	SubMenu:SetParent( self )

-- 	self:SetSubMenu( SubMenu )

-- 	return SubMenu

-- end

-- function PANEL:OnCursorEntered()

-- 	if ( IsValid( self.ParentMenu ) ) then
-- 		self.ParentMenu:OpenSubMenu( self, self.SubMenu )
-- 		return
-- 	end

-- 	self:GetParent():OpenSubMenu( self, self.SubMenu )

-- end

function PANEL:OnCursorExited()
end

function PANEL:Paint( w, h )
	derma.SkinHook( "Paint", "MenuOptionTTT2", self, w, h )

	--
	-- Draw the button text
	--
	return false

end

function PANEL:OnMousePressed( mousecode )

	self.m_MenuClicking = true

	DButton.OnMousePressed( self, mousecode )

end

function PANEL:OnMouseReleased( mousecode )

	DButton.OnMouseReleased( self, mousecode )

	if ( self.m_MenuClicking && mousecode == MOUSE_LEFT ) then

		self.m_MenuClicking = false
		CloseDermaMenus()

	end

end

function PANEL:DoRightClick()

	if ( self:GetIsCheckable() ) then
		self:ToggleCheck()
	end

end

function PANEL:DoClickInternal()

	if ( self:GetIsCheckable() ) then
		self:ToggleCheck()
	end

	if ( self.m_pMenu ) then

		self.m_pMenu:OptionSelectedInternal( self )

	end

end

function PANEL:ToggleCheck()

	self:SetChecked( !self:GetChecked() )
	self:OnChecked( self:GetChecked() )

end

function PANEL:OnChecked( b )
end


function PANEL:SetIcon( icon, color )
	if ( !icon ) then

		if ( IsValid( self.roleIcon ) ) then
			self.roleIcon:Remove()
		end

		return
	end

	if ( !IsValid( self.roleIcon ) ) then
		self.roleIcon = vgui.Create( "SimpleIcon", self )
	end

    -- TODO: RIchtig überprüfen, ob das Icon vohanden ist
    -- SimpleRoleIcon
    --self.roleIcon:SetIcon("vgui/ttt/dynamic/icon_base")
    --self.roleIcon.Icon:SetImage2("vgui/ttt/dynamic/icon_base_base")
    --self.roleIcon.Icon:SetImageOverlay("vgui/ttt/dynamic/icon_base_base_overlay")

    if icon ~= "" then
        self.roleIcon:SetIcon( icon )
        if color then
            self.roleIcon:SetIconColor( color )
        end 
    end

	self.roleIcon:SizeToContents()
    self.roleIcon:SetIconSize( 35 )
    self.roleIcon:CenterVertical(0.8)
    self.roleIcon:AlignLeft( 10 )

    self.roleIcon.PaintOverHovered = function() end

	self:InvalidateLayout()

end


function PANEL:PerformLayout( w, h )

	self:SizeToContents()
	self:SetWide( self:GetWide() + 30 )

	local w = math.max( self:GetParent():GetWide(), self:GetWide() )

	self:SetSize( w, 45 )

	-- if ( IsValid( self.SubMenuArrow ) ) then

	-- 	self.SubMenuArrow:SetSize( 15, 15 )
	-- 	self.SubMenuArrow:CenterVertical()
	-- 	self.SubMenuArrow:AlignRight( 4 )

	-- end

	DButton.PerformLayout( self, w, h )

end

-- function PANEL:Paint(w, h)
-- 	derma.SkinHook("Paint", "Button", self, w, h)

-- 	return false
-- end

derma.DefineControl( "DMenuOptionTTT2_roles", "Menu Option Line for Role Selection", PANEL, "DButton" )