--[[-----------------------------------------------------------------------------
SimpleGroup Container
Simple container widget that just groups widgets.
-------------------------------------------------------------------------------]]
local Type, Version = "SimpleGroup", 99

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
		self:SetWidth(300)
		self:SetHeight(100)
	end,

	-- ["OnRelease"] = nil,

	["LayoutFinished"] = function(self, width, height)
		if self.noAutoHeight then return end
		self:SetHeight(height or 0)
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		content:SetWidth(width)
		content.width = width
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		content:SetHeight(height)
		content.height = height
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor(...)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")

	--Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT")
	content:SetPoint("BOTTOMRIGHT")

	local widget = {
		frame     = frame,
		content   = content,
		type      = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AceGUI:|r Registrando " .. Type)
DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AceGUI:|r Registrando " .. Type)
AceGUI:RegisterWidgetType(Type, Constructor, Version)
