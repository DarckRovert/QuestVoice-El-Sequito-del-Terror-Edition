# Changelog: QuestVoice [Séquito del Terror Edition]

Todas las versiones desplegadas para la base de código documentarán aquí la escalabilidad asimétrica y la portabilidad para cliente vainilla (World of Warcraft 1.12.1).

El formato del registro de versiones se basa en Convenciones Semánticas para mantener trazabilidad estructural.

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