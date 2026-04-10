import os, re

def fix_content(content):
    # Patrón: # + cualquier cosa balanceada hasta el )
    # Esto captura: #meta["item"]) -> table.getn(meta["item"])
    # O: #children) -> table.getn(children)
    # Buscamos # seguido de cualquier cosa que NO sea un ) y que termine en )
    # Este patrón es específico para corregir las corrupciones de los scripts previos.
    content = re.sub(r'#([^)]+)\)', r'table.getn(\1)', content)
    
    # Manejar casos donde el # no tiene paréntesis extra pero no debería estar ahí (fuera de strings)
    # Ejemplo: cur < #t
    # Limitamos a variables, corchetes y puntos.
    # No usamos [^"] para evitar fallos masivos, mejor ser específico.
    content = re.sub(r'=\s*#([a-zA-Z_][a-zA-Z0-9_.\"\'\[\]]*)', r'= table.getn(\1)', content)
    content = re.sub(r'<\s*#([a-zA-Z_][a-zA-Z0-9_.\"\'\[\]]*)', r'< table.getn(\1)', content)
    content = re.sub(r'>\s*#([a-zA-Z_][a-zA-Z0-9_.\"\'\[\]]*)', r'> table.getn(\1)', content)
    content = re.sub(r',\s*#([a-zA-Z_][a-zA-Z0-9_.\"\'\[\]]*)', r', table.getn(\1)', content)
    
    return content

root_dir = r'e:\Turtle Wow\Interface\AddOns\QuestVoice'
for root, dirs, files in os.walk(root_dir):
    if any(x in root for x in ['brain', '.gemini', 'scratch']): continue
    for name in files:
        if name.endswith('.lua'):
            path = os.path.join(root, name)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            if '#' in content:
                new_content = fix_content(content)
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f'Reparado: {path}')
