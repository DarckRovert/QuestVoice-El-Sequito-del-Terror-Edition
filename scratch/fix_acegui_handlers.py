import os
import re

def fix_acegui_scripts(content):
    # Buscar funciones de handlers de scripts: local function Name(frame, ...)
    # y convertirlas a local function Name(...) local frame = this
    
    # Patrón común en AceGUI: local function ScriptHandler(frame, ...) o (frame, button) etc.
    # Buscamos funciones que luego son usadas en SetScript o pasadas como callbacks de frames.
    
    # 1. Identificar funciones que reciben 'frame' como primer argumento y luego usan 'frame.obj'
    # Esta es una firma clásica de AceGUI moderno.
    
    # Reemplazo para firmas con (frame, ...)
    content = re.sub(r'local\s+function\s+([a-zA-Z0-9_]+)\s*\(\s*frame\s*,\s*\.\.\.\s*\)', 
                     r'local function \1(...)\n\tlocal frame = this', content)
    
    # Reemplazo para firmas con (frame)
    content = re.sub(r'local\s+function\s+([a-zA-Z0-9_]+)\s*\(\s*frame\s*\)', 
                     r'local function \1()\n\tlocal frame = this', content)

    # Reemplazo para firmas con (frame, button) -> OnClick
    content = re.sub(r'local\s+function\s+([a-zA-Z0-9_]+)\s*\(\s*frame\s*,\s*button\s*\)', 
                     r'local function \1(button)\n\tlocal frame = this', content)
    
    # Reemplazo para firmas con (frame, value) -> OnValueChanged, etc.
    content = re.sub(r'local\s+function\s+([a-zA-Z0-9_]+)\s*\(\s*frame\s*,\s*([a-zA-Z0-9_]+)\s*\)', 
                     r'local function \1(\2)\n\tlocal frame = this', content)

    return content

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'
for root, dirs, files in os.walk(root_dir):
    for name in files:
        if name.endswith('.lua'):
            path = os.path.join(root, name)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            new_content = fix_acegui_scripts(content)
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f'Reparado Handlers: {path}')
