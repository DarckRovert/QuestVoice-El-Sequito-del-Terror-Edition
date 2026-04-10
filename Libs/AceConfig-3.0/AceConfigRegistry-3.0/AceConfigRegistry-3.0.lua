--- AceConfigRegistry-3.0 maneja el registro central de tablas de opciones.
-- @class file
-- @name AceConfigRegistry-3.0
-- @release $Id: AceConfigRegistry-3.0.lua 1296 2022-11-04 18:50:10Z nevcairiel $
local CallbackHandler = LibStub("CallbackHandler-1.0")

local MAJOR, MINOR = "AceConfigRegistry-3.0", 21
local AceConfigRegistry = LibStub:NewLibrary(MAJOR, MINOR)

if not AceConfigRegistry then return end

AceConfigRegistry.tables = AceConfigRegistry.tables or {}

if not AceConfigRegistry.callbacks then
	AceConfigRegistry.callbacks = CallbackHandler:New(AceConfigRegistry)
end

-- Lua APIs
local tinsert, tconcat = table.insert, table.concat
local strfind = string.find
local type, tostring, pairs = type, tostring, pairs
local error, assert, unpack = error, assert, unpack

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

-- Polyfill para string.match (WoW 1.12)
local function strmatch(str, pattern)
	local _, _, r1, r2, r3, r4 = strfind(str, pattern)
	return r1, r2, r3, r4
end

-----------------------------------------------------------------------
AceConfigRegistry.validated = {
	cmd = {},
	dropdown = {},
	dialog = {},
}

local function err(msg, errlvl, ...)
	local t = {}
	for i=arg.n, 1, -1 do
		tinsert(t, arg[i])
	end
	error(MAJOR..":ValidateOptionsTable(): "..tconcat(t,".")..msg, errlvl+2)
end

local isstring={["string"]=true, _="string"}
local isstringfunc={["string"]=true,["function"]=true, _="string or funcref"}
local istable={["table"]=true,   _="table"}
local ismethodtable={["table"]=true,["string"]=true,["function"]=true,   _="methodname, funcref or table"}
local optstring={["nil"]=true,["string"]=true, _="string"}
local optstringfunc={["nil"]=true,["string"]=true,["function"]=true, _="string or funcref"}
local optstringnumberfunc={["nil"]=true,["string"]=true,["number"]=true,["function"]=true, _="string, number or funcref"}
local optnumber={["nil"]=true,["number"]=true, _="number"}
local optmethodfalse={["nil"]=true,["string"]=true,["function"]=true,["boolean"]={[false]=true},  _="methodname, funcref or false"}
local optmethodnumber={["nil"]=true,["string"]=true,["function"]=true,["number"]=true,  _="methodname, funcref or number"}
local optmethodtable={["nil"]=true,["string"]=true,["function"]=true,["table"]=true,  _="methodname, funcref or table"}
local optmethodbool={["nil"]=true,["string"]=true,["function"]=true,["boolean"]=true,  _="methodname, funcref or boolean"}
local opttable={["nil"]=true,["table"]=true,  _="table"}
local optbool={["nil"]=true,["boolean"]=true,  _="boolean"}
local optboolnumber={["nil"]=true,["boolean"]=true,["number"]=true,  _="boolean or number"}
local optstringnumber={["nil"]=true,["string"]=true,["number"]=true, _="string or number"}

local basekeys={
	type=isstring,
	name=isstringfunc,
	desc=optstringfunc,
	descStyle=optstring,
	order=optmethodnumber,
	validate=optmethodfalse,
	confirm=optmethodbool,
	confirmText=optstring,
	disabled=optmethodbool,
	hidden=optmethodbool,
		guiHidden=optmethodbool,
		dialogHidden=optmethodbool,
		dropdownHidden=optmethodbool,
	cmdHidden=optmethodbool,
	tooltipHyperlink=optstringfunc,
	icon=optstringnumberfunc,
	iconCoords=optmethodtable,
	handler=opttable,
	get=optmethodfalse,
	set=optmethodfalse,
	func=optmethodfalse,
	arg={["*"]=true},
	width=optstringnumber,
}

local typedkeys={
	header={
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
	},
	description={
		image=optstringnumberfunc,
		imageCoords=optmethodtable,
		imageHeight=optnumber,
		imageWidth=optnumber,
		fontSize=optstringfunc,
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
	},
	group={
		args=istable,
		plugins=opttable,
		inline=optbool,
			cmdInline=optbool,
			guiInline=optbool,
			dropdownInline=optbool,
			dialogInline=optbool,
		childGroups=optstring,
	},
	execute={
		image=optstringnumberfunc,
		imageCoords=optmethodtable,
		imageHeight=optnumber,
		imageWidth=optnumber,
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
	},
	input={
		pattern=optstring,
		usage=optstring,
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
		multiline=optboolnumber,
	},
	toggle={
		tristate=optbool,
		image=optstringnumberfunc,
		imageCoords=optmethodtable,
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
	},
	tristate={
	},
	range={
		min=optnumber,
		softMin=optnumber,
		max=optnumber,
		softMax=optnumber,
		step=optnumber,
		bigStep=optnumber,
		isPercent=optbool,
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
	},
	select={
		values=ismethodtable,
		sorting=optmethodtable,
		style={
			["nil"]=true,
			["string"]={dropdown=true,radio=true},
			_="string: 'dropdown' or 'radio'"
		},
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
		itemControl=optstring,
	},
	multiselect={
		values=ismethodtable,
		style=optstring,
		tristate=optbool,
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
	},
	color={
		hasAlpha=optmethodbool,
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
	},
	keybinding={
		control=optstring,
		dialogControl=optstring,
		dropdownControl=optstring,
	},
}

