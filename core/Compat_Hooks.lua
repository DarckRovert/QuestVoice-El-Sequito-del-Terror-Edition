setfenv(1, VoiceOver)

if not GetQuestID then
    local source, text
    local old_QUEST_DETAIL = Addon.QUEST_DETAIL
    local old_QUEST_PROGRESS = Addon.QUEST_PROGRESS
    local old_QUEST_COMPLETE = Addon.QUEST_COMPLETE
    local GetTitleText = GetTitleText -- Store original function before EQL3 (Extended Quest Log 3) overrides it and starts prepending quest level
    function Addon:QUEST_DETAIL(...)   source = "accept"   text = GetQuestText()    old_QUEST_DETAIL(self) end
    function Addon:QUEST_PROGRESS(...) source = "progress" text = GetProgressText() old_QUEST_PROGRESS(self) end
    function Addon:QUEST_COMPLETE(...) source = "complete" text = GetRewardText()   old_QUEST_COMPLETE(self) end
    function GetQuestID(...)
        local npcName = Utils:GetNPCName()
        if Utils:IsNPCPlayer() then
            -- Can't do anything about quest sharing currently, because we need the original questgiver's name to obtain quest ID, and we need quest ID to obtain the questgiver's name
            return 0
        end

        local title = GetTitleText()
        local questID = DataModules:GetQuestID(source, title, npcName, text) or 0
        
        -- Telemetría técnica obligatoria para depuración
        if questID == 0 then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffa500[QuestVoice]|r ID no encontrado para: [%s] de [%s]", tostring(title), tostring(npcName)))
        else
            if Addon.db.profile.DebugEnabled then
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ffcc[QuestVoice]|r ID%d resuelto para: %s", questID, title))
            end
        end

        return questID
    end

end

if not QUESTS_DISPLAYED then
    if QuestLogScrollFrame then
        QUESTS_DISPLAYED = getn(QuestLogScrollFrame.buttons)
    end
end

-- Patch 7.3.0: New global table: SOUNDKIT - Keys are named similar to the old string names, and they hold the soundkit ID for the sound
if not SOUNDKIT or Version:IsBelowLegacyVersion(70300) then
    SOUNDKIT =
    {
        U_CHAT_SCROLL_BUTTON = "uChatScrollButton",
        IG_MAINMENU_OPEN = "igMainMenuOpen",
        IG_MAINMENU_CLOSE = "igMainMenuClose",
    }
end

-- Not sure when exactly were UI-Cursor-Move and UI-Cursor-SizeRight added, but the former was present in 6.0.1
if Version:IsBelowLegacyVersion(60000) then
    function SetCursor(...) end
end

-- Patch 2.4.0 (2008-03-25): Added.
if Version.IsAnyLegacy and not UnitGUID then
    -- 1.0.0 - 2.3.0
    Utils.GetGUIDType = nil
    Utils.GetIDFromGUID = nil
    Utils.MakeGUID = function(...) end
-- Patch 4.0.1 (2010-10-12): Bits shifted. NPCID is now characters 5-8, not 7-10 (counting from 1).
elseif Version:IsBelowLegacyVersion(40000) then
    -- 2.4.0 - 3.3.5
    Enums.GUID.Player     = tonumber("0000", 16)
    Enums.GUID.Item       = tonumber("4000", 16)
    Enums.GUID.Creature   = tonumber("F130", 16)
    Enums.GUID.Vehicle    = tonumber("F150", 16)
    Enums.GUID.GameObject = tonumber("F110", 16)

    function Utils:GetGUIDType(guid, ...)
        return guid and tonumber(string.sub(guid, 3, 3 + 4 - 1), 16)
    end

    function Utils:GetIDFromGUID(guid, ...)
        local type = assert(self:GetGUIDType(guid), format([[Failed to determine the type of GUID "%s"]], guid))
        assert(Enums.GUID:GetName(type), format([[Unknown GUID type%d]], type))
        assert(Enums.GUID:CanHaveID(type), format([[GUID "%s" does not contain ID]], guid))
        return tonumber(string.sub(guid, 7, 7 + 6 - 1), 16)
    end

    function Utils:MakeGUID(type, id)
        assert(Enums.GUID:CanHaveID(type), format("GUID of type%d (%s) cannot contain ID", type, Enums.GUID:GetName(type) or "Unknown"))
        return format("0x%04X%06X%06X", type, id, 0)
    end
