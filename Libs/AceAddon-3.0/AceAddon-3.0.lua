--- **AceAddon-3.0** proporciona una plantilla para crear objetos addon.
-- @class file
-- @name AceAddon-3.0.lua
-- @release $Id: AceAddon-3.0.lua 1284 2022-09-25 09:15:30Z nevcairiel $

local MAJOR, MINOR = "AceAddon-3.0", 13
local AceAddon, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceAddon then return end -- No Upgrade needed.

AceAddon.frame = AceAddon.frame or CreateFrame("Frame", "AceAddon30Frame") -- Our very own frame
AceAddon.addons = AceAddon.addons or {} -- addons in general
AceAddon.statuses = AceAddon.statuses or {} -- statuses of addon.
AceAddon.initializequeue = AceAddon.initializequeue or {} -- addons that are new and not initialized
AceAddon.enablequeue = AceAddon.enablequeue or {} -- addons that are initialized and waiting to be enabled
AceAddon.embeds = AceAddon.embeds or setmetatable({}, {__index = function(tbl, key) tbl[key] = {} return tbl[key] end }) -- contains a list of libraries embedded in an addon

-- Lua APIs
local tinsert, tconcat, tremove = table.insert, table.concat, table.remove
local fmt, tostring = string.format, tostring
local pairs, next, type, unpack = pairs, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget

-- WoW 1.12 / Lua 5.0 polyfill for select
local function select(index, ...)
	if index == "table.getn(" then
		return arg.n
	end
	local res = {}
	for i = index, arg.n do
		table.insert(res, arg[i])
	end
	return unpack(res)
end

--[[
	 xpcall safecall implementation for Lua 5.0
]]
local xpcall = xpcall

local function errorhandler(err, ...)
	if geterrorhandler then
		return geterrorhandler()(err)
	end
	return err
end

local function safecall(func, ...)
	if type(func) == "function" then
		local args = arg
		local success, ret = xpcall(function(...) return func(unpack(args)) end, errorhandler)
		if success then
			return ret
		end
	end
end

-- local functions that will be implemented further down
local Enable, Disable, EnableModule, DisableModule, Embed, NewModule, GetModule, GetName, SetDefaultModuleState, SetDefaultModuleLibraries, SetEnabledState, SetDefaultModulePrototype

-- used in the addon metatable
local function addontostring( self , ...) return self.name end

-- Check if the addon is queued for initialization
local function queuedForInitialization(addon, ...)
	local queueCount = table.getn(AceAddon.initializequeue)
	for i = 1, queueCount do
		if AceAddon.initializequeue[i] == addon then
			return true
		end
	end
	return false
end

--- Create a new AceAddon-3.0 addon.
function AceAddon:NewAddon(objectorname, ...)
	local object,name
	local i=1
	if type(objectorname)=="table" then
		object=objectorname
		name=arg[1]
		i=2
	else
		name=objectorname
	end
	if type(name)~="string" then
		error(("Usage: NewAddon([object,] name, [lib, lib, lib, ...]): 'name' - string expected got '%s'."):format(type(name)), 2)
	end
	if self.addons[name] then
		error(("Usage: NewAddon([object,] name, [lib, lib, lib, ...]): 'name' - Addon '%s' already exists."):format(name), 2)
	end

	object = object or {}
	object.name = name

	local addonmeta = {}
	local oldmeta = getmetatable(object)
	if oldmeta then
		for k, v in pairs(oldmeta) do addonmeta[k] = v end
	end
	addonmeta.__tostring = addontostring

	setmetatable( object, addonmeta )
	self.addons[name] = object
	object.modules = {}
	object.orderedModules = {}
	object.defaultModuleLibraries = {}
	Embed( object ) -- embed NewModule, GetModule methods
	
	local embeds = {}
	for j = i, arg.n do
		table.insert(embeds, arg[j])
	end
	self:EmbedLibraries(object, unpack(embeds))

	-- add to queue of addons to be initialized upon ADDON_LOADED
	tinsert(self.initializequeue, object)
	return object
end


--- Get the addon object by its name from the internal AceAddon registry.
function AceAddon:GetAddon(name, silent)
	if not silent and not self.addons[name] then
		error(("Usage: GetAddon(name): 'name' - Cannot find an AceAddon '%s'."):format(tostring(name)), 2)
	end
	return self.addons[name]
end

function AceAddon:EmbedLibraries(addon, ...)
	local args = arg
	for i=1, args.n do
		local libname = args[i]
		self:EmbedLibrary(addon, libname, false, 4)
	end
end

