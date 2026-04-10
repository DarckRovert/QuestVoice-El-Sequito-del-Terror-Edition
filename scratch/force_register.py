import os
import re

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'

for filename in os.listdir(root_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(root_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content

        # Forzar registro: eliminar el check de versión que impide re-registro
        # ANTES: if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
        # DESPUÉS: if not AceGUI then return end  (registrar siempre si AceGUI existe)
        new_content = re.sub(
            r'if not AceGUI or \(AceGUI:GetWidgetVersion\(Type\) or 0\) >= Version then return end',
            r'if not AceGUI then return end\n-- Forzar re-registro para asegurar compatibilidad con 1.12',
            new_content
        )

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Forzado registro obligatorio: {filename}")
        else:
            print(f"Sin patron encontrado: {filename}")
