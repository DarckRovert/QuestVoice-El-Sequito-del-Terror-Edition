# Política de Seguridad y Manejo de LUA Crashes

## Reporte Sensible

Si encuentras o detonas un fallo crítico de "Memory Leak", un Loop asincrónico infinito o una pantalla de error masiva generada por VoiceOver/QuestVoice que interfiera con la ejecución del cliente base de **WoW 1.12**, repórtalo explícitamente en el [GitHub oficial de DarckRovert](https://github.com/DarckRovert/QuestVoice-El-Sequito-del-Terror-Edition/issues).

## Reglas Obligatorias de Reporte de Vulnerabilidad
1. **NO usar foros públicos** para reportar scripts abusivos o exploits derivados del SetCVar si logran interrumpir mecánicas ingame; utiliza el correo corporativo o mensaje privado vía [Twitch.tv/darckrovert](https://twitch.tv/darckrovert).
2. Debes adjuntar exactamente el extracto LUA que provocó el crash con parámetros, usualmente encontrado en `Logs\FrameXML.log`.
3. Informa el Addon con el que colisiona (por ejemplo superposiciones agresivas a nivel global `_G`).

## Versiones Soportadas
| Versión del Addon | Estado de Framework | Acción |
| --- | --- | --- |
| 1.0.x (Current) |  Soportado | Aplicar parches semanales Diamond-Tier  |
| < 1.0.0 (PfQuest) | No Soportado | Migrar Inmediatamente |

Todo reporte deberá incluir variables de configuración y qué entorno custom de *Turtle WoW* se estaba usando (Ej. DataModules inyectados).