-- Patch 6.0.2 (2014-10-14): Changed to a new format, e.g. for players: Player-[serverID]-[playerUID]
elseif Version:IsBelowLegacyVersion(60000) then
    -- 4.0.1 - 5.4.8
    Enums.GUID.Player     = tonumber("000", 16)
    Enums.GUID.Item       = tonumber("400", 16)
    Enums.GUID.Creature   = tonumber("F13", 16)
    Enums.GUID.Vehicle    = tonumber("F15", 16)
    Enums.GUID.GameObject = tonumber("F11", 16)

    function Utils:GetGUIDType(guid, ...)
        return guid and tonumber(string.sub(guid, 3, 3 + 3 - 1), 16)
    end

    function Utils:GetIDFromGUID(guid, ...)
        if not guid then
            return
        end
        local type = assert(self:GetGUIDType(guid), format([[Failed to determine the type of GUID "%s"]], guid))
        assert(Enums.GUID:GetName(type), format("Unknown GUID type%d", type))
        assert(Enums.GUID:CanHaveID(type), format([[GUID "%s" does not contain ID]], guid))
        return tonumber(string.sub(guid, 6, 6 + 5 - 1), 16)
    end

    function Utils:MakeGUID(type, id)
        assert(Enums.GUID:CanHaveID(type), format("GUID of type%d (%s) cannot contain ID", type, Enums.GUID:GetName(type) or "Unknown"))
        return format("0x%03X%05X%08X", type, id, 0)
    end
end

