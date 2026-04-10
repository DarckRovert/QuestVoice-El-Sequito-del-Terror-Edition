# QuestVoice [Séquito del Terror Edition]

![Diamond Tier Addon](https://img.shields.io/badge/Tier-Diamond-cyan?style=for-the-badge)
![Lua 5.0](https://img.shields.io/badge/Client-WoW%201.12-blue?style=for-the-badge)
![Turtle WoW](https://img.shields.io/badge/Server-Turtle%20WoW-green?style=for-the-badge)
![License](https://img.shields.io/github/license/DarckRovert/QuestVoice-El-Sequito-del-Terror-Edition?style=for-the-badge)

**QuestVoice** es el motor narrativo y sistema de navegación definitivo para el ecosistema de **Turtle WoW**, portado con precisión técnica a World of Warcraft Vanilla (1.12) bajo estrictos estándares de rendimiento ("Diamond-Tier"). Esta herramienta reemplaza los aburridos muros de texto de las misiones brindando *VoiceOver* dinámico, junto a una interfaz libre de conflictos de memoria.

## 💎 Arquitectura y Soluciones Críticas Implementadas

1. **Aislamiento Nativo y Privatización `Ace3`**: 
   Todo el set de bibliotecas de interfaz (como *AceGUI* y *AceConfigDialog*) fueron abandonados y refactorizados a marcos visuales crudos de WoW Vanilla (Lua 5.0). El Addon fue desconectado de métodos globales inestables para evitar choques en memoria con otros complementos macroestructurales de Turtle WoW.

2. **Resolución de Silencio por Interrupción del Motor FMOD**: 
   Reparamos un bug catastrófico oculto de los clientes antiguos (1.12): La supresión de falsos "mutes" mediante `SetCVar("EnableSound", 0)`, lo cual reseteaba el motor de audio subyacente impidiendo la reproducción de cualquier voz en milisegundos consecuentes. **QuestVoice ahora garantiza entrega y ejecución ininterrumpida** de colas de sonido de NPCs convencionales.

3. **Limitaciones Técnicas con NPCs Custom**: 
   Si lees el error en chat `Sound does not exist for: [Nombre]`, significa que el interceptor lógico del Addon capturó la conversación exitosamente, pero dicho NPC es un personaje *custom* introducido por Turtle WoW y **NO existe data** de Text-to-Speech (MP3 generados) proveída en las librerías `DataModules`. Para solucionarlo, deberás instalar un pack local extendido que incluya audios customizados para el texto modificado The Turtle Dev Team.

---

## 🚀 Instalación Simple

1. Descarga el _Release_ estable.
2. Descomprime la carpeta completa dentro del trayecto tu cliente: `E:\Turtle Wow\Interface\AddOns\QuestVoice\`
3. Si lo requieres, descarga el **VoicePack (1.25 GB)** desde la sección de **[Releases](https://github.com/DarckRovert/QuestVoice-El-Sequito-del-Terror-Edition/releases)** y extráelo en la subcarpeta `data/generated/sounds/`.
4. Disfruta de un Vanilla con vida.

## 🔈 Descargas de Voces (Releases)
Debido a que el paquete de audio fonético completo pesa más de 1 GB, el repositorio de código se mantiene ligero. Debes descargar el pack de sonidos por separado para habilitar el VoiceOver:
- [📥 Descargar VoicePack v1.0 [1.25 GB]](https://github.com/DarckRovert/QuestVoice-El-Sequito-del-Terror-Edition/releases)

## 🛠️ Comandos Diagnósticos Embebidos
- `/vo` - Muestra la interfaz nativa del UI de Opciones.
- `/voresume` - Reanuda forzadamente de la pausa en la cola actual.
- `/voclear` - Vacía brutalmente y purga audios atascados del VoiceQueue.
- `/votest` - Lanza una prueba técnica de la ruta del archivo asegurando que FMOD puede leer MP3.

---

## 📺 Ecosistema y Soporte
Conecta con la comunidad para desarrollo en vivo, dudas de arquitectura, expansiones de packs TTS o simplemente saludar:
- [🔴 DarckRovert en Twitch](https://twitch.tv/darckrovert)
- [📘 Portal Open Source (QuestVoice Wiki Oficial)](https://github.com/DarckRovert/QuestVoice-El-Sequito-del-Terror-Edition/wiki)

## 📜 Licencia
Diseño y código amparados bajo los términos de permiso abierto expresados en la [Licencia MIT](LICENSE) (2026). Todos los emuladores, parches lógicos de compatibilidad para Cliente 1.12 y documentación fueron elaborados exclusivamente por **DarckRovert**.