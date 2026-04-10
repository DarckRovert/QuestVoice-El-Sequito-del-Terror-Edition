import os
import re

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'

for filename in os.listdir(root_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(root_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content

        # Patrón 1: local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
        # Reemplazar por: uso de QuestVoice_AceGUI con fallback a LibStub
        new_content = re.sub(
            r'local AceGUI = LibStub and LibStub\("AceGUI-3\.0",\s*true\)',
            'local AceGUI = QuestVoice_AceGUI or (LibStub and LibStub("AceGUI-3.0", true))',
            new_content
        )

        # Patrón 2: local AceGUI = LibStub("AceGUI-3.0") (sin true)
        new_content = re.sub(
            r'local AceGUI = LibStub\("AceGUI-3\.0"\)(?!\s*if)',
            'local AceGUI = QuestVoice_AceGUI or LibStub("AceGUI-3.0")',
            new_content
        )

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Actualizado acceso a AceGUI: {filename}")
        else:
            print(f"Sin cambios: {filename}")