function AceAddon:EmbedLibrary(addon, libname, silent, offset)
	local lib = LibStub:GetLibrary(libname, true)
	if not lib and not silent then
		error(("Usage: EmbedLibrary(addon, libname, silent, offset): 'libname' - Cannot find a library instance of%q."):format(tostring(libname)), offset or 2)
	elseif lib and type(lib.Embed) == "function" then
		lib:Embed(addon)
		tinsert(self.embeds[addon], libname)
		return true
	elseif lib then
		error(("Usage: EmbedLibrary(addon, libname, silent, offset): 'libname' - Library '%s' is not Embed capable"):format(libname), offset or 2)
	end
end

function GetModule(self, name, silent)
	if not self.modules[name] and not silent then
		error(("Usage: GetModule(name, silent): 'name' - Cannot find module '%s'."):format(tostring(name)), 2)
	end
	return self.modules[name]
end

local function IsModuleTrue(self, ...) return true end

--- Create a new module for the addon.
function NewModule(self, name, prototype, ...)
	if type(name) ~= "string" then error(("Usage: NewModule(name, [prototype, [lib, lib, lib, ...]): 'name' - string expected got '%s'."):format(type(name)), 2) end
	if type(prototype) ~= "string" and type(prototype) ~= "table" and type(prototype) ~= "nil" then error(("Usage: NewModule(name, [prototype, [lib, lib, lib, ...]): 'prototype' - table (prototype), string (lib) or nil expected got '%s'."):format(type(prototype)), 2) end

	if self.modules[name] then error(("Usage: NewModule(name, [prototype, [lib, lib, lib, ...]): 'name' - Module '%s' already exists."):format(name), 2) end

	local module = AceAddon:NewAddon(fmt("%s_%s", self.name or tostring(self), name))

	module.IsModule = IsModuleTrue
	module:SetEnabledState(self.defaultModuleState)
	module.moduleName = name

	if type(prototype) == "string" then
		AceAddon:EmbedLibraries(module, prototype, unpack(arg))
	else
		AceAddon:EmbedLibraries(module, unpack(arg))
	end
	AceAddon:EmbedLibraries(module, unpack(self.defaultModuleLibraries))

	if not prototype or type(prototype) == "string" then
		prototype = self.defaultModulePrototype or nil
	end

	if type(prototype) == "table" then
		local mt = getmetatable(module)
		mt.__index = prototype
		setmetatable(module, mt)
	end

	safecall(self.OnModuleCreated, self, module)
	self.modules[name] = module
	tinsert(self.orderedModules, module)

	return module
end

function GetName(self, ...)
	return self.moduleName or self.name
end

function Enable(self, ...)
	self:SetEnabledState(true)
	if not queuedForInitialization(self) then
		return AceAddon:EnableAddon(self)
	end
end

function Disable(self, ...)
	self:SetEnabledState(false)
	return AceAddon:DisableAddon(self)
end

function EnableModule(self, name)
	local module = self:GetModule( name )
	return module:Enable()
end

function DisableModule(self, name)
	local module = self:GetModule( name )
	return module:Disable()
end

function SetDefaultModuleLibraries(self, ...)
	if next(self.modules) then
		error("Usage: SetDefaultModuleLibraries(unpack(arg)): cannot change the module defaults after a module has been registered.", 2)
	end
	local libs = {}
	for i = 1, arg.n do
		table.insert(libs, arg[i])
	end
	self.defaultModuleLibraries = libs
end

function SetDefaultModuleState(self, state)
	if next(self.modules) then
		error("Usage: SetDefaultModuleState(state): cannot change the module defaults after a module has been registered.", 2)
	end
	self.defaultModuleState = state
end

function SetDefaultModulePrototype(self, prototype)
	if next(self.modules) then
		error("Usage: SetDefaultModulePrototype(prototype): cannot change the module defaults after a module has been registered.", 2)
	end
	if type(prototype) ~= "table" then
		error(("Usage: SetDefaultModulePrototype(prototype): 'prototype' - table expected got '%s'."):format(type(prototype)), 2)
	end
	self.defaultModulePrototype = prototype
end

function SetEnabledState(self, state)
	self.enabledState = state
end

local function IterateModules(self, ...) return pairs(self.modules) end
local function IterateEmbeds(self, ...) return pairs(AceAddon.embeds[self]) end
local function IsEnabled(self, ...) return self.enabledState end