-- Patch 6.0.2 (2014-10-14): Removed returns 'questTag' and 'isDaily'. Added returns 'frequency', 'isOnMap', 'hasLocalPOI', 'isTask', and 'isStory'.
if Version:IsBelowLegacyVersion(60000) then
    local dummyQuestIDMap = { NEXT = -1 }
    local oldGetQuestLogTitle = GetQuestLogTitle -- Store original function before BEQL (Bayi's Extended Questlog) overrides it and starts prepending quest level
    function GetQuestLogTitle(questIndex, ...)
        local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, displayQuestID
        -- Patch 2.0.3 (2007-01-09): Added the 'suggestedGroup' return.
        if Version:IsBelowLegacyVersion(20000) then
            title, level, questTag, isHeader, isCollapsed, isComplete = oldGetQuestLogTitle(questIndex)
        else
            title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, displayQuestID = oldGetQuestLogTitle(questIndex)
        end
        -- Patch 3.3.0 (2009-12-08): Added the 'questID' return.
        if Version:IsBelowLegacyVersion(30300) then
            questID = DataModules:GetQuestID("accept", title, "", "")
            if not questID then
                -- Try assuming that the last quest with the same title that the player has accepted is the quest that's currently in the quest log
                questID = Addon.db.char.RecentQuestTitleToID[title]
            end
            if not questID then
                -- Return a dummy quest ID unique per quest title, just to support having multiple quest log buttons in their current implementation (i.e. keyed by quest ID instead of button index)
                questID = dummyQuestIDMap[title]
                if not questID then
                    questID = dummyQuestIDMap.NEXT
                    dummyQuestIDMap.NEXT = dummyQuestIDMap.NEXT - 1
                    dummyQuestIDMap[title] = questID
                end
            end
        end
        local frequency = isDaily and 2 or 1
        return title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID
    end
end

if Version.IsLegacyVanilla then



    local function getargn(...)
        return arg.n
    end
    function GetNumGossipActiveQuests(...)
        return getargn(GetGossipActiveQuests())
    end
    function GetNumGossipAvailableQuests(...)
        return getargn(GetGossipAvailableQuests())
    end

    function Utils:GetNPCName(...)
        return UnitName("npc")
    end

    function Utils:GetNPCGUID(...)
        return nil
    end

    function Utils:IsNPCObjectOrItem(...)
        return not UnitExists("npc")
    end

    function Utils:IsNPCPlayer(...)
        return UnitIsPlayer("npc")
    end

    function Utils:IsSoundEnabled(...)
        local enableSound = GetCVar("EnableSound")
        if enableSound == nil then return true end
        return tonumber(enableSound) == 1
    end

    function Utils:TestSound(soundData, ...)
        return true
    end

    function Utils:PlaySound(soundData, ...)
        -- [HOTFIX] Turtle WoW (1.12)
        -- Apagar y prender 'EnableSound' en vainilla reinicia el motor FMOD
        -- y silencia las llamadas a PlaySoundFile que se realicen en el mismo frame.
        -- Deshabilitamos el AutoToggleDialog hack.
        -- if Addon.db.profile.Audio.AutoToggleDialog then
        --     SetCVar("EnableSound", 0)
        --     SetCVar("EnableSound", 1)
        -- end

        if Addon.db.profile.DebugEnabled then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ffcc[QuestVoice]|r Intentando reproducir: %s", tostring(soundData.filePath)))
        end

        PlaySoundFile(soundData.filePath)
        soundData.handle = 1 -- Flag para referenciar que se puede silenciar
    end

    function Utils:StopSound(soundData, ...)
        SetCVar("EnableSound", 0)
        SetCVar("EnableSound", 1)
        soundData.handle = nil
    end


    function Addon.OnAddonLoad.EQL3(...) -- Extended Quest Log 3
        QUESTS_DISPLAYED = EQL3_QUESTS_DISPLAYED

        QuestLogFrame = EQL3_QuestLogFrame
        QuestLogListScrollFrame = EQL3_QuestLogListScrollFrame

        function Utils:GetQuestLogTitleFrame(index, ...)
            return _G["EQL3_QuestLogTitle" .. index]
        end

        function Utils:GetQuestLogTitleNormalText(index, ...)
            return _G["EQL3_QuestLogTitle" .. index .. "NormalText"]
        end

        function Utils:GetQuestLogTitleCheck(index, ...)
            return _G["EQL3_QuestLogTitle" .. index .. "Check"]
        end

        -- Hook the new function created by EQL3
        hooksecurefunc("QuestLog_Update", function(...)
            QuestOverlayUI:Update()
        end)
    end

end
if Version.IsLegacyVanilla or Version.IsLegacyBurningCrusade then

    local modelFramePool = {}
    function Utils:CreateNPCModelFrame(soundData, ...)
        if soundData.modelFrame then
            return
        end

        local frame
        for _, pooled in ipairs(modelFramePool) do
            if not pooled._inUse then
                frame = pooled
                break
            end
        end

        if not frame then
            frame = CreateFrame("PlayerModel", nil, SoundQueueUI.frame.portrait)
            table.insert(modelFramePool, frame)
        end

        frame._inUse = true
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT")
        frame:SetWidth(1); frame:SetHeight(1)
        frame:Show()
        frame:SetUnit("npc")

        soundData.modelFrame = frame
    end
    function Utils:FreeNPCModelFrame(soundData, ...)
        local frame = soundData.modelFrame
        if not frame then
            return
        end
        soundData.modelFrame = nil

        if SoundQueueUI.frame.portrait.model == frame then
            SoundQueueUI.frame.portrait.model = SoundQueueUI.frame.portrait.defaultModel
        end

        frame:Hide()
        frame:ClearModel()
        frame._inUse = false
    end

    function hookModel(self, ...)
        self._sequence = 0
        hooksecurefunc(self, "ClearModel", function(self, ...)
            self._sequence = 0
            self._sequenceStart = nil
        end)
        hooksecurefunc(self, "SetSequence", function(self, sequence)
            self._sequence = sequence
            self._sequenceStart = GetTime()
        end)
        self:HookScript("OnUpdate", function(self, elapsed)
            if self._sequence ~= 0 then
                self:SetSequenceTime(self._sequence, (GetTime() - self._sequenceStart) * 1000)
            end
        end)
    end

    function FrameOverrides:HookScript(script, handler)
        if self:GetScript(script) then
            self:_HookScript(script, handler)
        else
            self:SetScript(script, handler)
        end
    end
    function FrameOverrides:CreateTexture(name, layer)
        local region = self:_CreateTexture(name, layer)
        ApplyMixinsAndOverrides(region, RegionMixins, RegionOverrides)
        return region
    end
    function FrameOverrides:CreateFontString(name, layer, template)
        local region = self:_CreateFontString(name, layer, template)
        ApplyMixinsAndOverrides(region, RegionMixins, RegionOverrides)
        ApplyMixinsAndOverrides(region, FontStringMixins)
        return region
    end
    function FrameOverrides:SetNormalTexture(file, ...)
        local texture = self:CreateTexture(nil, "ARTWORK")
        local success = texture:SetTexture(file)
        texture:SetAllPoints()
        self._normalTexture = texture
        self:_SetNormalTexture(texture)
        return success
    end
    function FrameMixins:GetNormalTexture(...)
        return self._normalTexture
    end
    function FrameOverrides:SetPushedTexture(file, ...)
        local texture = self:CreateTexture(nil, "ARTWORK")
        local success = texture:SetTexture(file)
        texture:SetAllPoints()
        self._pushedTexture = texture
        self:_SetPushedTexture(texture)
        return success
    end
    function FrameMixins:GetPushedTexture(...)
        return self._pushedTexture
    end
    function FrameOverrides:SetDisabledTexture(file, ...)
        local texture = self:CreateTexture(nil, "ARTWORK")
        local success = texture:SetTexture(file)
        texture:SetAllPoints()
        self._disabledTexture = texture
        self:_SetDisabledTexture(texture)
        return success
    end
    function FrameMixins:GetDisabledTexture(...)
        return self._disabledTexture
    end
    function FrameOverrides:SetHighlightTexture(file, ...)
        local texture = self:CreateTexture(nil, "HIGHLIGHT")
        local success = texture:SetTexture(file)
        texture:SetAllPoints()
        self._highlightTexture = texture
        self:_SetHighlightTexture(texture)
        return success
    end
    function FrameMixins:GetHighlightTexture(...)
        return self._highlightTexture
    end
    function FontStringMixins:SetWordWrap(wrap, ...)
        if not wrap then
            self:SetHeight((select(2, self:GetFont())))
        end
    end
    function ModelMixins:SetCreature(...)
    end

    function GameTooltip_Hide(...)
        -- Used for XML OnLeave handlers
        GameTooltip:Hide()
    end

end
if Version.IsLegacyBurningCrusade then
end
if Version.IsLegacyBurningCrusade or Version.IsLegacyWrath then

    function Utils:IsSoundEnabled(...)
        if tonumber(GetCVar("Sound_EnableAllSound")) ~= 1 then
            return false
        end
        return Addon.db.profile.LegacyWrath.PlayOnMusicChannel.Enabled or tonumber(GetCVar("Sound_EnableSFX")) == 1
    end

    function Utils:TestSound(soundData, ...)
        return true
    end

    function Utils:GetCurrentModelSet(...)
        return Addon.db.profile.LegacyWrath.HDModels and "HD" or "Original"
    end

    --[[
        Here begins the code the plays the VO over music channel in order to support the ability to pause/stop the VO.
        2.4.3's and 3.3.5's PlaySound/PlaySoundFile cannot be stopped by any means short of restarting the whole sound system (freezes the client for a couple of seconds).
        But PlayMusic can be stopped with StopMusic. This, however, causes the currently played script music to fade out instead of cutting,
            which is a problem, because by letting this happen we'll hear the VO looping until it fully fades out. This can be worked around
            by PlayMusic'ing another file (even one that doesn't exist), as that causes the script music to be instantly interrupted.
        Toggling Sound_EnableMusic cvar off-and-on additionally allows us to interrupt the current in-game background music.
        The whole process looks as follows:
        1. Sound queue requests to start playing the VO by calling Utils:PlaySound
        2. Music volume is smoothly lowered to 0 over the config.FadeOutMusic duration
        3. In-game background music is instantly stopped by toggling Sound_EnableMusic cvar off-and-on
        4. Music volume is instantly changed to config.Volume level
        5. VO sound file is played on the music channel
        6. Once the VO's duration has ran out (soundData.stopSoundTimer) - silence.wav is played as music to instantly stop the VO and prevent it from looping
        7. Sound queue requests to stop playing the VO by calling Utils:StopSound (either due to pause or soundData being removed from the queue) - silence.wav is played again to interrupt the VO in case it hasn't finished playing naturally
        8. Music volume is instantly changed to 0
        9. Music volume is smoothly raised to back to the pre-VO level over the config.FadeOutMusic duration
        10. In-game background music is removed by calling StopMusic()

        On 2.4.3 steps 2 and 3 are swapped, because 3.3.5's trick to instantly stop music by toggling cvars causes it to instead
            fade out over a short time on 2.4.3 (around 0.4-0.5 secs). So we lock config.FadeOutMusic to 0.5 secs let the client
            fade music out naturally during these 0.5 seconds, after which we bump the volume up and proceed as normal.
    ]]
    local function GetCurrentVolume(...)
        return tonumber(GetCVar("Sound_MusicVolume")) or 1
    end
    local function PlaySilence(...)
        PlayMusic([[Interface\AddOns\QuestVoice\Sounds\silence.wav]])
    end

    -- Functions that deal with temporarily changing player's sound settings to utilize the music channel for VO playback
    local prev_Sound_EnableMusic
    local prev_Sound_MusicVolume
    local function ReplaceCVars(...)
        if prev_Sound_EnableMusic == nil then
            prev_Sound_EnableMusic = GetCVar("Sound_EnableMusic")
            prev_Sound_MusicVolume = GetCVar("Sound_MusicVolume")
            SetCVar("Sound_EnableMusic", 1)
        end
    end
    local function RestoreCVars(...)
        if prev_Sound_EnableMusic ~= nil then
            SetCVar("Sound_EnableMusic", prev_Sound_EnableMusic)
            SetCVar("Sound_MusicVolume", prev_Sound_MusicVolume)
            prev_Sound_EnableMusic = nil
            prev_Sound_MusicVolume = nil
        end
    end

    -- Functions that deal with smoothly changing the music channel's volume to avoid abrupt changes
    local slideVolumeTarget
    local slideVolumeRate
    local slideVolumeCallback
    local EPS_VOLUME = 0.01
    local function GetMusicFadeOutDuration(...)
        if tonumber(prev_Sound_EnableMusic) == 0 or tonumber(prev_Sound_MusicVolume) == 0 then
            return 0
        end
        return Addon.db.profile.LegacyWrath.PlayOnMusicChannel.FadeOutMusic or 0
    end
    local function StopSlideVolume(...)
        slideVolumeTarget = nil
        slideVolumeRate = nil
        slideVolumeCallback = nil
    end
    local function SlideVolume(target, callback)
        local duration = GetMusicFadeOutDuration()
        if duration <= 0 then
            -- Instantly change the volume if the player had reduced the duration all the way to 0
            return false
        end
        local current = GetCurrentVolume()
        if math.abs(target - current) <= EPS_VOLUME then
            -- Instantly "change" the volume if it's already fuzzy-equal to the target volume, and cancel the ongoing slide volume ("remove currently played sound from queue" case)
            StopSlideVolume()
            return false
        end
        -- Interpolate towards the target volume over the configured duration
        slideVolumeTarget = target
        slideVolumeRate = (target - current) / duration
        slideVolumeCallback = callback
        return true
    end
    local volumeFrame = CreateFrame("Frame", "VoiceOverSlideVolumeFrame", UIParent)
    volumeFrame:RegisterEvent("PLAYER_LOGOUT")
    volumeFrame:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_LOGOUT" then
            StopSlideVolume()
            RestoreCVars()
        end
    end)
    volumeFrame:HookScript("OnUpdate", function(self, elapsed)
        if slideVolumeRate then
            local current = GetCurrentVolume()
            local target = slideVolumeTarget
            local next = current + slideVolumeRate * elapsed
            local finished = false
            if math.abs(target - current) <= EPS_VOLUME or current < target and next >= target or current > target and next <= target then
                next = target
                finished = true
            end
            SetCVar("Sound_MusicVolume", next)
            if finished then
                if slideVolumeCallback then
                    slideVolumeCallback()
                end
                StopSlideVolume()
            end
        end
    end)

    function Utils:PlaySound(soundData, ...)
        soundData.delay = nil
        if not Addon.db.profile.LegacyWrath.PlayOnMusicChannel.Enabled then
            -- Play VO as a sound, but have no ability to stop it
            _G.PlaySoundFile(soundData.filePath)
            return
        end

        soundData.handle = 1 -- Just put something here to flag the sound as stoppable

        ReplaceCVars()
        local function Play(...)
            -- Hack to instantly interrupt the music
            SetCVar("Sound_EnableMusic", 0)
            SetCVar("Sound_EnableMusic", 1)

            SetCVar("Sound_MusicVolume", Addon.db.profile.LegacyWrath.PlayOnMusicChannel.Volume)
            PlayMusic(soundData.filePath)

            soundData.stopSoundTimer = Addon:ScheduleTimer(function(...)
                PlaySilence() -- Instantly interrupt the VO sound
            end, soundData.length)
        end
        if SlideVolume(0, Play) then
            soundData.delay = GetMusicFadeOutDuration()

            if Version.IsLegacyBurningCrusade then
                -- On 2.4.3 we ask the client to interrupt the music here and give it time to fade out naturally
                SetCVar("Sound_EnableMusic", 0)
                SetCVar("Sound_EnableMusic", 1)
                PlaySilence()
            end
        else
            Play()
        end
    end

    function Utils:StopSound(soundData, ...)
        if not soundData.handle then
            -- VO was played as a sound - we cannot stop it
            return
        end

        Addon:CancelTimer(soundData.stopSoundTimer, true)
        soundData.stopSoundTimer = nil

        PlaySilence() -- Instantly interrupt the VO sound
        SetCVar("Sound_MusicVolume", 0)

        local function ResumeMusic(...)
            StopMusic()
            RestoreCVars()
        end
        if not SlideVolume(tonumber(prev_Sound_MusicVolume) or 1, ResumeMusic) then
            ResumeMusic()
        end
    end

    -- Frame fade-in animation to help alleviate the UX damage caused by delaying the VO
    hooksecurefunc(SoundQueueUI, "InitDisplay", function(self, ...)
        local fadeIn, animation
        if self.frame.CreateAnimationGroup then
            fadeIn = self.frame:CreateAnimationGroup()
            animation = fadeIn:CreateAnimation("Alpha")
            animation:SetOrder(1)
            animation:SetDuration(0)
            animation:SetChange(-1)
            animation = fadeIn:CreateAnimation("Alpha")
            animation:SetOrder(2)
            animation:SetDuration(1)
            animation:SetChange(1)
            animation:SetSmoothing("OUT")
        else
            fadeIn, animation = { frame = self.frame }, {}
            function fadeIn:Stop(...)
                self.frame:SetAlpha(1)
                self.enabled = nil
            end
            function fadeIn:Play(...)
                self.frame:SetAlpha(0)
                self.enabled = true
            end
            function animation:SetDuration(duration, ...)
                self.duration = duration
            end
            self.frame:HookScript("OnUpdate", function(self, elapsed)
                if fadeIn.enabled then
                    local alpha = math.min(1, self:GetAlpha() + elapsed / animation.duration)
                    if alpha >= 1 then
                        fadeIn:Stop()
                    else
                        self:SetAlpha(alpha)
                    end
                end
            end)
        end
        self.frame:HookScript("OnShow", function(...)
            fadeIn:Stop()
            local soundData = SoundQueue:GetCurrentSound()
            local duration = soundData and soundData.delay or 0
            if duration > 0 then
                animation:SetDuration(duration)
                fadeIn:Play()
            end
        end)
    end)

