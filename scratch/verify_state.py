import os
import re

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'

for filename in os.listdir(root_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(root_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content

        # Reemplazar la obtención de AceGUI via LibStub con acceso directo al objeto global
        # ya establecido por AceGUI-3.0.lua (que se carga primero en el XML)
        # ANTES: local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
        # DESPUÉS: local AceGUI = LibStub and LibStub("AceGUI-3.0", true) or _G["AceGUI30"]
        # También eliminar la condición de versión ya eliminada anteriormente

        # Asegurar que si LibStub falla, se use el objeto directo
        old_pattern = r'local AceGUI = LibStub and LibStub\("AceGUI-3\.0", true\)\r?\nif not AceGUI then return end\r?\n-- Forzar re-registro para asegurar compatibilidad con 1\.12'
        new_str = 'local AceGUI = LibStub and LibStub("AceGUI-3.0", true)\nif not AceGUI then return end\n-- Registro forzado: sin check de versión para compatibilidad con 1.12'
        
        new_content = re.sub(old_pattern, new_str, new_content)

        # Patrón alternativo si no hubo el comentario exacto
        old_pattern2 = r'local AceGUI = LibStub\("AceGUI-3\.0"\)\r?\n(?!if not AceGUI)'
        new_str2 = 'local AceGUI = LibStub("AceGUI-3.0")\nif not AceGUI then return end\n-- Registro forzado: sin check de versión para compatibilidad con 1.12\n'
        new_content = re.sub(old_pattern2, new_str2, new_content)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Verificado: {filename}")
        else:
            print(f"Sin necesidad de cambio: {filename}")
