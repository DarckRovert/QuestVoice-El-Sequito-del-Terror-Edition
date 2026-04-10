import os
import subprocess

repo_path = r"e:\QuestVoice_Git_Temp"
if not os.path.exists(repo_path):
    os.makedirs(repo_path)

# Sincronizar solo archivos de código y docs para el repo
source_path = r"e:\Turtle Wow\Interface\AddOns\QuestVoice"
include_exts = {".lua", ".toc", ".xml", ".md", ".txt", ".gitignore", "LICENSE"}

print("Iniciando recolección de archivos...")
files_added = 0
for root, dirs, files in os.walk(source_path):
    if ".git" in root or "scratch" in root: continue
    
    # Recrear estructura en Temp
    rel_path = os.path.relpath(root, source_path)
    target_dir = os.path.join(repo_path, rel_path)
    if not os.path.exists(target_dir):
        os.makedirs(target_dir)

    for file in files:
        if any(file.endswith(ext) for ext in include_exts) or file == "LICENSE":
            src_file = os.path.join(root, file)
            dst_file = os.path.join(target_dir, file)
            try:
                # Copiar archivo
                with open(src_file, 'rb') as fsrc:
                    with open(dst_file, 'wb') as fdst:
                        fdst.write(fsrc.read())
                files_added += 1
            except Exception as e:
                print(f"Error copiando {file}: {e}")

print(f"Copiados {files_added} archivos de código.")

# Git Operations en Temp
os.chdir(repo_path)
try:
    subprocess.run(["git", "init"], check=True)
    subprocess.run(["git", "config", "user.email", "darckrovert@example.com"], check=True)
    subprocess.run(["git", "config", "user.name", "DarckRovert"], check=True)
    
    # Agregar archivos uno por uno para debugGear
    for root, dirs, files in os.walk("."):
        if ".git" in root: continue
        for file in files:
            fpath = os.path.join(root, file)
            subprocess.run(["git", "add", fpath]) # No check=True para no abortar

    subprocess.run(["git", "commit", "-m", "[Diamond-Tier] Estabilización y Privatización Ace3 [QuestVoice Core]"], check=True)
    subprocess.run(["git", "branch", "-M", "main"], check=True)
    subprocess.run(["git", "remote", "add", "origin", "https://github.com/DarckRovert/QuestVoice-El-Sequito-del-Terror-Edition"], check=True)
    print("Listo para el push final.")
except Exception as e:
    print(f"Error en Git: {e}")
