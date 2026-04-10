setfenv(1, VoiceOver)

---@class Addon : AceAddon, AceAddon-3.0, AceEvent-3.0, AceTimer-3.0
---@field db VoiceOverConfig|AceDBObject-3.0
Addon = LibStub("AceAddon-3.0"):NewAddon("VoiceOver", "AceEvent-3.0", "AceTimer-3.0")

Addon.OnAddonLoad = {}

---@class VoiceOverConfig
local defaults = {
    profile = {
        SoundQueueUI = {
            LockFrame = false,
            FrameScale = 0.7,
            FrameStrata = "HIGH",
            HidePortrait = false,
            HideFrame = false,
        },
        Audio = {
            GossipFrequency = Enums.GossipFrequency.OncePerQuestNPC,
            SoundChannel = Enums.SoundChannel.Master,
            AutoToggleDialog = true,
            StopAudioOnDisengage = false,
        },
        MinimapButton = {
            LibDBIcon = {}, -- Table used by LibDBIcon to store position (minimapPos), dragging lock (lock) and hidden state (hide)
            Commands = {
                -- References keys from Options.table.args.SlashCommands.args table
                LeftButton = "Options",
                MiddleButton = "PlayPause",
                RightButton = "Clear",
            }
        },
        DebugEnabled = false,
    },
    char = {
        IsPaused = false,
        hasSeenGossipForNPC = {},
        RecentQuestTitleToID = {},
    }
}

local lastGossipOptions
local selectedGossipOption
local currentQuestSoundData
local currentGossipSoundData

function Addon:OnInitialize(...)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccQuestVoice:|r Cargando arquitectura [Séquito del Terror]...")
    
    self.db = LibStub("AceDB-3.0"):New("VoiceOverDB", defaults)
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

    StaticPopupDialogs["VOICEOVER_ERROR"] =
    {
        text = "VoiceOver|n|n%s",
        button1 = OKAY,
        timeout = 0,
        whileDead = 1,
    }

    SoundQueueUI:Initialize()
    
    -- Manejo de errores para prevenir que un crash en módulos detenga las opciones
    pcall(function(...) DataModules:EnumerateAddons() end)
    
    if QuestVoiceData then
        local ok, err = pcall(function(...) VoiceOver.DataModules:Register("QuestVoice", QuestVoiceData) end)
        if not ok then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000QuestVoice Error:|r Registro de datos fallido: " .. tostring(err))
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000QuestVoice Error:|r [Base de Datos] No detectada. Revisa la carpeta Data.")
    end

    local ok, err = pcall(function(...) Options:Initialize() end)
    if not ok then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000QuestVoice Error:|r Error en Interfaz: " .. tostring(err))
    end


    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("QUEST_DETAIL")
    -- self:RegisterEvent("QUEST_PROGRESS")
    self:RegisterEvent("QUEST_COMPLETE")
    self:RegisterEvent("QUEST_GREETING")
    self:RegisterEvent("QUEST_FINISHED")
    self:RegisterEvent("GOSSIP_SHOW")
    self:RegisterEvent("GOSSIP_CLOSED")

    if not DataModules:HasRegisteredModules() then
        StaticPopupDialogs["VOICEOVER_NO_REGISTERED_DATA_MODULES"] =
        {
            text = [[QuestVoice|n|nNo sound packs were found.|n|nAsegúrate de que la carpeta de datos exista y esté activada.]],
            button1 = OKAY,
            timeout = 0,
            whileDead = 1,
        }
        StaticPopup_Show("VOICEOVER_NO_REGISTERED_DATA_MODULES")
    end

    local function MakeAbandonQuestHook(field, getFieldData)
        return function(...)
            local data = getFieldData()
            local soundsToRemove = {}
            for _, soundData in pairs(SoundQueue.sounds) do
                if Enums.SoundEvent:IsQuestEvent(soundData.event) and soundData[field] == data then
                    table.insert(soundsToRemove, soundData)
                end
            end

            for _, soundData in pairs(soundsToRemove) do
                SoundQueue:RemoveSoundFromQueue(soundData)
            end
        end
    end
    if AbandonQuest then
        hooksecurefunc("AbandonQuest", MakeAbandonQuestHook("questName", function(...) return GetAbandonQuestName() end))
    end

    if QuestLog_Update then
        hooksecurefunc("QuestLog_Update", function(...)
            QuestOverlayUI:Update()
        end)
    end

    if SelectGossipOption then
        hooksecurefunc("SelectGossipOption", function(index, ...)
            if lastGossipOptions then
                selectedGossipOption = lastGossipOptions[1 + (index - 1) * 2]
                lastGossipOptions = nil
            end
        end)
    end
