--[[-----------------------------------------------------------------------------
Heading Widget
-------------------------------------------------------------------------------]]
local Type, Version = "Heading", 99

local AceGUI = _G.QuestVoice_AceGUI
if not AceGUI or not AceGUI.RegisterWidgetType then return end

-- Lua APIs
local select = AceGUI.select
local wipe = AceGUI.wipe
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self, ...)
		self:SetText()
		self:SetFullWidth()
		self:SetHeight(18)
	end,

	-- ["OnRelease"] = nil,

	["SetText"] = function(self, text)
		self.label:SetText(text or "")
		if text and text ~= "" then
			self.left:SetPoint("RIGHT", self.label, "LEFT", -5, 0)
			self.right:Show()
		else
			self.left:SetPoint("RIGHT", -3, 0)
			self.right:Hide()
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor(...)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("TOP")
	label:SetPoint("BOTTOM")
	label:SetJustifyH("CENTER")

	local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetHeight(8)
	left:SetPoint("LEFT", 3, 0)
	left:SetPoint("RIGHT", label, "LEFT", -5, 0)
	left:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	left:SetTexCoord(0.81, 0.94, 0.5, 1)

	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetHeight(8)
	right:SetPoint("RIGHT", -3, 0)
	right:SetPoint("LEFT", label, "RIGHT", 5, 0)
	right:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	right:SetTexCoord(0.81, 0.94, 0.5, 1)

	local widget = {
		label = label,
		left  = left,
		right = right,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AceGUI:|r Registrando " .. Type)
DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AceGUI:|r Registrando " .. Type)
AceGUI:RegisterWidgetType(Type, Constructor, Version)
