import os

def final_fix(content):
    # Restaurar select('#', ...) y similares que fueron dañados
    # por un reemplazo excesivamente agresivo de # por table.getn(
    content = content.replace("'table.getn('", "'#'")
    content = content.replace('"table.getn("', '"#"')
    return content

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice\Libs\AceGUI-3.0'
for root, dirs, files in os.walk(root_dir):
    for name in files:
        if name.endswith('.lua'):
            path = os.path.join(root, name)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            new_content = final_fix(content)
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f'Saneado: {path}')