end

function Addon:RefreshConfig(...)
    SoundQueueUI:RefreshConfig()
end

function Addon:ADDON_LOADED(event, addon)
    addon = addon or arg1 -- Thanks, Ace3v...
    local hook = self.OnAddonLoad[addon]
    if hook then
        hook()
    end
end

local function GossipSoundDataAdded(soundData, ...)
    Utils:CreateNPCModelFrame(soundData)

    -- Save current gossip sound data for dialog/frame sync option
    currentGossipSoundData = soundData
end

local function QuestSoundDataAdded(soundData, ...)
    Utils:CreateNPCModelFrame(soundData)

    -- Save current quest sound data for dialog/frame sync option
    currentQuestSoundData = soundData
end

local GetTitleText = GetTitleText -- Store original function before EQL3 (Extended Quest Log 3) overrides it and starts prepending quest level
function Addon:QUEST_DETAIL(...)
    local questID = GetQuestID()
    local questTitle = GetTitleText()
    local questText = GetQuestText()
    local guid = Utils:GetNPCGUID()
    local targetName = Utils:GetNPCName()

    if not questID or questID == 0 then
        return
    end

    -- Can happen if the player interacted with an NPC while having main menu or options opened
    if not guid and not targetName then
        return
    end

    if Addon.db.char.RecentQuestTitleToID and questID ~= 0 then
        Addon.db.char.RecentQuestTitleToID[questTitle] = questID
    end

    local type = guid and Utils:GetGUIDType(guid)
    if type == Enums.GUID.Item then
        -- Allow quests started from items to have VO, book icon will be displayed for them
    elseif not type or not Enums.GUID:CanHaveID(type) then
        -- If the quest is started by something that we cannot extract the ID of (e.g. Player, when sharing a quest) - try to fallback to a questgiver from a module's database
        local id
        type, id = DataModules:GetQuestLogQuestGiverTypeAndID(questID)
        guid = id and Enums.GUID:CanHaveID(type) and Utils:MakeGUID(type, id) or guid
        targetName = id and DataModules:GetObjectName(type, id) or targetName or "Unknown Name"
    end

    -- print("QUEST_DETAIL", questID, questTitle);
    ---@type SoundData
    local soundData = {
        event = Enums.SoundEvent.QuestAccept,
        questID = questID,
        name = targetName,
        title = questTitle,
        text = questText,
        unitGUID = guid,
        unitIsObjectOrItem = Utils:IsNPCObjectOrItem(),
        addedCallback = QuestSoundDataAdded,
    }
    SoundQueue:AddSoundToQueue(soundData)
end

function Addon:QUEST_COMPLETE(...)
    local questID = GetQuestID()
    local questTitle = GetTitleText()
    local questText = GetRewardText()
    local guid = Utils:GetNPCGUID()
    local targetName = Utils:GetNPCName()

    if not questID or questID == 0 then
        return
    end

    -- Can happen if the player interacted with an NPC while having main menu or options opened
    if not guid and not targetName then
        return
    end

    if Addon.db.char.RecentQuestTitleToID and questID ~= 0 then
        Addon.db.char.RecentQuestTitleToID[questTitle] = questID
    end

    -- print("QUEST_COMPLETE", questID, questTitle);
    ---@type SoundData
    local soundData = {
        event = Enums.SoundEvent.QuestComplete,
        questID = questID,
        name = targetName,
        title = questTitle,
        text = questText,
        unitGUID = guid,
        unitIsObjectOrItem = Utils:IsNPCObjectOrItem(),
        addedCallback = QuestSoundDataAdded,
    }
    SoundQueue:AddSoundToQueue(soundData)
