# 📖 Manual de Usuario 

**QuestVoice (Séquito del Terror Edition)** no es un Addon complejo de utilizar, pero posee robustos sistemas ocultos para gestionar la latencia sonora. Está pre-configurado para que al simplemente clickar a un Guardián u Dador de Misión ("Quest Giver"), los diálogos textuales se reemplacen automáticamente con un envolvente actor de voz.

## Cómo Utilizar
- Dirígete a cualquier **NPC (Personaje No-Jugador)** válido del entorno originario de Vanilla 1.12.
- Interactúa usando Click Derecho.
- La pantalla de "Detalles de Misión" silenciará los gritos monótonos o la ambientación general, e invocará tu Archivo de Voz (VoiceOver).

A diferencia de las versiones en las que el Addon se basó (Ej. PfQuest-Voice), este entorno fue refactorizado para operar sobre herramientas Vanilla Native y purgar librerías engorrosas, lo cual hace los menús limpios y ultra directos.

## Menú Transparente y Opciones

Ingresa `/vo` directamente en la ventana de Chat del juego. Surgirá de inmediato la ventana negra central (Opciones). Podrás configurar:
1. **Auto Toggle Dialog**: Silencia la típica línea cortísima del NPC para no encimarse a la voz generada.
2. **Minimap Button**: Permite adherir o desaparecer el ícono fonético de la brújula redonda de World of Warcraft.
3. **Sound Channel**: Decide a través de qué canal Vanilla se emitirá el Locutor (usualmente *Master*).

## Herramientas de Consola de Recuperación (Bypass Cmds)
En caso presencies que el audio general del Addon o del juego "Mudo" o congelado (Posible por choques de temporizadores), utiliza en el chat los **Comandos Especiales de Diagnóstico (Globales):**

- `/voclear`: Elimina la cola completa guardada en la matriz "SoundQueue". Purifica el Addon si una voz vieja fantasma no dejaba avanzar los sonidos siguientes.
- `/voresume`: Obliga al Addon a regresar de una Pausa explícita de "SoundQueue", re-disparando los temporizadores en el proceso actual.
- `/votest`: Comando crítico para probar el Motor FMOD de la computadora. En rutinas de Turtle WoW, este comando fuerza al addon a leer la dirección física exacta de un MP3 alojado en la base de datos (QuestID: 6187) reproduciéndolo inmediatamente. Si `/votest` suena, este Addon es técnicamente puro.
