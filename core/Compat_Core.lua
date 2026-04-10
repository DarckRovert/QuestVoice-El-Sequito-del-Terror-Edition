setfenv(1, VoiceOver)

if not select then
    function select(index, ...)
        if index == "#" then
            return arg.n
        else
            local result = {}
            for i = index, arg.n do
                table.insert(result, arg[i])
            end
            return unpack(result)
        end
    end
end

if not print or Version.IsLegacyVanilla or Version.IsLegacyBurningCrusade then
    local argn, argi
    if Version.IsLegacyVanilla then
        argn, argi = "arg.n", "arg[i]"
    else
        argn, argi = [[select("table.getn(", unpack(arg))]], [[(select(i, unpack(arg)))]]
    end
    print = loadstring(format([[return function(...)
        local text = ""
        for i = 1, %s do
            text = text .. (i > 1 and " " or "") .. tostring(%s)
        end
        DEFAULT_CHAT_FRAME:AddMessage(text)
    end]], argn, argi))()
end

if not strsplit then
    function strsplit(delimiter, text)
        local result = {}
        local from = 1
        local delim_from, delim_to = string.find(text, delimiter, from)
        while delim_from do
            table.insert(result, string.sub(text, from, delim_from - 1))
            from = delim_to + 1
            delim_from, delim_to = string.find(text, delimiter, from)
        end
        table.insert(result, string.sub(text, from))
        return unpack(result)
    end
end

if not string.gmatch then
    string.gmatch = string.gfind
end

if not string.match then
    local function getargs(s, e, ...)
        return unpack(arg)
    end
    function string.match(str, pattern)
        return getargs(string.find(str, pattern))
    end
end

if not string.trim then
    function string.trim(str, ...)
        return (string.match(str, "^%s*(.-)%s*$"))
    end
end

if not table.wipe then
    function table.wipe(tbl, ...)
        for key in next, tbl do
            tbl[key] = nil
        end
    end
end
if not wipe then
    wipe = table.wipe
end

if not hooksecurefunc then
    ---@overload fun(name, hook)
    function hooksecurefunc(table, name, hook)
        if not hook then
            name, hook = table, name
            table = _G
        end

        local old = table[name]
        assert(type(old) == "function")
        table[name] = function(...)
            local result = { old(unpack(arg)) }
            hook(unpack(arg))
            return unpack(result)
        end
    end
end

if not GetAddOnEnableState then
    ---@overload fun(addon)
    function GetAddOnEnableState(character, addon)
        addon = addon or character
        local name, _, _, _, loadable, reason = _G.GetAddOnInfo(addon)
        if not name or not loadable and reason == "DISABLED" then
            return 0
        end
        return 2
    end

    function GetAddOnInfo(indexOrName, ...)
        local name, title, notes, enabled, loadable, reason, security, newVersion = _G.GetAddOnInfo(indexOrName)
        return name, title, notes, loadable, reason, security, newVersion
    end
end


-- UI Compatibility Mixins moved from Hooks
RegionMixins = {}
RegionOverrides = {}
FrameMixins = {}
FrameOverrides = {}
FontStringMixins = {}
ModelMixins = {}
function ApplyMixinsAndOverrides(self, mixins, overrides)
    if mixins then
        for k, v in pairs(mixins) do
            if not self[k] then
                self[k] = v
            end
        end
    end
    if overrides then
        for k, v in pairs(overrides) do
            if self[k] then
                self["_" .. k], self[k] = self[k], v
            end
        end
    end
end
local orig_CreateFrame = _G.CreateFrame
function CreateFrame(frameType, name, parent, template)
    if template == "BackdropTemplate" then template = nil end
    local frame = orig_CreateFrame(frameType, name, parent, template)
    ApplyMixinsAndOverrides(frame, RegionMixins, RegionOverrides)
    ApplyMixinsAndOverrides(frame, FrameMixins, FrameOverrides)
    if hookFrame then hookFrame(frame) end
    if frameType == "Model" or frameType == "PlayerModel" or frameType == "DressUpModel" then
        ApplyMixinsAndOverrides(frame, ModelMixins)
        if hookModel then hookModel(frame) end
    end
    return frame
