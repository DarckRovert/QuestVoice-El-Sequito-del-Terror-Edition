import os
import re

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'

for filename in os.listdir(root_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(root_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content

        # 1. Eliminar el print de telemetría que se insertó ANTES de que AceGUI exista
        #    Patrón: linea de print justo después de local Type, Version
        new_content = re.sub(
            r'(local Type, Version = "[^"]+", \d+)\r?\nprint\("[^"]+"\s*\.\.\s*Type\)\r?\n',
            r'\1\n',
            new_content
        )

        # 2. Revertir el reemplazo del if-not-AceGUI que rompía la secuencia
        new_content = new_content.replace(
            '-- Forzado: Registro obligatorio\nif not AceGUI then print("|cffff0000AceGUI Error:|r No se encontró AceGUI al cargar " .. (Type or "Widget")); return end',
            'if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end'
        )

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Saneado (telemetría retirada): {filename}")
        else:
            print(f"Sin cambios: {filename}")