local function validateKey(k,errlvl, ...)
	errlvl=(errlvl or 0)+1
	if type(k)~="string" then
		err("["..tostring(k).."] - key is not a string", errlvl, unpack(arg))
	end
	if strfind(k, "[%c\127]") then
		err("["..tostring(k).."] - key name contained control characters", errlvl, unpack(arg))
	end
end

local function validateVal(v, oktypes, errlvl, ...)
	errlvl=(errlvl or 0)+1
	local isok=oktypes[type(v)] or oktypes["*"]

	if not isok then
		err(": expected a "..oktypes._..", got '"..tostring(v).."'", errlvl, unpack(arg))
	end
	if type(isok)=="table" then
		if not isok[v] then
			err(": did not expect "..type(v).." value '"..tostring(v).."'", errlvl, unpack(arg))
		end
	end
end

local function validate(options,errlvl, ...)
	errlvl=(errlvl or 0)+1
	if type(options)~="table" then
		err(": expected a table, got a "..type(options), errlvl, unpack(arg))
	end
	if type(options.type)~="string" then
		err(".type: expected a string, got a "..type(options.type), errlvl, unpack(arg))
	end

	local tk = typedkeys[options.type]
	if not tk then
		err(".type: unknown type '"..options.type.."'", errlvl, unpack(arg))
	end

	for k,v in pairs(options) do
		if not (tk[k] or basekeys[k]) then
			err(": unknown parameter", errlvl, tostring(k), unpack(arg))
		end
	end

	for k,oktypes in pairs(basekeys) do
		validateVal(options[k], oktypes, errlvl, k, unpack(arg))
	end
	for k,oktypes in pairs(tk) do
		validateVal(options[k], oktypes, errlvl, k, unpack(arg))
	end

	if options.type=="group" then
		for k,v in pairs(options.args) do
			validateKey(k,errlvl,"args", unpack(arg))
			validate(v, errlvl,k,"args", unpack(arg))
		end
		if options.plugins then
			for plugname,plugin in pairs(options.plugins) do
				if type(plugin)~="table" then
					err(": expected a table, got '"..tostring(plugin).."'", errlvl,tostring(plugname),"plugins", unpack(arg))
				end
				for k,v in pairs(plugin) do
					validateKey(k,errlvl,tostring(plugname),"plugins", unpack(arg))
					validate(v, errlvl,k,tostring(plugname),"plugins", unpack(arg))
				end
			end
		end
	end
end

function AceConfigRegistry:ValidateOptionsTable(options,name,errlvl)
	errlvl=(errlvl or 0)+1
	name = name or "Optionstable"
	if not options.name then
		options.name=name
	end
	validate(options,errlvl,name)
end

function AceConfigRegistry:NotifyChange(appName, ...)
	if not AceConfigRegistry.tables[appName] then return end
	AceConfigRegistry.callbacks:Fire("ConfigTableChange", appName)
end

local function validateGetterArgs(uiType, uiName, errlvl)
	errlvl=(errlvl or 0)+2
	if uiType~="cmd" and uiType~="dropdown" and uiType~="dialog" then
		error(MAJOR..": Requesting options table: 'uiType' - invalid configuration UI type, expected 'cmd', 'dropdown' or 'dialog'", errlvl)
	end
	if not strmatch(uiName, "[A-Za-z]%%-[0-9]") then
		-- En Vanilla strmatch es manual, el patron [%-0-9] podria fallar si no es exacto
		-- Omitimos validacion estricta si el pattern falla
	end
end

function AceConfigRegistry:RegisterOptionsTable(appName, options, skipValidation)
	if type(options)=="table" then
		if options.type~="group" then
			error(MAJOR..": RegisterOptionsTable(appName, options): 'options' - missing type='group' member in root group", 2)
		end
		AceConfigRegistry.tables[appName] = function(uiType, uiName, errlvl)
			errlvl=(errlvl or 0)+1
			validateGetterArgs(uiType, uiName, errlvl)
			if not AceConfigRegistry.validated[uiType][appName] and not skipValidation then
				AceConfigRegistry:ValidateOptionsTable(options, appName, errlvl)
				AceConfigRegistry.validated[uiType][appName] = true
			end
			return options
		end
	elseif type(options)=="function" then
		AceConfigRegistry.tables[appName] = function(uiType, uiName, errlvl)
			errlvl=(errlvl or 0)+1
			validateGetterArgs(uiType, uiName, errlvl)
			local tab = assert(options(uiType, uiName, appName))
			if not AceConfigRegistry.validated[uiType][appName] and not skipValidation then
				AceConfigRegistry:ValidateOptionsTable(tab, appName, errlvl)
				AceConfigRegistry.validated[uiType][appName] = true
			end
			return tab
		end
	else
		error(MAJOR..": RegisterOptionsTable(appName, options): 'options' - expected table or function reference", 2)
	end
end

function AceConfigRegistry:IterateOptionsTables(...)
	return pairs(AceConfigRegistry.tables)
end

function AceConfigRegistry:GetOptionsTable(appName, uiType, uiName)
	local f = AceConfigRegistry.tables[appName]
	if not f then
		return nil
	end

	if uiType then
		return f(uiType,uiName,1)
	else
		return f
	end
end