end
_G.CreateFrame = CreateFrame

local is_logged_in = false
local login_tracker = _G.CreateFrame("Frame")
login_tracker:RegisterEvent("PLAYER_LOGIN")
login_tracker:RegisterEvent("PLAYER_ENTERING_WORLD")
login_tracker:SetScript("OnEvent", function(...)
    is_logged_in = true
end)
function _G.IsLoggedIn()
    return is_logged_in or (UnitName("player") and UnitName("player") ~= "Unknown Entity")
end

-- Solo sobreescribir UnitGUID si el cliente no lo provee nativamente (1.12 no tiene UnitGUID)
if not _G.UnitGUID or _G.UnitGUID("player") == nil then
    function _G.UnitGUID(unit)
        return nil
    end
end

function RegionMixins:SetShown(shown, ...)
    if shown then
        self:Show()
    else
        self:Hide()
    end
end
function RegionMixins:SetSize(width, height)
    self:SetWidth(width)
    self:SetHeight(height)
end
function FrameMixins:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
    self:SetMinResize(minWidth, minHeight)
    if maxWidth and maxHeight then
        self:SetMaxResize(maxWidth, maxHeight)
    end
end
function ModelMixins:SetAnimation(animation, ...)
    self:SetSequence(animation)
end
function ModelMixins:SetCustomCamera(camera, ...)
    self:SetCamera(camera)
