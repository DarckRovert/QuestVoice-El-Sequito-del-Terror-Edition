import os

developer = "DarckRovert"
year = "2026"
repo_url = "https://github.com/DarckRovert/QuestVoice-El-Sequito-del-Terror-Edition"
twitch_url = "https://twitch.tv/darckrovert"

files = {
    "LICENSE": f"""MIT License

Copyright (c) {year} {developer}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.""",

    "README.md": f"""# QuestVoice [Séquito del Terror Edition]

![Diamond Tier Addon](https://img.shields.io/badge/Tier-Diamond-cyan?style=for-the-badge)
![Lua 5.0](https://img.shields.io/badge/Client-WoW%201.12-blue?style=for-the-badge)
![Turtle WoW](https://img.shields.io/badge/Server-Turtle%20WoW-green?style=for-the-badge)

**QuestVoice** es el motor definitivo de inmersión para **Turtle WoW**, integrando VoiceOver, navegación avanzada y optimización de arquitectura reactiva bajo estándares de alto rendimiento ("Diamond-Tier").

## 💎 Características Principales
- **Arquitectura Privatizada**: Motor Ace3 independiente para evitar conflictos con otros addons (pfQuest, BigWigs).
- **Sanación de Redundancias**: Eliminación de crasheos por inyección de código moderno en Lua 5.0.
- **VoiceOver Integrado**: Narración dinámica de quest de Turtle WoW.
- **Diamond-Tier Stability**: Cero errores en los logs de interfaz.

## 🚀 Instalación
1. Descarga la última versión estable.
2. Extrae en `Interface\\AddOns\\QuestVoice`.
3. Disfruta de una experiencia totalmente inmersiva.

## 📺 Community & Support
Síguenos en las plataformas oficiales para actualizaciones y desarrollo en vivo:
- [Twitch]({twitch_url})
- [GitHub]({repo_url})

## 📜 Licencia
Este proyecto está bajo la [Licencia MIT](LICENSE).""",

    "CONTRIBUTING.md": f"""# Contribuyendo a QuestVoice

Agradecemos tu interés en mejorar este addon. Para mantener el estándar **Diamond-Tier**, sigue estas guías:

1. **Lua 5.0**: Prohibido el uso de operadores modernos (`#`, `...` sin polyfill, etc.).
2. **Pull Requests**: Deben incluir una descripción técnica detallada.
3. **Estilo**: Sigue la coherencia de marca de DarckRovert.

Visítanos en [Twitch]({twitch_url}) para discutir cambios arquitecturales.""",

    "CODE_OF_CONDUCT.md": "Code of Conduct - Standard DarckRovert Diamond-Tier Protocol applies.",
    "SECURITY.md": "Report security issues via private message to DarckRovert or via GitHub Issues.",
    "CHANGELOG.md": "# Changelog\n\n## [1.0.1] - 2026-04-10\n### Fixed\n- Privatización de arquitectura Ace3 (QuestVoice_AceGUI).\n- Eliminación total de BackdropTemplate en 1.12.\n- Arreglo de handlers de eventos (contexto 'this').\n- Saneamiento de LibStub y strings corruptas.",
}

root = r"e:\Turtle Wow\Interface\AddOns\QuestVoice"
for name, content in files.items():
    with open(os.path.join(root, name), 'w', encoding='utf-8') as f:
        f.write(content)

# Crear Wiki
wiki_dir = os.path.join(root, "wiki")
if not os.path.exists(wiki_dir):
    os.makedirs(wiki_dir)

wiki_files = {
    "Arquitectura.md": "# Arquitectura Diamond-Tier\n\nQuestVoice usa una instancia privada de AceGUI para garantizar 0 conflictos ambientales.",
    "Guía_API.md": "# Guía de API\n\nDocumentación para desarrolladores de módulos de datos.",
    "Manual_Usuario.md": "# Manual de Usuario\n\nGuía de configuración rápida via `/vo` o el menú de Interface.",
}

for name, content in wiki_files.items():
    with open(os.path.join(wiki_dir, name), 'w', encoding='utf-8') as f:
        f.write(content)

print("Suite de gobernanza y Wiki institucional creadas.")
