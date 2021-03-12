---
-- @class PANEL
-- @section DButtonTTT2

local PANEL = {}

---
-- @accessor boolean
-- @realm client
AccessorFunc(PANEL, "m_bBorder", "DrawBorder", FORCE_BOOL)

---
-- @ignore
function PANEL:Init()
	self:SetIsToggle(true) -- enables toggeling
	self:SetToggle(false)  -- turned off by default

	self:SetContentAlignment(5)

	self:SetTall(22)
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self:SetCursor("hand")
	self:SetFont("DermaTTT2Button")

	self.text = ""
	--self.state = false

	--self.material = material_off

	-- remove label and overwrite function
	self:SetText("")
	self.SetText = function(slf, text)
		slf.text = text
	end
end

---
-- @return string
-- @realm client
function PANEL:GetText()
	return self.text
end

---
-- @return boolean
-- @realm client
function PANEL:IsDown()
	return self.Depressed
end


---
-- @realm client
function PANEL:OnReleased()
	self:Toggle()
end


function PANEL:OnToggled(state)
	if state == false then
		print("Of State")
		self.material = self.material_off
	else
		print("On State")
		self.material = self.material_on
	end
end

-- function PANEL:Toggle()
-- 	print("Toggle Status:", self:GetToggle())
-- end

-- function PANEL:ToggleState()
-- 	if self.state == false then
-- 		self.state = true
-- 		self.material = self.material_on
-- 	else
-- 		self.state = false
-- 		self.material = self.material_off
-- 	end
-- end


-- function PANEL:SetState(state)

-- end

---
-- @ignore
function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "ButtonTTT2", self, w, h)

	return false
end

---
-- @param string strName
-- @param string strArgs
-- @realm client
function PANEL:SetConsoleCommand(strName, strArgs)
	self.DoClick = function(slf, val)
		RunConsoleCommand(strName, strArgs)
	end
end

---
-- @ignore
function PANEL:SizeToContents()
	local w, h = self:GetContentSize()

	self:SetSize(w + 8, h + 4)
end

derma.DefineControl("DButtonTTT2_toggle", "A extended standard Button", PANEL, "DLabelTTT2")