local mixins = {
	NewModule = NewModule,
	GetModule = GetModule,
	Enable = Enable,
	Disable = Disable,
	EnableModule = EnableModule,
	DisableModule = DisableModule,
	IsEnabled = IsEnabled,
	SetDefaultModuleLibraries = SetDefaultModuleLibraries,
	SetDefaultModuleState = SetDefaultModuleState,
	SetDefaultModulePrototype = SetDefaultModulePrototype,
	SetEnabledState = SetEnabledState,
	IterateModules = IterateModules,
	IterateEmbeds = IterateEmbeds,
	GetName = GetName,
}
local function IsModule(self, ...) return false end
local pmixins = {
	defaultModuleState = true,
	enabledState = true,
	IsModule = IsModule,
}

function Embed(target, skipPMixins)
	for k, v in pairs(mixins) do
		target[k] = v
	end
	if not skipPMixins then
		for k, v in pairs(pmixins) do
			target[k] = target[k] or v
		end
	end
end

function AceAddon:InitializeAddon(addon, ...)
	safecall(addon.OnInitialize, addon)

	local embeds = self.embeds[addon]
	local count = table.getn(embeds)
	for i = 1, count do
		local lib = LibStub:GetLibrary(embeds[i], true)
		if lib then safecall(lib.OnEmbedInitialize, lib, addon) end
	end
end

function AceAddon:EnableAddon(addon, ...)
	if type(addon) == "string" then addon = AceAddon:GetAddon(addon) end
	if self.statuses[addon.name] or not addon.enabledState then return false end

	self.statuses[addon.name] = true

	safecall(addon.OnEnable, addon)

	if self.statuses[addon.name] then
		local embeds = self.embeds[addon]
		local ecount = table.getn(embeds)
		for i = 1, ecount do
			local lib = LibStub:GetLibrary(embeds[i], true)
			if lib then safecall(lib.OnEmbedEnable, lib, addon) end
		end

		local modules = addon.orderedModules
		local mcount = table.getn(modules)
		for i = 1, mcount do
			self:EnableAddon(modules[i])
		end
	end
	return self.statuses[addon.name]
end

function AceAddon:DisableAddon(addon, ...)
	if type(addon) == "string" then addon = AceAddon:GetAddon(addon) end
	if not self.statuses[addon.name] then return false end

	self.statuses[addon.name] = false

	safecall( addon.OnDisable, addon )

	if not self.statuses[addon.name] then
		local embeds = self.embeds[addon]
		local ecount = table.getn(embeds)
		for i = 1, ecount do
			local lib = LibStub:GetLibrary(embeds[i], true)
			if lib then safecall(lib.OnEmbedDisable, lib, addon) end
		end
		local modules = addon.orderedModules
		local mcount = table.getn(modules)
		for i = 1, mcount do
			self:DisableAddon(modules[i])
		end
	end

	return not self.statuses[addon.name]
end

function AceAddon:IterateAddons(...) return pairs(self.addons) end
function AceAddon:IterateAddonStatus(...) return pairs(self.statuses) end
function AceAddon:IterateEmbedsOnAddon(addon, ...) return pairs(self.embeds[addon]) end
function AceAddon:IterateModulesOfAddon(addon, ...) return pairs(addon.modules) end

local BlizzardEarlyLoadAddons = {
	Blizzard_DebugTools = true,
	Blizzard_TimeManager = true,
	Blizzard_BattlefieldMap = true,
	Blizzard_MapCanvas = true,
	Blizzard_SharedMapDataProviders = true,
	Blizzard_CombatLog = true,
}

local function onEvent(...)
	if (event == "ADDON_LOADED"  and (arg1 == nil or not BlizzardEarlyLoadAddons[arg1])) or event == "PLAYER_LOGIN" then
		while(table.getn(AceAddon.initializequeue) > 0) do
			local addon = tremove(AceAddon.initializequeue, 1)
			if event == "ADDON_LOADED" then addon.baseName = arg1 end
			AceAddon:InitializeAddon(addon)
			tinsert(AceAddon.enablequeue, addon)
		end

		if IsLoggedIn() then
			while(table.getn(AceAddon.enablequeue) > 0) do
				local addon = tremove(AceAddon.enablequeue, 1)
				AceAddon:EnableAddon(addon)
			end
		end
	end
end

AceAddon.frame:RegisterEvent("ADDON_LOADED")
AceAddon.frame:RegisterEvent("PLAYER_LOGIN")
AceAddon.frame:SetScript("OnEvent", onEvent)

for name, addon in pairs(AceAddon.addons) do
	Embed(addon, true)
end

if oldminor and oldminor < 10 then
	for name, addon in pairs(AceAddon.addons) do
		addon.orderedModules = {}
		for module_name, module in pairs(addon.modules) do
			tinsert(addon.orderedModules, module)
		end
	end
end
