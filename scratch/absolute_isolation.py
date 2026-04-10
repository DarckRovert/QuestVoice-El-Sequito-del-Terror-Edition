import os
import re

# 1. Modificar AceGUI-3.0.lua para ser totalmente privado e independiente de LibStub
acegui_core = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\AceGUI-3.0.lua'
with open(acegui_core, 'r', encoding='utf-8') as f:
    content = f.read()

# Eliminar dependencia de LibStub para la instancia principal
new_content = re.sub(r'local AceGUI, oldminor = LibStub:NewLibrary\(.*?\)', 
                     r'local AceGUI = _G.QuestVoice_AceGUI or {}\n_G.QuestVoice_AceGUI = AceGUI\nlocal oldminor = AceGUI.minor', 
                     content)

# Asegurar que no se sale prematuramente
new_content = re.sub(r'if not AceGUI then\s*AceGUI = LibStub\(ACEGUI_MAJOR\)\s*end', '', new_content)
new_content = re.sub(r'if not AceGUI then return end', '', new_content)

# Forzar el print de éxito
new_content = re.sub(r'print\(".*?AceGUI:.*? Inicializado v" \.\. ACEGUI_MINOR\)', 
                     r'DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccQuestVoice AceGUI [Private Instance]:|r Operativa.")', 
                     new_content)

if new_content != content:
    with open(acegui_core, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("AceGUI-3.0 Core convertido a instancia privada.")

# 2. Modificar todos los widgets para usar ÚNICAMENTE el global privado
widgets_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'
for filename in os.listdir(widgets_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(widgets_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            c = f.read()
        
        # Eliminar cualquier rastro de LibStub y forzar uso de QuestVoice_AceGUI
        # Patrón: local AceGUI = ...
        nc = re.sub(r'local AceGUI = .*?\r?\n(if not AceGUI then return end)?', 
                    r'local AceGUI = _G.QuestVoice_AceGUI\nif not AceGUI then return end', 
                    c)
        
        # Eliminar comentarios de re-registro forzado que ensucian
        nc = nc.replace('-- Forzar re-registro para asegurar compatibilidad con 1.12', '')
        nc = nc.replace('-- Registro forzado: sin check de versión para compatibilidad con 1.12', '')
        
        if nc != c:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(nc)
            print(f"Widget {filename} privatizado.")

# 3. Privatizar AceConfigDialog-3.0.lua
acdialog = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceConfig-3.0\AceConfigDialog-3.0\AceConfigDialog-3.0.lua'
with open(acdialog, 'r', encoding='utf-8') as f:
    adc = f.read()

# Forzar uso del AceGUI privado
nadc = re.sub(r'local gui = .*?\n', r'local gui = _G.QuestVoice_AceGUI\n', adc)

if nadc != adc:
    with open(acdialog, 'w', encoding='utf-8') as f:
        f.write(nadc)
    print("AceConfigDialog privatizado.")
