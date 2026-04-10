import os
import re

widgets_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'

for filename in os.listdir(widgets_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(widgets_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # Encontrar dónde empieza la lógica de AceGUI
        # Buscamos la línea que tiene QuestVoice_AceGUI
        start_index = -1
        for i, line in enumerate(lines):
            if "QuestVoice_AceGUI" in line:
                start_index = i
                break
        
        if start_index != -1:
            # Preservar el encabezado de comentarios (usualmente líneas 1-4)
            header = lines[:4]
            # Preservar la definición de Type/Version (usualmente línea 5)
            metadata = []
            for i in range(4, start_index):
                if 'local Type, Version = "' in lines[i]:
                    metadata.append(lines[i])
                    break
            
            # Nueva cabecera limpia
            new_lines = header + metadata + ["\n"] 
            new_lines.append("local AceGUI = _G.QuestVoice_AceGUI\n")
            new_lines.append("if not AceGUI or not AceGUI.RegisterWidgetType then return end\n\n")
            
            # El resto del archivo desde start_index + 1 (o +2 si había check de nil)
            # Buscamos la primera línea de "Lua APIs" o similar después del check de AceGUI
            actual_code_start = -1
            for i in range(start_index + 1, len(lines)):
                if "-- Lua APIs" in lines[i] or "-- WoW APIs" in lines[i] or "local " in lines[i]:
                    actual_code_start = i
                    break
            
            if actual_code_start != -1:
                new_lines.extend(lines[actual_code_start:])
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.writelines(new_lines)
                print(f"Widget {filename} saneado.")
            else:
                print(f"No se detectó el inicio del código en {filename}")
        else:
            print(f"No se detectó AceGUI en {filename}")

print("Limpieza de sintaxis completada.")
