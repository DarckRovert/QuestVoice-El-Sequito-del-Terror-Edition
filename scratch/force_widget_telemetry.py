import os
import re

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'

for filename in os.listdir(root_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(root_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 1. Eliminar chequeo de versión para forzar registro
        # local AceGUI = ...
        # if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
        
        new_content = re.sub(r'if not AceGUI or \(AceGUI:GetWidgetVersion\(Type\) or 0\) >= Version then return end', 
                             r'-- Forzado: Registro obligatorio\nif not AceGUI then print("|cffff0000AceGUI Error:|r No se encontró AceGUI al cargar " .. (Type or "Widget")); return end', 
                             content)
        
        # 2. Inyectar telemetría de carga
        if "AceGUI:RegisterWidgetType" in new_content and "Cargando Widget:" not in new_content:
             print_line = f'print("|cff33ffccQuestVoice AceGUI:|r Cargando Widget [%s]" .. Type)\n'
             # Insertar después de la definición de Version
             new_content = re.sub(r'(local Type, Version = ".*?", \d+)', r'\1\n' + print_line, new_content)

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Widget {filename} forzado y con telemetría.")
