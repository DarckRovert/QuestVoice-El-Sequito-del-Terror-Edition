--- AceConfigCmd-3.0 maneja el acceso a una tabla de opciones a través de la interfaz de "línea de comandos".
-- @class file
-- @name AceConfigCmd-3.0
-- @release $Id: AceConfigCmd-3.0.lua 1284 2022-09-25 09:15:30Z nevcairiel $

local cfgreg = LibStub("AceConfigRegistry-3.0")

local MAJOR, MINOR = "AceConfigCmd-3.0", 14
local AceConfigCmd = LibStub:NewLibrary(MAJOR, MINOR)

if not AceConfigCmd then return end

AceConfigCmd.commands = AceConfigCmd.commands or {}
local commands = AceConfigCmd.commands

local AceConsole -- LoD
local AceConsoleName = "AceConsole-3.0"

-- Lua APIs
local strsub, strlower, format, tonumber, tostring = string.sub, string.lower, string.format, tonumber, tostring
local tsort, tinsert, unpack = table.sort, table.insert, unpack
local pairs, next, type = pairs, next, type
local error, assert = error, assert

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
	local _, _, r1, r2, r3, r4 = string.find(str, pattern)
	return r1, r2, r3, r4
end

-- Polyfill para string.trim (WoW 1.12)
local function strtrim(str, ...)
	return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end

-- Polyfill para string.split (WoW 1.12)
local function strsplit(delim, str, max)
	local result = {}
	local i = 1
	for s in string.gfind(str, "([^"..delim.."]+)") do
		if max and i >= max then
			table.insert(result, string.sub(str, string.find(str, s)))
			break
		end
		table.insert(result, s)
		i = i + 1
	end
	return unpack(result)
end

-- WoW APIs
local _G = _G

local L = setmetatable({}, {
	__index = function(self,k) return k end
})

local function print(msg, ...)
	(SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME):AddMessage(msg)
end

local handlertypes = {["table"]=true}
local handlermsg = "expected a table"
local functypes = {["function"]=true, ["string"]=true}
local funcmsg = "expected function or member name"

local function pickfirstset(...)
	for i=1, arg.n do
		if arg[i] ~= nil then
			return arg[i]
		end
	end
end

local function err(info,inputpos,msg )
	local cmdstr=" "..strsub(info.input, 1, inputpos-1)
	error(MAJOR..": /" ..info[0] ..cmdstr ..": "..(msg or "malformed options table"), 2)
end

local function usererr(info,inputpos,msg )
	local cmdstr=strsub(info.input, 1, inputpos-1);
	print("/" ..info[0] .. " "..cmdstr ..": "..(msg or "malformed options table"))
end

local function callmethod(info, inputpos, tab, methodtype, ...)
	local method = info[methodtype]
	if not method then
		err(info, inputpos, "'"..methodtype.."': not set")
	end

	info.arg = tab.arg
	info.option = tab
	info.type = tab.type

	if type(method)=="function" then
		return method(info, unpack(arg))
	elseif type(method)=="string" then
		if type(info.handler[method])~="function" then
			err(info, inputpos, "'"..methodtype.."': '"..method.."' is not a member function of "..tostring(info.handler))
		end
		return info.handler[method](info.handler, info, unpack(arg))
	else
		assert(false)
	end
end

local function callfunction(info, tab, methodtype, ...)
	local method = tab[methodtype]

	info.arg = tab.arg
	info.option = tab
	info.type = tab.type

	if type(method)=="function" then
		return method(info, unpack(arg))
	else
		assert(false)
	end
end

local function do_final(info, inputpos, tab, methodtype, ...)
	if info.validate then
		local res = callmethod(info, inputpos, tab, "validate", unpack(arg))
		if type(res)=="string" then
			usererr(info, inputpos, "'"..strsub(info.input, inputpos).."' - "..res)
			return
		end
	end
	callmethod(info, inputpos, tab, methodtype, unpack(arg))
end

local function getparam(info, inputpos, tab, depth, paramname, types, errormsg)
	local old,oldat = info[paramname], info[paramname.."_at"]
	local val=tab[paramname]
	if val~=nil then
		if val==false then
			val=nil
		elseif not types[type(val)] then
			err(info, inputpos, "'" .. paramname.. "' - "..errormsg)
		end
		info[paramname] = val
		info[paramname.."_at"] = depth
	end
	return old,oldat
