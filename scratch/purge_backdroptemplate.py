import os
import re

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs'

# Patrón para eliminar ", \"BackdropTemplate\"" o ", \"BackdropTemplate\", \"" o "\"BackdropTemplate\""
# Casos comunes:
# CreateFrame("Frame", nil, UIParent, "BackdropTemplate") -> CreateFrame("Frame", nil, UIParent)
# CreateFrame("Frame", nil, parent, "BackdropTemplate", "OtherTemplate") -> CreateFrame("Frame", nil, parent, "OtherTemplate")

patterns = [
    (re.compile(r', \s*"BackdropTemplate"'), ''),
    (re.compile(r'"BackdropTemplate", \s*'), ''),
    (re.compile(r'"BackdropTemplate"'), 'nil') # Si era el único argumento de template
]

for root, dirs, files in os.walk(root_dir):
    for filename in files:
        if filename.endswith(".lua"):
            filepath = os.path.join(root, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = content
            if "BackdropTemplate" in content:
                # Caso específico de CreateFrame:
                # Reemplazar , "BackdropTemplate" por nada dentro de CreateFrame
                new_content = re.sub(r'(CreateFrame\s*\(.*?),?\s*"BackdropTemplate"\s*(.*?\))', r'\1\2', content)
                
                # Limpiar comas dobles si quedaron: (..., , ...)
                new_content = re.sub(r',\s*,', r',', new_content)
                # Limpiar coma final: (..., )
                new_content = re.sub(r',\s*\)', r')', new_content)

            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Saneado: {filepath}")
