# Changelog: QuestVoice [Séquito del Terror Edition]

Todas las versiones desplegadas para la base de código documentarán aquí la escalabilidad asimétrica y la portabilidad para cliente vainilla (World of Warcraft 1.12.1).

El formato del registro de versiones se basa en Convenciones Semánticas para mantener trazabilidad estructural.

## [1.0.2] - 2026-05-28
### Añadido
- **🧠 Integración God-Tier (WCS_Brain)**: Los eventos narrativos de `QUEST_DETAIL` y `QUEST_GREETING` ahora se transmiten al motor neuronal `WCS_Brain`. Esto permite que tu mascota (Brujo/Cazador) entienda la misión que estás leyendo y reaccione contextualmente a las palabras clave (matar, cazar, proteger) mientras la voz se reproduce.

## [1.0.1] - 2026-05-27
### Corregido
- **[CRITICAL HOTFIX] pfUI Font Desync (Arrow Disappearance)**: Añadidos fallbacks de seguridad (`pfUI_config.global.font_size`) durante el Parse-Time del AddOn y una recarga dinámica inteligente de fuentes asiáticas (`ZYHei`, `FZXHLJW`) introducidas por las traducciones de Turtle WoW mediante `WoWTranslate.dll`. La flecha de misiones (Route Arrow) ahora renderiza el texto chino dinámicamente y previene crasheos si `pfUI` es modificado.

## [1.0.0] Diamond-Tier Native Optimization - 2026-04-10

### Añadido (`Added`)
- Menú Options nativo para configuraciones en WoW Vanilla.
- Slash commands duros en el espacio global `_G` para aislar bugs del marco AceConfig (`/vo`, `/voclear`, `/voresume`, `/votest`).
- Generación de insignias estéticas de estado en Suite de Go-live en GitHub.

### Modificado (`Changed`)
- Re-enrutamientos y sanaciones estrictas dependientes de librerías como *AceGUI-3.0*, excluyendo el renderizado por bloques.
- Desacople completo entre interfaces interactivas dependientes del objeto UI primario de BlizOptions.

### Removido (`Removed`)
- **[CRITICAL HOTFIX]**: Deshecho el manipulador lógico del comando `SetCVar("EnableSound")`. Originalmente reseteaba el motor de audio FMOD silenciosamente y destruía la entrega del PlaySoundFile para todos los archivos generados.
- Fragmentos redundantes de la suite *AceConsole-3.0* obsoleta que provocaba colgar o congelar la consola al disparar metadatos inexistentes.
- `table.getn` remplazado algorítmicamente y funciones no existentes en `Lua 5.0` (`#` op).

### Soporte a la Base Creada
- Repositorio reconfigurado formalmente para la rama GitHub DarckRovert.