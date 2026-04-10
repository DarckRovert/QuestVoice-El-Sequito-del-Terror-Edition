# 🛠️ Guía de API de QuestVoice

La extensibilidad del Addon radica en su capacidad para inyectar paquetes locales de audios "Text-To-Speech" (DataModules). Al ser un servidor custom, Turtle WoW frecuentemente introduce nuevos NPCs o modifica secuencias de Quest originales (Vanilla). 

## Estructura de DataModules (Registrar Archivos Nuevos)

Para cargar tu conjunto de traducciones (ej. Misiones Custom de El Séquito de Terror), el archivo TOC de tu paquete fonético debe invocar a la API principal del `QuestVoice`.

Ejemplo de `DataModule.lua`:
```lua
if not VoiceOver or not VoiceOver.DataModules then return end

-- 1. Crear un metadato de base local
MiAddonDeVoces = {}
AI_VoiceOverData_Vanilla = MiAddonDeVoces

-- 2. Declarar el enrutador físico
function MiAddonDeVoces:GetSoundPath(fileName, event)
    setfenv(1, VoiceOver)
    -- Enrutador Estándar 1.12 (Saneando M/F Prefix)
    fileName = string.gsub(fileName, "^[mf]%-", "")

    if Enums.SoundEvent:IsQuestEvent(event) then
        return format([[data\generated\sounds\quests\%s.mp3]], fileName)
    elseif Enums.SoundEvent:IsGossipEvent(event) then
        return format([[data\generated\sounds\gossip\%s.mp3]], fileName)
    end
end
```

## Interacción con `VoiceOver`
Cualquier otro motor que intente disparar o interrogar VoiceOver en 1.12, debe depender estrictamente de:
```lua
-- Obtener manejador
local Addon = LibStub("AceAddon-3.0"):GetAddon("VoiceOver")
if Addon then
    -- Registrar Módulo
    Addon.DataModules:Register("NombreDeTuModulo", MiAddonDeVoces)
end
```