import os
import re

widgets_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'

for filename in os.listdir(widgets_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(widgets_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            c = f.read()
        
        # Inyectar polyfills básicos si no existen (select/pairs/etc)
        # Algunos archivos los necesitan locales por performance
        if "local select = AceGUI.select" not in c:
            c = re.sub(r'(-- Lua APIs\r?\n)', r'\1local select = AceGUI.select\nlocal wipe = AceGUI.wipe\n', c)

        # Inyectar telemetría
        if "AceGUI: Registrando" not in c:
            c = re.sub(r'(AceGUI:RegisterWidgetType\(Type,\s*Constructor,\s*Version\))',
                       r'DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AceGUI:|r Registrando " .. Type)\n\1',
                       c)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(c)

print("Telemetría inyectada y polyfills vinculados.")
