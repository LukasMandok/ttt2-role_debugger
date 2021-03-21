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

	--self:SetPaintBackgroundEnabled(false)
	--self:SetPaintBorderEnabled(false)

	self.text = ""

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

function PANEL:SetIntitial(bool)
	self:SetToggle(bool)
end


-- function PANEL:Toggle()
-- 	if not self:GetIsToggle() then return end

-- 	self:SetToggle(not self:GetToggle())
-- 	self:OnToggled(self:GetToggle())
-- end

-- Switches the state of the button to the given state,
-- but only if it has a different state at the moment
-- @param boolean state: the state the button should be switched into
function PANEL:OnToggled(state)
	if state == false then
		self:OnUnlocked()
		self.material = self.material_off
	elseif state == true then
		self:OnLocked()
		self.material = self.material_on
	else
		--print("Toggled but state did not change!")
	end
end

function PANEL:DoUnlock()
	if self:GetToggle() != false then
		--self:OnToggled(false)
		self:Toggle()
	end
end

function PANEL:DoLock()
	if self:GetToggle() != true then
		--self:OnToggled(true)
		self:Toggle()
	end
end


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
