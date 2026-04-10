if not VoiceOver or not VoiceOver.DataModules then return end

QuestVoiceData = {}
AI_VoiceOverData_Vanilla = QuestVoiceData

function QuestVoiceData:GetSoundPath(fileName, event)
    setfenv(1, VoiceOver)
    
    -- Turtle WoW / Séquito del Terror [HOTFIX]
    -- El generador inyecta "m-" en la tabla de longitudes, pero los archivos físicos
    -- en la base de datos de misiones carecen de prefijo de género (ej. 10-accept.mp3).
    -- Saneamos el nombre del archivo para garantizar el enrutamiento correcto.
    fileName = string.gsub(fileName, "^[mf]%-", "")

    if Enums.SoundEvent:IsQuestEvent(event) then
        return format([[data\generated\sounds\quests\%s.mp3]], fileName)
    elseif Enums.SoundEvent:IsGossipEvent(event) then
        return format([[data\generated\sounds\gossip\%s.mp3]], fileName)
    end
end

