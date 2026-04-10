--- AceGUI-3.0 — Instancia privada QuestVoice (Lua 5.0 / WoW 1.12)
-- Motor completo compatible con todos los widgets Ace3 que usa este addon.
local ACEGUI_MAJOR, ACEGUI_MINOR = "AceGUI-3.0", 99
local AceGUI = _G.QuestVoice_AceGUI or {}
_G.QuestVoice_AceGUI = AceGUI

-- Lua 5.0 APIs
local tinsert, tremove, getn = table.insert, table.remove, table.getn
local pairs, next, type = pairs, next, type
local error, assert = error, assert
local setmetatable, rawget, rawset = setmetatable, rawget, rawset
local math_max, math_min, math_ceil = math.max, math.min, math.ceil
local unpack = unpack
local tostring, tonumber = tostring, tonumber

-- Polyfills Lua 5.0
local function select(index, ...)
	if index == "#" then return arg.n end
	local res = {}
	for i = index, arg.n do tinsert(res, arg[i]) end
	return unpack(res)
end
local function wipe(t) for k in pairs(t) do t[k] = nil end return t end

-- Exponer para widgets hijos que los necesiten como upvalue
AceGUI.select = select
AceGUI.wipe   = wipe

-- WoW APIs
local UIParent    = UIParent
local CreateFrame = CreateFrame

-- ============================================================
-- Registros internos
-- ============================================================
AceGUI.WidgetRegistry  = AceGUI.WidgetRegistry  or {}
AceGUI.LayoutRegistry  = AceGUI.LayoutRegistry   or {}
AceGUI.WidgetVersions  = AceGUI.WidgetVersions   or {}
AceGUI.tooltip         = AceGUI.tooltip or CreateFrame("GameTooltip", "AceGUITooltip", UIParent, "GameTooltipTemplate")

-- Piscinas de reciclaje por tipo de widget
local widgetPools = {}

-- ============================================================
-- Registro de tipos y layouts
-- ============================================================
function AceGUI:RegisterWidgetType(Name, Constructor, Version)
	local oldVersion = self.WidgetVersions[Name]
	if oldVersion and oldVersion >= Version then return end
	self.WidgetVersions[Name] = Version
	self.WidgetRegistry[Name]  = Constructor
	-- Limpiar pool al actualizar versión
	widgetPools[Name] = nil
end

function AceGUI:RegisterLayout(Name, LayoutFunc)
	self.LayoutRegistry[string.upper(Name)] = LayoutFunc
end

-- ============================================================
-- Motor de eventos (Fire / callbacks) por widget
-- ============================================================
local function FireEvent(widget, event, ...)
	local handler = widget.events and widget.events[event]
	if handler then
		handler(widget, event, unpack(arg))
	end
end

-- Mixin de eventos que se agrega a cada widget
local eventMixin = {}
function eventMixin:SetCallback(event, func)
	if not self.events then self.events = {} end
	self.events[event] = func
end
function eventMixin:Fire(event, ...)
	FireEvent(self, event, unpack(arg))
end

-- ============================================================
-- UserData
-- ============================================================
local userDataMixin = {}
function userDataMixin:GetUserDataTable()
	if not self.userdata then self.userdata = {} end
	return self.userdata
end
function userDataMixin:GetUserData(key)
	return self.userdata and self.userdata[key]
end
function userDataMixin:SetUserData(key, val)
	if not self.userdata then self.userdata = {} end
	self.userdata[key] = val
end

-- ============================================================
-- Mixins de contenedor (children, layout)
-- ============================================================
local containerMixin = {}
function containerMixin:AddChild(widget, ...)
	if not self.children then self.children = {} end
	tinsert(self.children, widget)
	widget:SetParent(self)
	self:DoLayout()
end
function containerMixin:ReleaseChildren()
	if not self.children then return end
	for i = getn(self.children), 1, -1 do
		self.children[i]:Release()
		self.children[i] = nil
	end
end
function containerMixin:SetLayout(layoutName)
	self.layout = string.upper(layoutName or "List")
end
function containerMixin:DoLayout()
	local layout = self.layout and AceGUI.LayoutRegistry[self.layout]
	if layout and self.content then
		layout(self.content, self.children or {})
	end
end
function containerMixin:SetParent(parent)
	if parent and parent.content then
		self.frame:SetParent(parent.content)
	elseif type(parent) == "table" and parent.frame then
		self.frame:SetParent(parent.frame)
	end
end
function containerMixin:SetWidth(width)
	self.frame:SetWidth(width)
	if self.OnWidthSet then self:OnWidthSet(width) end
