import os
import re

# 1. Reparar AceGUI-3.0.lua (Core Privado)
# Asegurar que los registros NO sean locales para evitar desincronización
acegui_path = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\AceGUI-3.0.lua'
with open(acegui_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Forzar que RegisterWidgetType use el objeto directamente
new_content = content
new_content = re.sub(r'WidgetRegistry\[Name\]\s*=\s*Constructor', 
                     r'AceGUI.WidgetRegistry[Name] = Constructor', new_content)
new_content = re.sub(r'local Constructor\s*=\s*WidgetRegistry\[Name\]', 
                     r'local Constructor = AceGUI.WidgetRegistry[Name]', new_content)

with open(acegui_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

# 2. Limpiar y Sincronizar WIDGETS
widgets_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'
for filename in os.listdir(widgets_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(widgets_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            c = f.read()
        
        # Eliminar polyfills redundantes que pueden fallar
        c = re.sub(r'local function select\(index, \.\.\.\).*?end', '', c, flags=re.DOTALL)
        c = re.sub(r'local function wipe\(t, \.\.\.\).*?end', '', c, flags=re.DOTALL)
        
        # Asegurar el uso de la instancia privada
        c = re.sub(r'local AceGUI = _G\.QuestVoice_AceGUI.*?\n', 
                   r'local AceGUI = _G.QuestVoice_AceGUI or QuestVoice_AceGUI\n', c)
        
        # Inyectar un mensaje de depuración de registro
        c = re.sub(r'AceGUI:RegisterWidgetType\(Type,\s*Constructor,\s*Version\)',
                   r'DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AceGUI:|r Registrando " .. Type)\nAceGUI:RegisterWidgetType(Type, Constructor, Version)',
                   c)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(c)

print("Widgets sincronizados y telemetría de registro inyectada.")
