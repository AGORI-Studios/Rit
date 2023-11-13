# Rit

# How to run (Uncompiled)
- Install [LÖVE](https://love2d.org/)
- Head to the [requirements](/requirements/) folder, open your operating system's folder, and download the .dll/.so/.dylib files
- Place the .dll/.so/.dylib files in your love installation folder
- Run the game by dragging the folder into the love executable, or by running `love <path to folder>` in the command line

# How to run (Compiled)
- Download the latest release from the [releases](https://github.com/AGORI-Studios/rit/releases/latest) page
- Or, download from the Steam page (Coming soon)
- Run the executable

# How to build

## Windows
- Head to the [requirements](/requirements/) folder, open the win32/win64 folder, and open requirements.txt
- Download msys2, and install "zip"
- Run make (os) in the command line. (os) is either win32, win64, macos, linux, or lovefile (Leave blank for all with distribution zips)

## Linux
- Download "zip" and "love" from your package manager
- Run make (os) in the command line. (os) is either win32, win64, macos, linux, or lovefile (Leave blank for all with distribution zips)

# How to contribute
- Fork the repository
- Make your changes
- Make a pull request

# Project structure
- All lua source files are PascalCase (e.g. `MainMenu.lua`)
- Global/local variables are camelCase (e.g. `gameState`)
- Functions are camelCase (e.g. `loadGame()`)
- Classes are PascalCase (e.g. `MainMenu`)
- Class functions are camelCase (e.g. `MainMenu:load()`)

# Libraries (By me) - Free for use
- [class.lua](/src/lib/class.lua)
- [env.lua](/src/lib/env.lua)
- [ini.lua](/src/lib/ini.lua)
- [state.lua](/src/lib/state.lua)

# Libraries Used (Not by me) 
- [baton.lua](/src/lib/baton.lua)
- [complex.lua](/src/lib/complex.lua)
- [discordRPC.lua](/src/lib/discordRPC.lua)
- [json.lua](/src/lib/json.lua)
- [luafft.lua](/src/lib/luafft.lua)
- [push.lua](/src/lib/push.lua)
- [lume.lua](/src/lib/lume.lua)
- [timer.lua](/src/lib/timer.lua)
- [tinyyaml.lua](/src/lib/tinyyaml.lua)
- [xml.lua](/src/lib/xml.lua)

# Credits
- [Getsaa](https://twitter.com/GetsaaNG) - Menu design, UI design, and art
- [LÖVE](https://love2d.org/) - Game Framework
- [Quaver](https://store.steampowered.com/app/980610/Quaver/) - Inspiration
- [osu!](https://osu.ppy.sh/) - Inspiration
- [Average4k](https://twitter.com/Average4k) - Inspiration

# License
- [GNU License](/LICENSE)

# Contact
- [AGORI Discord](https://discord.gg/8RrzKnNtKW) / [GuglioIsStupid Discord](https://discord.gg/ehY5gMMPW8)
- [AGORI Twitter](https://twitter.com/AGORIStudios) / [GuglioIsStupid Twitter](https://twitter.com/GuglioIs2Stupid)

# Useful links
- [Quaver](https://quavergame.com/)
- [osu!](https://osu.ppy.sh/)
- [LÖVE](https://love2d.org/)
