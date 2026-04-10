--- **AceConsole-3.0** proporciona facilidades de registro para comandos de barra inclinada (slash commands).
-- @class file
-- @name AceConsole-3.0
-- @release $Id: AceConsole-3.0.lua 1284 2022-09-25 09:15:30Z nevcairiel $
local MAJOR,MINOR = "AceConsole-3.0", 7

local AceConsole, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceConsole then return end -- No upgrade needed

AceConsole.embeds = AceConsole.embeds or {} -- table containing objects AceConsole is embedded in.
AceConsole.commands = AceConsole.commands or {} -- table containing commands registered
AceConsole.weakcommands = AceConsole.weakcommands or {} -- table containing self, command => func references for weak commands that don't persist through enable/disable

-- Lua APIs
local tconcat, tostring = table.concat, tostring
local type, pairs, error = type, pairs, error
local format, strfind, strsub = string.format, string.find, string.sub
local max = math.max
local unpack = unpack

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

-- WoW APIs
local _G = _G

local tmp={}
local function Print(self, frame, ...)
	local n=0
	if self ~= AceConsole then
		n=n+1
		tmp[n] = "|cff33ff99"..tostring( self ).."|r:"
	end
	for i=1, arg.n do
		n=n+1
		tmp[n] = tostring(arg[i])
	end
	if frame and frame.AddMessage then
		frame:AddMessage( tconcat(tmp," ",1,n) )
	end
end

--- Print to DEFAULT_CHAT_FRAME or given ChatFrame
function AceConsole:Print(...)
	local frame = arg[1]
	if type(frame) == "table" and frame.AddMessage then
		local params = {}
		for i = 2, arg.n do table.insert(params, arg[i]) end
		return Print(self, frame, unpack(params))
	else
		return Print(self, DEFAULT_CHAT_FRAME, unpack(arg))
	end
end


--- Formatted print
function AceConsole:Printf(...)
	local frame = arg[1]
	if type(frame) == "table" and frame.AddMessage then
		local params = {}
		for i = 2, arg.n do table.insert(params, arg[i]) end
		return Print(self, frame, format(unpack(params)))
	else
		return Print(self, DEFAULT_CHAT_FRAME, format(unpack(arg)))
	end
end


--- Register a simple chat command
function AceConsole:RegisterChatCommand( command, func, persist )
	if type(command)~="string" then error([[Usage: AceConsole:RegisterChatCommand( "command", func[, persist ]): 'command' - expected a string]], 2) end

	if persist==nil then persist=true end

	local name = "ACECONSOLE_"..string.upper(command)

	if type( func ) == "string" then
		SlashCmdList[name] = function(input, editBox)
			self[func](self, input, editBox)
		end
	else
		SlashCmdList[name] = func
	end
	_G["SLASH_"..name.."1"] = "/"..string.lower(command)
	AceConsole.commands[command] = name
	if not persist then
		if not AceConsole.weakcommands[self] then AceConsole.weakcommands[self] = {} end
		AceConsole.weakcommands[self][command] = func
	end
	return true
end

--- Unregister a chatcommand
function AceConsole:UnregisterChatCommand( command , ...)
	local name = AceConsole.commands[command]
	if name then
		SlashCmdList[name] = nil
		_G["SLASH_" .. name .. "1"] = nil
		AceConsole.commands[command] = nil
	end
end

function AceConsole:IterateChatCommands(...) return pairs(AceConsole.commands) end


local function nils(n, ...)
	if n>1 then
		return nil, nils(n-1, unpack(arg))
	elseif n==1 then
		return nil, unpack(arg)
	else
		return unpack(arg)
	end
end


--- Retreive one or more space-separated arguments from a string.
function AceConsole:GetArgs(str, numargs, startpos)
	numargs = numargs or 1
	startpos = max(startpos or 1, 1)

	local pos=startpos

	-- find start of new arg
	pos = strfind(str, "[^ ]", pos)
	if not pos then	-- whoops, end of string
		return nils(numargs, 1e9)
	end

	if numargs<1 then
		return pos
	end

	-- quoted or space separated? find out which pattern to use
	local delim_or_pipe
	local ch = strsub(str, pos, pos)
	if ch=='"' then
		pos = pos + 1
		delim_or_pipe='([|"])'
	elseif ch=="'" then
		pos = pos + 1
		delim_or_pipe="([|'])"
	else
		delim_or_pipe="([| ])"
	end

	startpos = pos

	while true do
		-- find delimiter or hyperlink
		local _
		pos,_,ch = strfind(str, delim_or_pipe, pos)

		if not pos then break end

		if ch=="|" then
			if strsub(str,pos,pos+1)=="|H" then
				pos=strfind(str, "|h", pos+2)
				if not pos then break end
				pos=strfind(str, "|h", pos+2)
				if not pos then break end
			elseif strsub(str,pos, pos+1) == "|T" then
				pos=strfind(str, "|t", pos+2)
				if not pos then break end
			end
			pos=pos+2 
		else
			return strsub(str, startpos, pos-1), AceConsole:GetArgs(str, numargs-1, pos+1)
		end
	end

	return strsub(str, startpos), nils(numargs-1, 1e9)
end


-- Embed handling
local mixins = {
	"Print",
	"Printf",
	"RegisterChatCommand",
	"UnregisterChatCommand",
	"GetArgs",
}

function AceConsole:Embed( target , ...)
	for k, v in pairs( mixins ) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

function AceConsole:OnEmbedEnable( target , ...)
	if AceConsole.weakcommands[target] then
		for command, func in pairs( AceConsole.weakcommands[target] ) do
			target:RegisterChatCommand( command, func, false )
		end
	end
end

function AceConsole:OnEmbedDisable( target , ...)
	if AceConsole.weakcommands[target] then
		for command, func in pairs( AceConsole.weakcommands[target] ) do
			target:UnregisterChatCommand( command )
		end
	end
end

for addon in pairs(AceConsole.embeds) do
	AceConsole:Embed(addon)
end
