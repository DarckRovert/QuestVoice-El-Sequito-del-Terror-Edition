# QuestVoice [Séquito del Terror Edition]
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
> **No descargues el repositorio como ZIP** (botón verde "Code"). Ese archivo NO contiene los datos de audio necesarios. **Descarga siempre desde la sección de [Releases](https://github.com/DarckRovert/QuestVoice-El-Sequito-del-Terror-Edition/releases).**

1. **Descarga el ZIP Maestro**: 
   - Busca el último archivo en Releases: `QuestVoice_v1.0.x.zip`.
2. **Instalación Directa**:
   - Extrae el contenido en: `\World of Warcraft\Interface\AddOns\`.
3. **Validación Crítica**:
   - > [!IMPORTANT]
     > La carpeta dentro de AddOns **debe llamarse exactamente `QuestVoice`**. Si al extraer se creó una carpeta con otro nombre (ej. `QuestVoice-v1.1`), **renómbrala a `QuestVoice`** o el addon no cargará.

---

## 💎 Soluciones Críticas Implementadas (Diamond-Tier)

1. **Fusión Monorepo Inteligente**: Hemos unificado los Voice Packs bilingües bajo un solo framework modular. El motor ahora detecta dinámicamente el idioma del cliente y selecciona los punteros de audio MP3 correspondientemente.
2. **Aislamiento Ace3 Nativo**: Se ha eliminado la dependencia de bibliotecas globales. QuestVoice utiliza un entorno protegido (`setfenv`) para evitar conflictos de memoria con otros Addons macroestructurales.
3. **Parche FMOD (CVar Rescue)**: Corregimos el crash silencioso del motor de audio de WoW 1.12 rescatando las llamadas a `Sound_EnableAllSound` cuando el sistema intenta vaciar la cola de reproducción.

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