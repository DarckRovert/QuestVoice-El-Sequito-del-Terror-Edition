# QuestVoice [Séquito del Terror Edition] v1.0.3
# 📚 Portal de Documentación y Gobernanza

![Diamond Tier Addon](https://img.shields.io/badge/Tier-Diamond-cyan?style=for-the-badge)
![Lua 5.0](https://img.shields.io/badge/Client-WoW%201.12-blue?style=for-the-badge)
![Turtle WoW](https://img.shields.io/badge/Server-Turtle%20WoW-green?style=for-the-badge)
![Documentation Only](https://img.shields.io/badge/Status-Docs--Only-lightgrey?style=for-the-badge)

**QuestVoice** es la solución definitiva de inmersión y navegación para **Turtle WoW**. Este repositorio actúa como el centro de control para la gobernanza, documentación técnica y manuales de usuario del proyecto. 

> [!IMPORTANT]
> **Repositorio de Solo Documentación:** Siguiendo los estándares de alto rendimiento "Diamond-Tier", el código fuente y los activos pesados del Addon se distribuyen exclusivamente de forma compilada para garantizar la estabilidad de los punteros de memoria en el cliente 1.12.

---

## 📥 Descarga e Instalación (Universal Mono-Bundle)

> [!CAUTION]
> **DESCARGA EXTERNA OBLIGATORIA**: Debido al tamaño masivo de los activos de audio (3.2 GB+), el archivo debe descargarse desde el servidor de alta velocidad en Google Drive. El botón verde de "Code" de GitHub NO contiene los audios.

1. **Descarga el ZIP Maestro**: 
   - [📥 **Descargar QuestVoice Universal Bundle (Google Drive)**](https://drive.google.com/file/d/1n02xoc2FtzRHnmmOIX70QyFT-tDsYUUP/view?usp=sharing)
2. **Instalación Directa**:
   - Extrae el contenido directamente en: `\World of Warcraft\Interface\AddOns\`.
3. **Validación Crítica**:
   - > [!IMPORTANT]
     > La carpeta dentro de AddOns **debe llamarse exactamente `QuestVoice`**. Si al extraer se creó una carpeta con otro nombre (ej. `QuestVoice-v1.0.x`), **renómbrala a `QuestVoice`** o el addon no podrá resolver las rutas de los archivos de sonido.

---

## 💎 Soluciones Críticas Implementadas (Diamond-Tier)

1. **Fusión Monorepo Inteligente**: Hemos unificado los Voice Packs bilingües bajo un solo framework modular. El motor ahora detecta dinámicamente el idioma del cliente y selecciona los punteros de audio MP3 correspondientemente.
2. **Aislamiento Ace3 Nativo**: Se ha eliminado la dependencia de bibliotecas globales. QuestVoice utiliza un entorno protegido (`setfenv`) para evitar conflictos de memoria con otros Addons macroestructurales.
3. **Parche FMOD (CVar Rescue)**: Corregimos el crash silencioso del motor de audio de WoW 1.12 rescatando las llamadas a `Sound_EnableAllSound` cuando el sistema intenta vaciar la cola de reproducción.
4. **Sincronización Dinámica de Fuentes**: (v1.0.1) Compatibilidad total con la inyección asíncrona de fuentes asiáticas (`WoWTranslate.dll`) del ecosistema `pfUI`, eliminando crasheos por desincronización de carga (`pfUI_config.global`).
5. **Rastreador de Misiones Hispano 100% Preciso**: (v1.0.3) Integración del puente neural `GetQuestLogTitle -> VoiceQuestID` que elimina las fallas de la flecha guía (Arrow) al jugar en clientes en español (esES/esMX), saltándose por completo las limitaciones de codificación de texto y errores ortográficos de las bases de datos de Vanilla.

---

## 🧠 WCS_Brain Integration [God-Tier]

> [!IMPORTANT]
> **Compatibilidad Neural Nativa:** Este AddOn expone sus eventos narrativos para ser analizados por **[WCS_Brain (El Núcleo Neuronal)](https://github.com/DarckRovert/WCS_Brain-v9.3.1-God-Tier)**. Tu mascota ahora es "consciente" del texto de la misión de QuestVoice, reaccionando de manera inmersiva a la trama (reaccionando a cacerías, recolecciones, etc.) en tiempo real.

---

## 📖 Documentación Técnica

Contamos con una base de conocimientos completa en nuestra Wiki corporativa para desarrolladores y usuarios avanzados:

- [🏗️ Arquitectura del Sistema](wiki/Arquitectura.md)
- [📘 Manual de Usuario](wiki/Manual_Usuario.md)
- [🛠️ Guía de Integración API](wiki/Guía_API.md)
- [❓ Preguntas Frecuentes (FAQ)](wiki/FAQ.md)

---

## 📺 Soporte y Comunidad

Conecta con el ecosistema de **DarckRovert** para obtener actualizaciones de packs de voces, sugerencias de nuevas funcionalidades o soporte técnico especializado:

- [🔴 Twitch Oficial](https://twitch.tv/darckrovert)
- [💻 Perfil de GitHub](https://github.com/DarckRovert)

---

## 📜 Licencia
Este proyecto y su documentación están bajo la [Licencia MIT](LICENSE) (2026). Todos los derechos de los parches lógicos de compatibilidad y el diseño de la Suite Terror están reservados a **DarckRovert**.