end
-- Patch 7.0.3 (2016-07-19): Added.
if Version:IsBelowLegacyVersion(70000) then
    local modelToFileID = {
        ["Original"] = {
            ["interface/buttons/talktomequestion_white"]                = 130737,

            ["character/bloodelf/female/bloodelffemale"]                = 116921,
            ["character/bloodelf/male/bloodelfmale"]                    = 117170,
            ["character/broken/female/brokenfemale"]                    = 117400,
            ["character/broken/male/brokenmale"]                        = 117412,
            ["character/draenei/female/draeneifemale"]                  = 117437,
            ["character/draenei/male/draeneimale"]                      = 117721,
            ["character/dwarf/female/dwarffemale"]                      = 118135,
            ["character/dwarf/female/dwarffemale_hd"]                   = 950080,
            ["character/dwarf/female/dwarffemale_npc"]                  = 950080,
            ["character/dwarf/male/dwarfmale"]                          = 118355,
            ["character/dwarf/male/dwarfmale_hd"]                       = 878772,
            ["character/dwarf/male/dwarfmale_npc"]                      = 878772,
            ["character/felorc/female/felorcfemale"]                    = 118652,
            ["character/felorc/male/felorcmale"]                        = 118653,
            ["character/felorc/male/felorcmaleaxe"]                     = 118654,
            ["character/felorc/male/felorcmalesword"]                   = 118667,
            ["character/foresttroll/male/foresttrollmale"]              = 118798,
            ["character/gnome/female/gnomefemale"]                      = 119063,
            ["character/gnome/female/gnomefemale_hd"]                   = 940356,
            ["character/gnome/female/gnomefemale_npc"]                  = 940356,
            ["character/gnome/male/gnomemale"]                          = 119159,
            ["character/gnome/male/gnomemale_hd"]                       = 900914,
            ["character/gnome/male/gnomemale_npc"]                      = 900914,
            ["character/goblin/female/goblinfemale"]                    = 119369,
            ["character/goblin/male/goblinmale"]                        = 119376,
            ["character/goblinold/male/goblinoldmale"]                  = 119376,
            ["character/human/female/humanfemale"]                      = 119563,
            ["character/human/female/humanfemale_hd"]                   = 1000764,
            ["character/human/female/humanfemale_npc"]                  = 1000764,
            ["character/human/male/humanmale"]                          = 119940,
            ["character/human/male/humanmale_cata"]                     = 119940,
            ["character/human/male/humanmale_hd"]                       = 1011653,
            ["character/human/male/humanmale_npc"]                      = 1011653,
            ["character/icetroll/male/icetrollmale"]                    = 232863,
            ["character/naga_/female/naga_female"]                      = 120263,
            ["character/naga_/male/naga_male"]                          = 120294,
            ["character/nightelf/female/nightelffemale"]                = 120590,
            ["character/nightelf/female/nightelffemale_hd"]             = 921844,
            ["character/nightelf/female/nightelffemale_npc"]            = 921844,
            ["character/nightelf/male/nightelfmale"]                    = 120791,
            ["character/nightelf/male/nightelfmale_hd"]                 = 974343,
            ["character/nightelf/male/nightelfmale_npc"]                = 974343,
            ["character/northrendskeleton/male/northrendskeletonmale"]  = 233367,
            ["character/orc/female/orcfemale"]                          = 121087,
            ["character/orc/female/orcfemale_npc"]                      = 121087,
            ["character/orc/male/orcmale"]                              = 121287,
            ["character/orc/male/orcmale_hd"]                           = 917116,
            ["character/orc/male/orcmale_npc"]                          = 917116,
            ["character/scourge/female/scourgefemale"]                  = 121608,
            ["character/scourge/female/scourgefemale_hd"]               = 997378,
            ["character/scourge/female/scourgefemale_npc"]              = 997378,
            ["character/scourge/male/scourgemale"]                      = 121768,
            ["character/scourge/male/scourgemale_hd"]                   = 959310,
            ["character/scourge/male/scourgemale_npc"]                  = 959310,
            ["character/skeleton/male/skeletonmale"]                    = 121942,
            ["character/taunka/male/taunkamale"]                        = 233878,
            ["character/tauren/female/taurenfemale"]                    = 121961,
            ["character/tauren/female/taurenfemale_hd"]                 = 986648,
            ["character/tauren/female/taurenfemale_npc"]                = 986648,
            ["character/tauren/male/taurenmale"]                        = 122055,
            ["character/tauren/male/taurenmale_hd"]                     = 968705,
            ["character/tauren/male/taurenmale_npc"]                    = 968705,
            ["character/troll/female/trollfemale"]                      = 122414,
            ["character/troll/female/trollfemale_hd"]                   = 1018060,
            ["character/troll/female/trollfemale_npc"]                  = 1018060,
            ["character/troll/male/trollmale"]                          = 122560,
            ["character/troll/male/trollmale_hd"]                       = 1022938,
            ["character/troll/male/trollmale_npc"]                      = 1022938,
            ["character/tuskarr/male/tuskarrmale"]                      = 122738,
            ["character/vrykul/male/vrykulmale"]                        = 122815,
        },
        ["HD"] = {
            ["character/scourge/female/scourgefemale"]                  = 997378,
        },
    }
    local function CleanupModelName(model, ...)
        model = string.lower(model)
        model = string.gsub(model, "\\", "/")
        model = string.gsub(model, "%.m2", "")
        model = string.gsub(model, "%.mdx", "")
        return model
    end
    function ModelMixins:GetModelFileID(...)
        local model = self:GetModel()
        if model and type(model) == "string" then
            model = CleanupModelName(model)
            local models = modelToFileID[Utils:GetCurrentModelSet()] or modelToFileID["Original"]
            return models[model] or modelToFileID["Original"][model]
        end
    end
end


-- UI Overrides moved from Hooks to Core
    function RegionOverrides:SetPoint(point, region, relativeFrame, offsetX, offsetY)
        if region == nil and relativeFrame == nil and offsetX == nil and offsetY == nil then
            self:_SetPoint(point, 0, 0)
        else
            self:_SetPoint(point, region, relativeFrame, offsetX, offsetY)
        end
    end
    function FrameOverrides:SetScript(script, handler)
        self:_SetScript(script, script == "OnEvent"
            and function(...) handler(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end
            or  function(...) handler(this,        arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end)
    end
    function FrameMixins:HookScript(script, handler)
        local old = self:GetScript(script)
        self:_SetScript(script, script == "OnEvent"
            and function(...) if old then old() end handler(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end
            or  function(...) if old then old() end handler(this,        arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end)
    end

    hooksecurefunc(GameTooltip, "SetOwner", function(self, owner, anchor)
        self._owner = owner
    end)
    function GameTooltip:GetOwner(...)
        return self._owner
    end
