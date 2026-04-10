--- LibDBIcon-1.0
-- @class file
-- @name LibDBIcon-1.0.lua

local DBICON10 = "LibDBIcon-1.0"
local DBICON10_MINOR = 44
if not LibStub then error(DBICON10 .. " requires LibStub.") end
local ldb = LibStub("LibDataBroker-1.1", true)
if not ldb then error(DBICON10 .. " requires LibDataBroker-1.1.") end
local lib = LibStub:NewLibrary(DBICON10, DBICON10_MINOR)
if not lib then return end

lib.objects = lib.objects or {}
lib.callbackRegistered = lib.callbackRegistered or nil
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.notCreated = lib.notCreated or {}
lib.radius = lib.radius or 5
local Minimap, CreateFrame = Minimap, CreateFrame
lib.tooltip = lib.tooltip or CreateFrame("GameTooltip", "LibDBIconTooltip", UIParent, "GameTooltipTemplate")
local isDraggingButton = false

function lib:IconCallback(event, name, key, value)
	if lib.objects[name] then
		if key == "icon" then
			lib.objects[name].icon:SetTexture(value)
		elseif key == "iconCoords" then
			lib.objects[name].icon:UpdateCoord()
		elseif key == "iconR" then
			local _, g, b = lib.objects[name].icon:GetVertexColor()
			lib.objects[name].icon:SetVertexColor(value, g, b)
		elseif key == "iconG" then
			local r, _, b = lib.objects[name].icon:GetVertexColor()
			lib.objects[name].icon:SetVertexColor(r, value, b)
		elseif key == "iconB" then
			local r, g = lib.objects[name].icon:GetVertexColor()
			lib.objects[name].icon:SetVertexColor(r, g, value)
		end
	end
end
if not lib.callbackRegistered then
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__icon", "IconCallback")
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__iconCoords", "IconCallback")
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__iconR", "IconCallback")
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__iconG", "IconCallback")
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__iconB", "IconCallback")
	lib.callbackRegistered = true
end

local function getAnchors(frame, ...)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function onEnter(...)
	if isDraggingButton then return end
	local self = this
	local obj = self.dataObject
	if obj.OnTooltipShow then
		lib.tooltip:SetOwner(self, "ANCHOR_NONE")
		lib.tooltip:SetPoint(getAnchors(self))
		obj.OnTooltipShow(lib.tooltip)
		lib.tooltip:Show()
	elseif obj.OnEnter then
		obj.OnEnter(self)
	end
end

local function onLeave(...)
	lib.tooltip:Hide()
	local self = this
	local obj = self.dataObject
	if obj.OnLeave then
		obj.OnLeave(self)
	end
end

local onDragStart, updatePosition
do
	local minimapShapes = {
		["ROUND"] = {true, true, true, true},
		["SQUARE"] = {false, false, false, false},
	}

	local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min
	function updatePosition(button, position)
		local angle = rad(position or 225)
		local x, y, q = cos(angle), sin(angle), 1
		if x < 0 then q = q + 1 end
		if y > 0 then q = q + 2 end
		local minimapShape = "ROUND" -- General vanilla
		local quadTable = minimapShapes[minimapShape] or minimapShapes["ROUND"]
		local w = (Minimap:GetWidth() / 2) + lib.radius
		local h = (Minimap:GetHeight() / 2) + lib.radius
		if quadTable[q] then
			x, y = x*w, y*h
		else
			local diagRadiusW = sqrt(2*(w)^2)-10
			local diagRadiusH = sqrt(2*(h)^2)-10
			x = max(-w, min(x*diagRadiusW, w))
			y = max(-h, min(y*diagRadiusH, h))
		end
		button:SetPoint("CENTER", Minimap, "CENTER", x, y)
	end
end

local function onClick(...)
	local self = this
	local buttonName = arg1 -- En WoW 1.12, el botón (LeftButton/RightButton) está en arg1
	if self.dataObject.OnClick then
		self.dataObject.OnClick(self, buttonName)
	end
end

local function onMouseDown(...)
	local self = this
	self.isMouseDown = true
	self.icon:UpdateCoord()
end

local function onMouseUp(...)
	local self = this
	self.isMouseDown = false
	self.icon:UpdateCoord()
end

