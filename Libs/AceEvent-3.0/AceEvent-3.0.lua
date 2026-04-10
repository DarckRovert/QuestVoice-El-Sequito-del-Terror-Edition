--- AceEvent-3.0 proporciona registro de eventos y despacho seguro.
-- @class file
-- @name AceEvent-3.0
-- @release $Id: AceEvent-3.0.lua 1202 2019-05-15 23:11:22Z nevcairiel $
local CallbackHandler = LibStub("CallbackHandler-1.0")

local MAJOR, MINOR = "AceEvent-3.0", 4
local AceEvent = LibStub:NewLibrary(MAJOR, MINOR)

if not AceEvent then return end

-- Lua APIs
local pairs = pairs
local unpack = unpack

AceEvent.frame = AceEvent.frame or CreateFrame("Frame", "AceEvent30Frame") -- our event frame
AceEvent.embeds = AceEvent.embeds or {} -- what objects embed this lib

-- APIs and registry for blizzard events, using CallbackHandler lib
if not AceEvent.events then
	AceEvent.events = CallbackHandler:New(AceEvent,
		"RegisterEvent", "UnregisterEvent", "UnregisterAllEvents")
end

function AceEvent.events:OnUsed(target, eventname)
	AceEvent.frame:RegisterEvent(eventname)
end

function AceEvent.events:OnUnused(target, eventname)
	AceEvent.frame:UnregisterEvent(eventname)
end


-- APIs and registry for IPC messages, using CallbackHandler lib
if not AceEvent.messages then
	AceEvent.messages = CallbackHandler:New(AceEvent,
		"RegisterMessage", "UnregisterMessage", "UnregisterAllMessages"
	)
	AceEvent.SendMessage = AceEvent.messages.Fire
end

--- embedding and embed handling
local mixins = {
	"RegisterEvent", "UnregisterEvent",
	"RegisterMessage", "UnregisterMessage",
	"SendMessage",
	"UnregisterAllEvents", "UnregisterAllMessages",
}

-- Embeds AceEvent into the target object making the functions from the mixins list available on target:..
function AceEvent:Embed(target, ...)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

-- AceEvent:OnEmbedDisable( target )
function AceEvent:OnEmbedDisable(target, ...)
	target:UnregisterAllEvents()
	target:UnregisterAllMessages()
end

-- Script to fire blizzard events into the event listeners
local events = AceEvent.events
AceEvent.frame:SetScript("OnEvent", function(...)
	-- En WoW 1.12, 'event' y 'arg1'..'arg9' son globales en el manejador de OnEvent
	events:Fire(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end)

--- Finally: upgrade our old embeds
for target, v in pairs(AceEvent.embeds) do
	AceEvent:Embed(target)
end
