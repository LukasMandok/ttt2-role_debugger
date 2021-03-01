local PANEL = {}
--setmetatable({}, PANEL_EXTENSION)

--local BaseClass = baseclass.Get( "DFormTTT2" )

local materialReset = Material("vgui/ttt/vskin/icon_reset")

-- Unnötig zu überschreiben, geht aber nicht anders.
local function MakeReset(parent)
	local reset = vgui.Create("DButtonTTT2", parent)

	reset:SetText("button_default")
	reset:SetSize(32, 32)

	reset.Paint = function(slf, w, h)
		derma.SkinHook("Paint", "FormButtonIconTTT2", slf, w, h)

		return true
	end

	reset.material = materialReset

	return reset
end

--
-- Adds a combobox to the form with support for different data and values
-- @param table data The data for the combobox
-- @return Panel The created combobox
-- @return Panel The created label
-- @realm client
function PANEL:MakeComboBox(data)
	local left = vgui.Create("DLabelTTT2", self)

	left:SetText(data.label)

	left.Paint = function(slf, w, h)
		derma.SkinHook("Paint", "FormLabelTTT2", slf, w, h)

		return true
	end

	local right = vgui.Create("DComboBoxTTT2", self)

	data.data = data.data or data.choices

	if data.choices then
		for i = 1, #data.choices do
			right:AddChoice(data.choices[i], data.data[i])
		end
	end

	if data.selectId then
		right:ChooseOptionId(data.selectId)
	elseif data.selectName then
		right:ChooseOptionName(data.selectName)
	end

	right.OnSelect = function(slf, index, value, rawdata)
		if slf.m_strConVar then
			RunConsoleCommand(slf.m_strConVar, tostring(rawdata or value))
		end

		-- run the callback function in the next frame since it takes
		-- one frame to update the convar if one is set.
		timer.Simple(0, function()
			if data and isfunction(data.OnChange) then
				data.OnChange(slf, index, value, rawdata)
			end
		end)
	end

	right:SetConVar(data.convar)
	right:SetTall(32)
	right:Dock(TOP)

	local reset = MakeReset(self)

	if ConVarExists(data.convar or "") or data.default ~= nil then
		reset.DoClick = function(slf)
			local default = data.default
			if default == nil then
				default = GetConVar(data.convar):GetDefault()
			end

			right:ChooseOptionName(default)
		end
	else
		reset.noDefault = true
	end

	self:AddItem(left, right, reset)

	if IsValid(data.master) and isfunction(data.master.AddSlave) then
		data.master:AddSlave(left)
		data.master:AddSlave(right)
		data.master:AddSlave(reset)
	end

	return right, left
end

-- Size ist in AddItem Function!!!!

---
-- Adds a slider to the form with an Button inclusive
-- @param table data The data for the slider
-- @return Panel The created slider
-- @realm client
function PANEL:MakeButtonSlider(data)
	local left = vgui.Create("DButtonTTT2", self)

	left:SetText(data.label)

	--left.Paint = function(slf, w, h)
	--	derma.SkinHook("Paint", "ButtonTTT2", self, w, h)
	--	print("############################# Painting Button")
	--	return false
	--end

	--function PANEL:Paint(w, h)
	--	derma.SkinHook("Paint", "ButtonTTT2", self, w, h)
	--	return false
	--end

	left.DoClick = function(slf) 
		if isfunction(data.OnClick) then
			data.OnClick(slf)
		end
	end


	local right = vgui.Create("DNumSliderTTT2", self)

	right:SetMinMax(data.min, data.max)

	if data.decimal ~= nil then
		right:SetDecimals(data.decimal)
	end

	right:SetConVar(data.convar)
	right:SizeToContents()

	right:SetValue(data.initial)

	right.OnValueChanged = function(slf, value)
		if isfunction(data.OnChange) then
			data.OnChange(slf, value)
		end
	end

	right:SetTall(32)
	right:Dock(TOP)

	local reset = MakeReset(self)

	if ConVarExists(data.convar or "") or data.default ~= nil then
		reset.DoClick = function(slf)
			local default = data.default
			if default == nil then
				default = tonumber(GetConVar(data.convar):GetDefault())
			end

			right:SetValue(default)
		end
	else
		reset.noDefault = true
	end

	self:AddItem(left, right, reset)

	if IsValid(data.master) and isfunction(data.master.AddSlave) then
		data.master:AddSlave(left)
		data.master:AddSlave(right)
		data.master:AddSlave(reset)
	end

	return left
end

derma.DefineControl("ExtensionTTT2", "Extension to DForms_TTT2", PANEL, "Panel")