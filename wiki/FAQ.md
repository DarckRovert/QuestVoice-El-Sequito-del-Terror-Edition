# ❓ FAQ y Solución de Errores Comunes

Para la extensa mayoría de las fallas auditivas que pudiesen generarse usando ecosistemas Retro Vanilla, las fallas provienen del banco de datos, no del framework de LUA. Consulta este manual antes de considerar tu addon averiado.

## > ¿Por qué ciertos NPCs en Turtle WoW no hablan?
*Síntoma: Todo funciona pero un NPC solo dice su frase de Vanilla por defecto y en el chat dice "**QuestVoice - Sound does not exist for: Nombre**".*

**Causa:** Pese a que el motor interceptó la conversación correctamente, no encontró ningún archivo MP3 que asocie lingüísticamente lo dicho. "Justine Demalier", "Felicia" u "Ophelia Worthington" son NPCs exclusivos agregados por los dev de Turtle WoW de manera personalizada; no existen en el cliente original 1.12. Para adquirir su voz tendrás que aguardar a que El Séquito de Terror expanda o grabe una traducción TTS local de dichos NPCs e inyectarla.

## > Al abrir el mapa se pone opaco
*Pregunta: Al usar complementos externos de Zoom, el Addon interactúa mal.*

**Causa:** Mapeos de UI conflictivos en LUA 5.0. Utiliza `/vo` para ingresar al marco de herramientas y deshabilita temporalmente el "Play icon on Quests and Map".

## > Escribí /vo play y no sonó ningún locutor de prueba.
*Pregunta: Escribí el comando de la antigua versión (PfQuest) y este Addon ignora la petición.*

**Aclaratoria:** El comando original `play` únicamente funcionaba para "Des-pausar" un audio puesto previamente en espera en el banco (Queue). No es un "Reproductor" universal. Si deseas forzar una validación de audio técnico para detectar compatibilidad FMOD, hemos facilitado el comando puro: `/votest`.