end

local function iterateargs(tab, ...)
	if not tab.plugins then
		return pairs(tab.args)
	end

	local argtabkey,argtab = next(tab.plugins)
	local v

	return function(_, k)
		while argtab do
			k,v = next(argtab, k)
			if k then return k,v end
			if argtab==tab.args then
				argtab=nil
			else
				argtabkey,argtab = next(tab.plugins, argtabkey)
				if not argtabkey then
					argtab=tab.args
				end
			end
		end
	end
end

local function checkhidden(info, inputpos, tab)
	if tab.cmdHidden~=nil then
		return tab.cmdHidden
	end
	local hidden = tab.hidden
	if type(hidden) == "function" or type(hidden) == "string" then
		info.hidden = hidden
		hidden = callmethod(info, inputpos, tab, 'hidden')
		info.hidden = nil
	end
	return hidden
end

local function showhelp(info, inputpos, tab, depth, noHead)
	if not noHead then
		print("|cff33ff99"..info.appName.."|r: Arguments to |cffffff78/"..info[0].."|r "..strsub(info.input,1,inputpos-1)..":")
	end

	local sortTbl = {}
	local refTbl = {}

	for k,v in iterateargs(tab) do
		if not refTbl[k] then
			tinsert(sortTbl, k)
			refTbl[k] = v
		end
	end

	tsort(sortTbl, function(one, two)
		local o1 = refTbl[one].order or 100
		local o2 = refTbl[two].order or 100
		if type(o1) == "function" or type(o1) == "string" then
			info.order = o1
			tinsert(info, one)
			o1 = callmethod(info, inputpos, refTbl[one], "order")
			table.remove(info, table.getn(info))
			info.order = nil
		end
		if type(o2) == "function" or type(o2) == "string" then
			info.order = o2
			tinsert(info, two)
			o2 = callmethod(info, inputpos, refTbl[two], "order")
			table.remove(info, table.getn(info))
			info.order = nil
		end
		if o1<0 and o2<0 then return o1<o2 end
		if o2<0 then return true end
		if o1<0 then return false end
		if o1==o2 then return tostring(one)<tostring(two) end
		return o1<o2
	end)

	for i = 1, table.getn(sortTbl) do
		local k = sortTbl[i]
		local v = refTbl[k]
		if not checkhidden(info, inputpos, v) then
			if v.type ~= "description" and v.type ~= "header" then
				local name, desc = v.name, v.desc
				if type(name) == "function" then
					name = callfunction(info, v, 'name')
				end
				if type(desc) == "function" then
					desc = callfunction(info, v, 'desc')
				end
				if v.type == "group" and pickfirstset(v.cmdInline, v.inline, false) then
					print("  "..(desc or name)..":")
					local oldhandler,oldhandler_at = getparam(info, inputpos, v, depth, "handler", handlertypes, handlermsg)
					showhelp(info, inputpos, v, depth, true)
					info.handler,info.handler_at = oldhandler,oldhandler_at
				else
					local key = string.gsub(k, " ", "_")
					print("  |cffffff78"..key.."|r - "..(desc or name or ""))
				end
			end
		end
	end
end

