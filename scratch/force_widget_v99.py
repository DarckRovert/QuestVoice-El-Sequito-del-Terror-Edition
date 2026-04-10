import os
import re

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0\widgets'

for filename in os.listdir(root_dir):
    if filename.endswith(".lua"):
        filepath = os.path.join(root_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Incrementar version a 99
        # local Type, Version = "...", 12 -> local Type, Version = "...", 99
        new_content = re.sub(r'local Type, Version = "(.*?)", \d+', r'local Type, Version = "\1", 99', content)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Versión de {filename} incrementada a 99.")