end
if Version.IsLegacyWrath then

    function Utils:GetQuestLogScrollOffset(...)
        return HybridScrollFrame_GetOffset(QuestLogScrollFrame)
    end

    function Utils:GetQuestLogTitleFrame(index, ...)
        return _G["QuestLogScrollFrameButton" .. index]
    end

    function Utils:GetQuestLogTitleNormalText(index, ...)
        return _G["QuestLogScrollFrameButton" .. index .. "NormalText"]
    end

    function Utils:GetQuestLogTitleCheck(index, ...)
        return _G["QuestLogScrollFrameButton" .. index .. "Check"]
    end

    local prefix
    local QuestLogTitleButton_Resize = QuestLogTitleButton_Resize
    function QuestOverlayUI:UpdateQuestTitle(questLogTitleFrame, playButton, normalText, questCheck)
        if not prefix then
            local text = normalText:GetText()
            for i = 1, 20 do
                normalText:SetText(string.rep(" ", i))
                if normalText:GetStringWidth() >= 24 then
                    prefix = normalText:GetText()
                    break
                end
            end
            prefix = prefix or "  "
            normalText:SetText(text)
        end

        playButton:SetPoint("LEFT", normalText, "LEFT", 4, 0)
        normalText:SetText(prefix .. (normalText:GetText() or ""):trim())
        QuestLogTitleButton_Resize(questLogTitleFrame)
    end

    hooksecurefunc(Addon, "OnInitialize", function(...)
        QuestLogScrollFrame.update = QuestLog_Update
    end)

    function hookModel(self, ...)
        local function HasModelLoaded(self, ...)
            local model = self:GetModel()
            return model and type(model) == "string" and self:GetModelFileID() ~= 130737
        end
        self._sequence = 0
        hooksecurefunc(self, "ClearModel", function(self, ...)
            self._awaitingModel = nil
            self._camera = nil
            self._sequence = 0
            self._sequenceStart = nil
        end)
        local oldSetSequence = self.SetSequence
        function self:SetSequence(sequence, ...)
            self._sequence = sequence
            self._sequenceStart = GetTime()
            if not self._awaitingModel then
                oldSetSequence(self, sequence)
            end
        end
        local oldSetCreature = self.SetCreature
        function self:SetCreature(id, ...)
            self:ClearModel()
            self:SetModel([[Interface\Buttons\TalkToMeQuestion_White.mdx]])
            oldSetCreature(self, id)
            self._awaitingModel = not HasModelLoaded(self)
        end
        local oldSetCamera = self.SetCamera
        function self:SetCamera(id, ...)
            self._camera = id
            if not self._awaitingModel then
                oldSetCamera(self, id)
            end
        end
        self:HookScript("OnUpdate", function(self, elapsed)
            if self._awaitingModel and HasModelLoaded(self) then
                self._awaitingModel = nil
                self:SetModelScale(2)
                self:SetPosition(0, 0, 0)

                if self._sequence ~= 0 then
                    self:SetSequence(self._sequence)
                end
            elseif self._awaitingModel then
                self:SetModelScale(0.71 / self:GetEffectiveScale())
                self:SetPosition(5 * self:GetModelScale(), 0, 2 * self:GetModelScale())
            end
            if self._sequence ~= 0 and not self._awaitingModel then
                self:SetSequenceTime(self._sequence, (GetTime() - self._sequenceStart) * 1000)
            end
        end)
    end

    hooksecurefunc(SoundQueueUI, "InitPortrait", function(self, ...)
        self.frame.portrait.pause:HookScript("OnEnter", function(...)
            if self.frame.portrait.model._awaitingModel then
                GameTooltip:SetOwner(self.frame.portrait.pause, "ANCHOR_NONE")
                GameTooltip:SetPoint("BOTTOMLEFT", self.frame.portrait.pause, "BOTTOMRIGHT", 4, -4)
                GameTooltip:SetText("Uncached NPC", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
                GameTooltip:AddLine("Encounter this NPC in the world again to be able to see their model.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
                GameTooltip:Show()
            end
        end)
        self.frame.portrait.pause:HookScript("OnLeave", GameTooltip_Hide)
    end)

end
if Version.IsRetailVanilla then

    GetGossipText = C_GossipInfo.GetText
    GetNumGossipActiveQuests = C_GossipInfo.GetNumActiveQuests
    GetNumGossipAvailableQuests = C_GossipInfo.GetNumAvailableQuests
    
    function Addon.OnAddonLoad.Leatrix_Plus(...)
        C_Timer.After(0, function(...) -- Let it run its ADDON_LOADED code
            hooksecurefunc("QuestLog_Update", function(...)
                -- Update QuestOverlayUI again after Leatrix_Plus replaces the titles with prepended quest levels
                QuestOverlayUI:Update()
            end)
        end)
    end
    function Addon.OnAddonLoad.Guidelime(...)
        QuestLogFrame:HookScript("OnUpdate", function(...)
            -- Update QuestOverlayUI again after Guidelime decorates the titles
            QuestOverlayUI:Update()
        end)
    end

end
if Version.IsRetailWrath then

    GetGossipText = C_GossipInfo.GetText
    GetNumGossipActiveQuests = C_GossipInfo.GetNumActiveQuests
    GetNumGossipAvailableQuests = C_GossipInfo.GetNumAvailableQuests

    function Utils:GetQuestLogScrollOffset(...)
        return HybridScrollFrame_GetOffset(QuestLogListScrollFrame)
    end

    function Utils:GetQuestLogTitleFrame(index, ...)
        return _G["QuestLogListScrollFrameButton" .. index]
    end

    function Utils:GetQuestLogTitleNormalText(index, ...)
        return _G["QuestLogListScrollFrameButton" .. index .. "NormalText"]
    end

    function Utils:GetQuestLogTitleCheck(index, ...)
        return _G["QuestLogListScrollFrameButton" .. index .. "Check"]
    end

    local QuestLogTitleButton_Resize = QuestLogTitleButton_Resize -- Store original function before LeatrixPlus's "Enhance quest log" hooks into it
    local prefix
    function QuestOverlayUI:UpdateQuestTitle(questLogTitleFrame, playButton, normalText, questCheck)
        if not prefix then
            local text = normalText:GetText()
            for i = 1, 20 do
                normalText:SetText(string.rep(" ", i))
                if normalText:GetStringWidth() >= 24 then
                    prefix = normalText:GetText()
                    break
                end
            end
            prefix = prefix or "  "
            normalText:SetText(text)
        end

        playButton:SetPoint("LEFT", normalText, "LEFT", 4, 0)
        normalText:SetText(prefix .. (normalText:GetText() or ""):trim())
        QuestLogTitleButton_Resize(questLogTitleFrame)
    end

    hooksecurefunc(Addon, "OnInitialize", function(...)
        QuestLogListScrollFrame.update = QuestLog_Update
    end)

    function Addon.OnAddonLoad.Guidelime(...)
        QuestLogFrame:HookScript("OnUpdate", function(...)
            -- Update QuestOverlayUI again after Guidelime decorates the titles
            QuestOverlayUI:Update()
        end)
    end

end
if Version.IsRetailMainline then

    GetGossipText = C_GossipInfo.GetText
    GetNumGossipActiveQuests = C_GossipInfo.GetNumActiveQuests
    GetNumGossipAvailableQuests = C_GossipInfo.GetNumAvailableQuests

    function Utils:GetCurrentModelSet(...)
        return "HD"
    end

end
