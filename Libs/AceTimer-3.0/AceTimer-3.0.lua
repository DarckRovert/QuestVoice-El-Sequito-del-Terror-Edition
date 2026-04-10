--- **AceTimer-3.0** proporciona un servicio central para registrar temporizadores.
-- @class file
-- @name AceTimer-3.0
-- @release $Id: AceTimer-3.0.lua 1284 2022-09-25 09:15:30Z nevcairiel $

local MAJOR, MINOR = "AceTimer-3.0", 17 
local AceTimer, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceTimer then return end -- No upgrade needed

AceTimer.activeTimers = AceTimer.activeTimers or {}
local activeTimers = AceTimer.activeTimers

-- Lua APIs
local type, unpack, next, error = type, unpack, next, error

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
local GetTime = GetTime

-- Polyfill para C_Timer.After usando un Frame (WoW 1.12)
AceTimer.frame = AceTimer.frame or CreateFrame("Frame")
local timerQueue = {}

AceTimer.frame:SetScript("OnUpdate", function(...)
	local now = GetTime()
	for i = table.getn(timerQueue), 1, -1 do
		local t = timerQueue[i]
		if now >= t.ends then
			table.remove(timerQueue, i)
			t.callback()
		end
	end
end)

local function C_TimerAfter(delay, func)
	table.insert(timerQueue, {
		ends = GetTime() + delay,
		callback = func
	})
end

local function new(self, loop, func, delay, ...)
	if delay < 0.01 then
		delay = 0.01
	end

	local timer = {
		object = self,
		func = func,
		looping = loop,
		argsCount = arg.n,
		delay = delay,
		ends = GetTime() + delay,
	}
	-- Copiar argumentos a la tabla timer para unpack posterior
	for i = 1, arg.n do
		timer[i] = arg[i]
	end

	activeTimers[timer] = timer

	timer.callback = function(...)
		if not timer.cancelled then
			if type(timer.func) == "string" then
				timer.object[timer.func](timer.object, unpack(timer))
			else
				timer.func(unpack(timer))
			end

			if timer.looping and not timer.cancelled then
				local time = GetTime()
				local ndelay = timer.delay - (time - timer.ends)
				if ndelay < 0.01 then ndelay = 0.01 end
				C_TimerAfter(ndelay, timer.callback)
				timer.ends = time + ndelay
			else
				activeTimers[timer.handle or timer] = nil
			end
		end
	end

	C_TimerAfter(delay, timer.callback)
	return timer
end

function AceTimer:ScheduleTimer(func, delay, ...)
	if not func or not delay then
		error(MAJOR..": ScheduleTimer(callback, delay, args...): 'callback' and 'delay' must have set values.", 2)
	end
	return new(self, nil, func, delay, unpack(arg))
end

function AceTimer:ScheduleRepeatingTimer(func, delay, ...)
	if not func or not delay then
		error(MAJOR..": ScheduleRepeatingTimer(callback, delay, args...): 'callback' and 'delay' must have set values.", 2)
	end
	return new(self, true, func, delay, unpack(arg))
end

function AceTimer:CancelTimer(id, ...)
	local timer = activeTimers[id]
	if not timer then
		return false
	else
		timer.cancelled = true
		activeTimers[id] = nil
		return true
	end
end

function AceTimer:CancelAllTimers(...)
	for k,v in pairs(activeTimers) do
		if v.object == self then
			AceTimer.CancelTimer(self, k)
		end
	end
end

function AceTimer:TimeLeft(id, ...)
	local timer = activeTimers[id]
	if not timer then
		return 0
	else
		return timer.ends - GetTime()
	end
end

-- Embed handling
AceTimer.embeds = AceTimer.embeds or {}
local mixins = {
	"ScheduleTimer", "ScheduleRepeatingTimer",
	"CancelTimer", "CancelAllTimers",
	"TimeLeft"
}

function AceTimer:Embed(target, ...)
	AceTimer.embeds[target] = true
	for _,v in pairs(mixins) do
		target[v] = AceTimer[v]
	end
	return target
end

function AceTimer:OnEmbedDisable(target, ...)
	target:CancelAllTimers()
end

for addon in pairs(AceTimer.embeds) do
	AceTimer:Embed(addon)
end