local function handle(info, inputpos, tab, depth, retfalse)
	if not(type(tab)=="table" and type(tab.type)=="string") then err(info,inputpos) end

	local oldhandler,oldhandler_at = getparam(info,inputpos,tab,depth,"handler",handlertypes,handlermsg)
	local oldset,oldset_at = getparam(info,inputpos,tab,depth,"set",functypes,funcmsg)
	local oldget,oldget_at = getparam(info,inputpos,tab,depth,"get",functypes,funcmsg)
	local oldfunc,oldfunc_at = getparam(info,inputpos,tab,depth,"func",functypes,funcmsg)
	local oldvalidate,oldvalidate_at = getparam(info,inputpos,tab,depth,"validate",functypes,funcmsg)

	if tab.type=="group" then
		if type(tab.args)~="table" then err(info, inputpos) end

		local _,nextpos,arg = string.find(info.input, " *([^ ]+) *", inputpos)
		if not arg then
			showhelp(info, inputpos, tab, depth)
			return
		end
		nextpos=nextpos+1

		for k,v in iterateargs(tab) do
			if v.type=="group" and pickfirstset(v.cmdInline, v.inline, false) then
				info[depth+1] = k
				if handle(info, inputpos, v, depth+1, true)==false then
					info[depth+1] = nil
				else
					return
				end
			elseif strlower(arg)==strlower(string.gsub(k, " ", "_")) then
				info[depth+1] = k
				return handle(info,nextpos,v,depth+1)
			end
		end

		if retfalse then
			info.handler,info.handler_at = oldhandler,oldhandler_at
			info.set,info.set_at = oldset,oldset_at
			info.get,info.get_at = oldget,oldget_at
			info.func,info.func_at = oldfunc,oldfunc_at
			info.validate,info.validate_at = oldvalidate,oldvalidate_at
			return false
		end

		usererr(info, inputpos, "'"..arg.."' - unknown argument")
		return
	end

	local strInput = strsub(info.input,inputpos);

	if tab.type=="execute" then
		do_final(info, inputpos, tab, "func")
	elseif tab.type=="input" then
		if tab.pattern then
			if not strmatch(strInput, tab.pattern) then
				usererr(info, inputpos, "'"..strInput.."' - invalid input")
				return
			end
		end
		do_final(info, inputpos, tab, "set", strInput)
	elseif tab.type=="toggle" then
		local b
		local str = strtrim(strlower(strInput))
		if str=="" then
			b = callmethod(info, inputpos, tab, "get")
			if tab.tristate then
				if b then b = nil elseif b == nil then b = false else b = true end
			else
				b = not b
			end
		elseif str=="on" then b = true
		elseif str=="off" then b = false
		elseif tab.tristate and str=="default" then b = nil
		else
			usererr(info, inputpos, "'"..str.."' - expected 'on' or 'off'")
			return
		end
		do_final(info, inputpos, tab, "set", b)
	elseif tab.type=="range" then
		local val = tonumber(strInput)
		if not val then usererr(info, inputpos, "'"..strInput.."' - expected number") return end
		do_final(info, inputpos, tab, "set", val)
	elseif tab.type=="select" then
		local str = strtrim(strlower(strInput))
		local values = tab.values
		if type(values) == "function" or type(values) == "string" then
			info.values = values
			values = callmethod(info, inputpos, tab, "values")
			info.values = nil
		end
		if str == "" then
			print("Options for |cffffff78"..info[table.getn(info)].."|r:")
			for k, v in pairs(values) do print("  - ["..k.."] "..v) end
			return
		end
		local ok
		for k,v in pairs(values) do
			if strlower(k)==str then str = k; ok = true; break end
		end
		if not ok then usererr(info, inputpos, "'"..str.."' - unknown selection") return end
		do_final(info, inputpos, tab, "set", str)
	elseif tab.type=="multiselect" then
		-- Abreviado para brevedad en backport base
		usererr(info, inputpos, "multiselect not fully supported in console backport")
	elseif tab.type=="color" then
		usererr(info, inputpos, "color not fully supported in console backport")
	else
		err(info, inputpos, "unknown options table item type '"..tostring(tab.type).."'")
	end
end

function AceConfigCmd:HandleCommand(slashcmd, appName, input)
	local optgetter = cfgreg:GetOptionsTable(appName)
	if not optgetter then error("no options table registered", 2) end
	local options = assert( optgetter("cmd", MAJOR) )
	local info = {
		[0] = slashcmd,
		appName = appName,
		options = options,
		input = input,
		self = self,
		handler = self,
		uiType = "cmd",
		uiName = MAJOR,
	}
	handle(info, 1, options, 0)
end

function AceConfigCmd:CreateChatCommand(slashcmd, appName)
	if not AceConsole then AceConsole = LibStub(AceConsoleName) end
	AceConsole.RegisterChatCommand(self, slashcmd, function(input, ...)
		AceConfigCmd.HandleCommand(self, slashcmd, appName, input)
	end, true)
	commands[slashcmd] = appName
end

function AceConfigCmd:GetChatCommandOptions(slashcmd, ...)
	return commands[slashcmd]
end
