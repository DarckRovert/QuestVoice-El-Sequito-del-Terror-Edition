import os, re

def fix_content(content):
    # Caso 1: table.getn(obj).field -> table.getn(obj.field)
    # Este es un error muy común del script que reemplazó # indiscriminadamente
    content = re.sub(r'table\.getn\(([^)]+)\)\.([a-zA-Z_][a-zA-Z0-9_]*)', r'table.getn(\1.\2)', content)

    # Caso 2: Corrupción dentro de strings
    # Si vemos table.getn(Algo) dentro de un string de unidad o localización, es una corrupción.
    # Ejemplo: [21935] = "Gnome Cannon Shooter table.getn(Shattrath)"
    def fix_strings(m):
        s = m.group(0)
        # Revertir table.getn(X) a #X dentro de strings
        return s.replace('table.getn(', '#')
    
    # Solo aplicar en líneas que parecen definiciones de strings largos o bases de datos
    # O mejor, en cualquier string literal que tenga el patrón.
    content = re.sub(r'\"[^\"]*table\.getn\([^)]+\)[^\"]*\"', fix_strings, content)
    content = re.sub(r'\'[^\']*table\.getn\([^)]+\)[^\']*\'', fix_strings, content)

    return content

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice'
for root, dirs, files in os.walk(root_dir):
    if any(x in root for x in ['brain', '.gemini', 'scratch']): continue
    for name in files:
        if name.endswith('.lua'):
            path = os.path.join(root, name)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            if 'table.getn' in content:
                new_content = fix_content(content)
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f'Reparado: {path}')
