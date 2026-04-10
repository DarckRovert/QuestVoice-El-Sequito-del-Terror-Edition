# 🤝 Contribuir a QuestVoice

Bienvenido al repositorio open source **QuestVoice [Séquito del Terror Edition]** liderado por [DarckRovert](https://github.com/DarckRovert). Valoramos el código optimizado, los parches estables y una arquitectura sin conflictos para nuestra querida comunidad de Turtle WoW.

Para garantizar la pureza "Diamond-Tier" de este complemento, por favor sigue rigurosamente los siguientes lineamientos antes de abrir un Pull Request (PR):

## ⚖️ 1. Estándar Funcional Vanilla (1.12)
Todo el ecosistema de este addon opera sobre un core estabilizado para World of Warcraft 1.12 (Vanilla).
- Es imperativo escribir el código restringiéndose estricta y puramente a **Lua 5.0**.
- **Prohibido** usar azúcar sintáctico de expansiones posteriores (ej. el operador rápido de longitud de tabla `#` o `math.huge`). Emplea la sintaxis arcaica `table.getn(...)`.

## 🛡️ 2. Aislamiento Estricto de Librerías
Este proyecto superó la barrera de colisiones de librerías independizando internamente sus herramientas principales (como variables embebidas _G). 
- No inyectar nuevas versiones pre-compiladas de *Ace3*.
- Se prohíbe explícitamente re-habilitar enrutamiento globalizado (No importar `AceConfigDialog`, todo panel debe estar escrito directamente contra la API de frame de WoW `CreateFrame`).

## 🔈 3. Expansión de Paquetes de Voz (DataModules)
Si generaste audios TTS usando ElevenLabs, Azure, u otro proveedor local para las misiones exclusivas (custom) de Turtle WoW:
1. Extrae los hashes exactos de los NPCs a una tabla separada bajo el formato `[Hash MD5 del texto] = Duración en Segundos`.
2. Empaqueta todo bajo el formato requerido internamente por `DataModules.lua` e inyéctalo sin alterar el motor principal de audio global `SoundQueue`.

## 📝 4. Nomenclatura del Commit
Formatea tu mensaje del commit en inglés/spanglish entendible, separando refactors estéticos de cambios en arquitectura. Ejemplos correctos:
- `fix(audio): previene silenciamiento del FMOD motor (EnableSound)`
- `feat(wiki): inyección de comandos en crudo para slash`
- `refactor(db): corrige fall-backs para NPC sin IDs`

Te invitamos a conectar o resolver dudas live interactuando con la comunidad en [Twitch.tv/darckrovert](https://twitch.tv/darckrovert).