end
function containerMixin:SetHeight(height)
	self.frame:SetHeight(height)
	if self.OnHeightSet then self:OnHeightSet(height) end
end
function containerMixin:IsShown()
	return self.frame and self.frame:IsShown()
end
function containerMixin:Show()
	if self.frame then self.frame:Show() end
end
function containerMixin:Hide()
	if self.frame then self.frame:Hide() end
end

-- ============================================================
-- Mixins de widget simple
-- ============================================================
local widgetMixin = {}
function widgetMixin:SetParent(parent)
	if parent and parent.content then
		self.frame:SetParent(parent.content)
	elseif type(parent) == "table" and parent.frame then
		self.frame:SetParent(parent.frame)
	end
end
function widgetMixin:SetWidth(w)
	self.frame:SetWidth(w)
	if self.OnWidthSet then self:OnWidthSet(w) end
end
function widgetMixin:SetHeight(h)
	self.frame:SetHeight(h)
	if self.OnHeightSet then self:OnHeightSet(h) end
end
function widgetMixin:SetPoint(...)
	self.frame:SetPoint(unpack(arg))
end
function widgetMixin:IsShown()
	return self.frame and self.frame:IsShown()
end
function widgetMixin:Show()
	if self.frame then self.frame:Show() end
end
function widgetMixin:Hide()
	if self.frame then self.frame:Hide() end
end
function widgetMixin:Release()
	AceGUI:Release(self)
end

-- ============================================================
-- Aplicar todos los mixins a un objeto widget
-- ============================================================
local function applyMixins(widget, mixinList)
	for k, v in pairs(mixinList) do
		if not widget[k] then widget[k] = v end
	end
end

-- ============================================================
-- RegisterAsContainer / RegisterAsWidget
-- ============================================================
function AceGUI:RegisterAsContainer(widget)
	applyMixins(widget, eventMixin)
	applyMixins(widget, userDataMixin)
	applyMixins(widget, containerMixin)
	widget.children = widget.children or {}
	widget.layout   = widget.layout   or "List"
	if widget.OnAcquire then widget:OnAcquire() end
	return widget
end

function AceGUI:RegisterAsWidget(widget)
	applyMixins(widget, eventMixin)
	applyMixins(widget, userDataMixin)
	applyMixins(widget, widgetMixin)
	if widget.OnAcquire then widget:OnAcquire() end
	return widget
end

-- ============================================================
-- Create / Release
-- ============================================================
function AceGUI:Create(Name)
	local Constructor = self.WidgetRegistry[Name]
	if not Constructor then
		DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff0000AceGUI:|r '%s' NO está registrado en la instancia de AceGUI.", Name))
		return nil
	end
	local widget = Constructor()
	return widget
end

function AceGUI:Release(widget)
	if widget.OnRelease then widget:OnRelease() end
	if widget.ReleaseChildren then widget:ReleaseChildren() end
	if widget.frame then
		widget.frame:ClearAllPoints()
		widget.frame:Hide()
		widget.frame:SetParent(UIParent)
	end
	wipe(widget.userdata or {})
	wipe(widget.events   or {})
end

-- ============================================================
-- ClearFocus (requerido por Frame widget)
-- ============================================================
function AceGUI:ClearFocus()
	-- placeholder: en 1.12 no hay un focus global de Ace3
end

-- ============================================================
-- Layouts
-- ============================================================
AceGUI:RegisterLayout("List", function(content, children)
	local height = 0
	for i = 1, getn(children) do
		local child = children[i]
		child:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -height)
		child:SetPoint("RIGHT",   content, "RIGHT")
		height = height + (child.frame and child.frame:GetHeight() or 0)
	end
	content:SetHeight(height)
end)

AceGUI:RegisterLayout("Fill", function(content, children)
	if children[1] then
		children[1]:SetPoint("TOPLEFT",     content, "TOPLEFT")
		children[1]:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT")
	end
end)

AceGUI:RegisterLayout("Flow", function(content, children)
	local width   = content:GetWidth() or 0
	local height  = 0
	local rowH    = 0
	local rowX    = 0

	for i = 1, getn(children) do
		local child = children[i]
		local cw    = child.frame and child.frame:GetWidth()  or 0
		local ch    = child.frame and child.frame:GetHeight() or 0

		if rowX + cw > width and rowX > 0 then
			height = height + rowH
			rowX   = 0
			rowH   = 0
		end

		child:SetPoint("TOPLEFT", content, "TOPLEFT", rowX, -height)
		rowX  = rowX  + cw
		rowH  = math_max(rowH, ch)
	end
	height = height + rowH
	content:SetHeight(height)
end)

DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccQuestVoice AceGUI [Motor Completo]:|r Inicializado.")
