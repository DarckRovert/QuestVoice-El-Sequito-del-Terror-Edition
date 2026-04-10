--[[-----------------------------------------------------------------------------
Button Widget
Graphical Button.
-------------------------------------------------------------------------------]]
local Type, Version = "Button", 99

local AceGUI = _G.QuestVoice_AceGUI
if not AceGUI or not AceGUI.RegisterWidgetType then return end

-- Lua APIs
local select = AceGUI.select
local wipe = AceGUI.wipe
local pairs = pairs

-- WoW APIs
local _G = _G
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnClick(...)
	local frame = this
	AceGUI:ClearFocus()
	PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
	frame.obj:Fire("OnClick", unpack(arg))
end

local function Control_OnEnter(...)
	local frame = this
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(...)
	local frame = this
	frame.obj:Fire("OnLeave")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self, ...)
		-- restore default values
		self:SetHeight(24)
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetAutoWidth(false)
		self:SetText()
	end,

	-- ["OnRelease"] = nil,

	["SetText"] = function(self, text)
		self.text:SetText(text)
		if self.autoWidth then
			self:SetWidth(self.text:GetStringWidth() + 30)
		end
	end,

	["SetAutoWidth"] = function(self, autoWidth)
		self.autoWidth = autoWidth
		if self.autoWidth then
			self:SetWidth(self.text:GetStringWidth() + 30)
		end
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
		else
			self.frame:Enable()
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor(...)
	local name = "AceGUI30Button" .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Button", name, UIParent, "UIPanelButtonTemplate")
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnClick", Button_OnClick)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)

	local text = frame:GetFontString()
	text:ClearAllPoints()
	text:SetPoint("TOPLEFT", 15, -1)
	text:SetPoint("BOTTOMRIGHT", -15, 1)
	text:SetJustifyV("MIDDLE")

	local widget = {
		text  = text,
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
