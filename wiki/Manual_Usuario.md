# 📖 Manual de Usuario 

**QuestVoice (Universal Edition v1.1.0)** es una herramienta bilingüe diseñada para automatizar la narración de misiones en World of Warcraft (Vanilla 1.12) bajo estándares "Diamond-Tier".

## 🚀 Instalación y Configuración Bilingüe (Mono-Bundle)

> [!CAUTION]
> **DESCARGA EXTERNA OBLIGATORIA**: Debido al tamaño masivo de los activos de audio (3.2 GB+), el archivo debe descargarse desde el servidor de alta velocidad en Google Drive. El botón verde de "Code" de GitHub NO contiene los audios.

### 1. Extracción Única
Descarga el bundle maestro desde este enlace: [📥 **Descargar QuestVoice (Google Drive)**](https://drive.google.com/file/d/1n02xoc2FtzRHnmmOIX70QyFT-tDsYUUP/view?usp=sharing). Una vez descargado, descomprímelo dentro de tu carpeta de AddOns.

> [!IMPORTANT]
> **Nombre de Carpeta**: Asegúrate de que la carpeta resultante se llame exactamente `QuestVoice`. Si el extractor añade números o versiones al nombre de la carpeta (ej. `QuestVoice-v1.0`), el addon NO podrá resolver las rutas de sonido y el juego no lo cargará.

### 2. Estructura de Directorios
Tu estructura debe verse siempre así para garantizar el funcionamiento del motor:
```text
Interface/AddOns/
└── QuestVoice/
    ├── data/
    │   ├── generated/                 <-- Diccionarios base (EN)
    │   └── AI_VoiceOverData_Vanilla_esES/ <-- Diccionarios localizados (ES)
    ├── core/
    └── QuestVoice.toc
```

### 3. Detección Automática de Idioma
No requiere configuración manual. El Addon detectará el idioma de tu cliente de juego al iniciar sesión y seleccionará el Pack de Audio correspondiente (Español o Inglés) automáticamente mediante el sistema de prioridades dinámicas.

---

## 🎮 Cómo Utilizar
- Interactúa con cualquier NPC usando Click Derecho.
- La pantalla de "Detalles de Misión" silenciará la ambientación monótona e invocará la voz del actor.
- Ingresa `/vo` directamente en el chat para abrir el menú de opciones (Auto Toggle, Minimap Button, etc).

---

## 🛠️ Comandos de Diagnóstico (Globales)
En caso de que el audio se detenga o se "congele", utiliza estos comandos para purgar la cola:

- `/voclear`: Limpia la cola de sonidos. Útil si un audio se quedó trabado.
- `/voresume`: Obliga al Addon a regresar de una pausa de la cola sonora.
- `/votest`: Prueba crítica del motor FMOD. Si suena, el addon está correctamente instalado.
