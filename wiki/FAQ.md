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

## > La flecha indicadora de misiones (Arrow) desapareció
*Síntoma: La flecha que apunta a los objetivos dejó de mostrarse o su texto dice `???`.*

**Causa y Solución 1 (General/Todos los idiomas):** Esto ocurría por una asincronía de carga entre `QuestVoice` y el addon `pfUI`. Las nuevas traducciones chinas de `pfUI` retrasaban la inyección de fuentes, provocando que la flecha colapsara al inicializarse antes de tiempo. En la versión **1.0.1** este problema ha sido mitigado mediante recarga dinámica de fuentes y verificaciones *anti-nil*.

**Causa y Solución 2 (Específico de clientes en Español/esMX):** Anteriormente, si el juego estaba en español, la flecha de la misión podía no aparecer debido a que el texto exacto de la misión devuelto por el juego no coincidía letra por letra con las bases de datos internas (errores de codificación de tildes o eñes en `quests-turtle.lua`). En la versión **1.0.3**, `pfQuest` ahora usa el **ID numérico nativo** detectado por el motor de `QuestVoice`, solucionando definitivamente las fallas de coincidencia de texto para los clientes en español. Si el error persiste, asegúrate de tener la versión 1.0.3 o superior instalada.