do
	local deg, atan2 = math.deg, math.atan2
	local function onUpdate(...)
		local mx, my = Minimap:GetCenter()
		local px, py = GetCursorPosition()
		local scale = Minimap:GetEffectiveScale()
		px, py = px / scale, py / scale
		local pos = math.mod(deg(atan2(py - my, px - mx)), 360)
		if this.db then
			this.db.minimapPos = pos
		else
			this.minimapPos = pos
		end
		updatePosition(this, pos)
	end

	function onDragStart(...)
		this:LockHighlight()
		this.isMouseDown = true
		this.icon:UpdateCoord()
		this:SetScript("OnUpdate", onUpdate)
		isDraggingButton = true
		lib.tooltip:Hide()
	end
end

local function onDragStop(...)
	this:SetScript("OnUpdate", nil)
	this.isMouseDown = false
	this.icon:UpdateCoord()
	this:UnlockHighlight()
	isDraggingButton = false
end

local defaultCoords = {0, 1, 0, 1}
local function updateCoord(self, ...)
	local parent = self:GetParent()
	local coords = parent.dataObject.iconCoords or defaultCoords
	local deltaX, deltaY = 0, 0
	if not parent.isMouseDown then
		deltaX = (coords[2] - coords[1]) * 0.05
		deltaY = (coords[4] - coords[3]) * 0.05
	end
	self:SetTexCoord(coords[1] + deltaX, coords[2] - deltaX, coords[3] + deltaY, coords[4] - deltaY)
end

function lib:CreateButton(name, object, db)
	local button = CreateFrame("Button", "LibDBIcon10_"..name, Minimap)
	button.dataObject = object
	button.db = db
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:SetWidth(31)
	button:SetHeight(31)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	
	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetWidth(53)
	overlay:SetHeight(53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT", 0, 0)
	
	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetWidth(20)
	background:SetHeight(20)
	background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	background:SetPoint("TOPLEFT", 7, -5)
	
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetWidth(17)
	icon:SetHeight(17)
	icon:SetTexture(object.icon)
	icon:SetPoint("TOPLEFT", 7, -6)
	button.icon = icon
	button.isMouseDown = false

	icon.UpdateCoord = updateCoord
	icon:UpdateCoord()

	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)
	button:SetScript("OnClick", onClick)
	if not db or not db.lock then
		button:SetScript("OnDragStart", onDragStart)
		button:SetScript("OnDragStop", onDragStop)
	end
	button:SetScript("OnMouseDown", onMouseDown)
	button:SetScript("OnMouseUp", onMouseUp)

	lib.objects[name] = button

	if lib.loggedIn then
		updatePosition(button, db and db.minimapPos)
		if not db or not db.hide then
			button:Show()
		else
			button:Hide()
		end
	end
	lib.callbacks:Fire("LibDBIcon_IconCreated", button, name)
end

local function check(name, ...)
	if lib.notCreated[name] then
		lib:CreateButton(name, lib.notCreated[name][1], lib.notCreated[name][2])
		lib.notCreated[name] = nil
	end
end

if not lib.loggedIn then
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function(...)
		for _, button in pairs(lib.objects) do
			updatePosition(button, button.db and button.db.minimapPos)
			if not button.db or not button.db.hide then
				button:Show()
			else
				button:Hide()
			end
		end
		lib.loggedIn = true
	end)
	f:RegisterEvent("PLAYER_LOGIN")
end

function lib:Register(name, object, db)
	if not object.icon then error("Can't register LDB objects without icons set!") end
	if lib.objects[name] or lib.notCreated[name] then error(DBICON10.. ": Object '".. name .."' is already registered.") end
	if not db or not db.hide then
		lib:CreateButton(name, object, db)
	else
		lib.notCreated[name] = {object, db}
	end
end

function lib:Hide(name, ...)
	if not lib.objects[name] then return end
	lib.objects[name]:Hide()
end

function lib:Show(name, ...)
	check(name)
	local button = lib.objects[name]
	if button then
		button:Show()
		updatePosition(button, button.db and button.db.minimapPos or button.minimapPos)
	end
end

function lib:IsRegistered(name, ...)
	return (lib.objects[name] or lib.notCreated[name]) and true or false
end

function lib:Lock(name, ...)
	if not lib.objects[name] then return end
	lib.objects[name]:SetScript("OnDragStart", nil)
	lib.objects[name]:SetScript("OnDragStop", nil)
end

function lib:Unlock(name, ...)
	if not lib.objects[name] then return end
	lib.objects[name]:SetScript("OnDragStart", onDragStart)
	lib.objects[name]:SetScript("OnDragStop", onDragStop)
end

function lib:Refresh(name, db, ...)
	if not lib.objects[name] then return end
	if db then
		lib.objects[name].db = db
	end
	
	local button = lib.objects[name]
	if button.db.hide then
		button:Hide()
	else
		button:Show()
		updatePosition(button, button.db.minimapPos)
	end
end
