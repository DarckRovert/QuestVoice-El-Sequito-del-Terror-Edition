# 📖 Manual de Usuario 

**QuestVoice (Universal Edition v1.1.0)** es una herramienta bilingüe diseñada para automatizar la narración de misiones en World of Warcraft (Vanilla 1.12).

## 🚀 Instalación y Configuración Bilingüe (Mono-Bundle)

QuestVoice se distribuye ahora como una **Universal Edition** única. Ya no es necesario descargar parches o packs de idiomas por separado; todo el ecosistema de audio (EN/ES) está pre-instalado en el núcleo.

### 1. Extracción Única
Descarga el archivo `QuestVoice_Universal_Edition_v1.1.0.zip` desde la sección de **Releases** y descomprímelo directamente en tu carpeta de AddOns.

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
No requiere configuración manual. El Addon detectará el idioma de tu cliente de juego al iniciar sesión y seleccionará el Pack de Audio correspondiente (Español o Inglés) automáticamente.

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