end

function Addon:ShouldPlayGossip(guid, text)
    local npcKey = guid or "unknown"

    local gossipSeenForNPC = self.db.char.hasSeenGossipForNPC[npcKey]

    if self.db.profile.Audio.GossipFrequency == Enums.GossipFrequency.OncePerQuestNPC then
        local numActiveQuests = GetNumGossipActiveQuests()
        local numAvailableQuests = GetNumGossipAvailableQuests()
        local npcHasQuests = (numActiveQuests > 0 or numAvailableQuests > 0)
        if npcHasQuests and gossipSeenForNPC then
            return
        end
    elseif self.db.profile.Audio.GossipFrequency == Enums.GossipFrequency.OncePerNPC then
        if gossipSeenForNPC then
            return
        end
    elseif self.db.profile.Audio.GossipFrequency == Enums.GossipFrequency.Never then
        return
    end

    return true, npcKey
end

function Addon:QUEST_GREETING(...)
    local guid = Utils:GetNPCGUID()
    local targetName = Utils:GetNPCName()
    local greetingText = GetGreetingText()

    -- Can happen if the player interacted with an NPC while having main menu or options opened
    if not guid and not targetName then
        return
    end

    local play, npcKey = self:ShouldPlayGossip(guid, greetingText)
    if not play then
        return
    end

    -- Play the gossip sound
    ---@type SoundData
    local soundData = {
        event = Enums.SoundEvent.QuestGreeting,
        name = targetName,
        text = greetingText,
        unitGUID = guid,
        unitIsObjectOrItem = Utils:IsNPCObjectOrItem(),
        addedCallback = GossipSoundDataAdded,
        startCallback = function(...)
            self.db.char.hasSeenGossipForNPC[npcKey] = true
        end
    }
    SoundQueue:AddSoundToQueue(soundData)
end

function Addon:GOSSIP_SHOW(...)
    local guid = Utils:GetNPCGUID()
    local targetName = Utils:GetNPCName()
    local gossipText = GetGossipText()

    -- Can happen if the player interacted with an NPC while having main menu or options opened
    if not guid and not targetName then
        return
    end

    local play, npcKey = self:ShouldPlayGossip(guid, gossipText)
    if not play then
        return
    end

    -- Play the gossip sound
    ---@type SoundData
    local soundData = {
        event = Enums.SoundEvent.Gossip,
        name = targetName,
        title = selectedGossipOption and format([["%s"]], selectedGossipOption),
        text = gossipText,
        unitGUID = guid,
        unitIsObjectOrItem = Utils:IsNPCObjectOrItem(),
        addedCallback = GossipSoundDataAdded,
        startCallback = function(...)
            self.db.char.hasSeenGossipForNPC[npcKey] = true
        end
    }
    SoundQueue:AddSoundToQueue(soundData)

    selectedGossipOption = nil
    lastGossipOptions = nil
    if GetGossipOptions then
        lastGossipOptions = { GetGossipOptions() }
    end
end

function Addon:QUEST_FINISHED(...)
    if Addon.db.profile.Audio.StopAudioOnDisengage and currentQuestSoundData then
        SoundQueue:RemoveSoundFromQueue(currentQuestSoundData)
    end
    currentQuestSoundData = nil
end

function Addon:GOSSIP_CLOSED(...)
    if Addon.db.profile.Audio.StopAudioOnDisengage and currentGossipSoundData then
        SoundQueue:RemoveSoundFromQueue(currentGossipSoundData)
    end
    currentGossipSoundData = nil

    selectedGossipOption = nil
end
