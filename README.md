<!--
NOTE TO SELF: Update links.
-->
# Rit

### A rhythm game made in LÖVE.

# How to run (Uncompiled)
- Install [LÖVE](https://love2d.org/)
- Head to the [requirements](/requirements/) folder, open your operating system's folder, and download the .dll/.so/.dylib files
- Place the .dll/.so/.dylib files in your love installation folder
- Run the game by dragging the folder into the love executable, or by running `love <path to folder>` in the command line

# How to run (Compiled)
### Method 1
- Download the latest release from the [releases](https://github.com/AGORI-Studios/rit/releases/latest) page
- Run the executable
### Method 2
- Download from the Steam page (Coming soon)
- Open the game

# How to build

## Windows
- Head to the [requirements](/requirements/) folder, open the win32/win64 folder, and open requirements.txt
- Download [MSYS2](https://www.msys2.org/)
- Run `pacman -S zip`
- Run `make <os>` in the command line.
`<os>` can be replaced with either 'win32', 'win64', 'macos', 'linux', or 'lovefile'. Alternatively, Leave it blank for a zip bundle.

## Linux
- Download "zip" and "love" from your package manager
- Run `make <os>` in the command line.
`<os>` can be replaced with either 'win32', 'win64', 'macos', 'linux', or 'lovefile'. Alternatively, Leave it blank for a zip bundle.

# How to contribute
- Fork the repository
- Make your changes
- Make a pull request

# GuglioIsStupid's Libraries - Free for use
- [class.lua](/src/lib/class.lua)
- [env.lua](/src/lib/env.lua)
- [ini.lua](/src/lib/ini.lua)
- [state.lua](/src/lib/state.lua)

# External Libraries
- [baton.lua](/src/lib/baton.lua)
- [discordRPC.lua](/src/lib/discordRPC.lua) * Modified slightly to support [this custom discordRPC library](https://github.com/hipvpitsme/discord-rpc-with-buttons)
- [jsonhybrid.lua](/src/lib/jsonhybrid.lua) * Mix of 2 seperate json libraries, check out file for more info
- [timer.lua](/src/lib/timer.lua)
- [tinyyaml.lua](/src/lib/tinyyaml.lua)
- [xml.lua](/src/lib/xml.lua)
- [loveloader.lua](/src/lib/loveloader.lua)
- [sworks](/src/lib/sworks/)
- [aqua](/src/lib/aqua) * Just the video module
- [cimgui](/src/lib/cimgui)

# Credits
- [Getsaa](https://twitter.com/GetsaaNG) - UI/UX Design, Rit's Branding, and a few translations (Spanish & Portuguese)
- [Lumaah](https://github.com/Lumaah) - French translation
- [LÖVE](https://love2d.org/) - Game Framework
- [Quaver](https://store.steampowered.com/app/980610/Quaver/) - Inspiration, Quaver beatmap format
- [osu!](https://osu.ppy.sh/) - Inspiration, osu! beatmap format
- [Average4k](https://twitter.com/Average4k) - Inspiration
- [StepMania](https://www.stepmania.com/) - Inspiration, StepMania beatmap format
- [Malody](https://m.mugzone.net/) - Inspiration, MalodyV beatmap format
- [Etterna](https://etternaonline.com/) - Inspiration
- [fluXis](https://fluxis.flux.moe/) - Inspiration, fluXis beatmap format
- [NotITG](https://www.noti.tg/) - Inspiration
- [Kenney.nl](https://kenney.nl/) - UI Assets

\* If you are not credited and you should be, please contact me on [Discord](https://discord.gg/ehY5gMMPW8) or [Twitter](https://twitter.com/GuglioIsStupid)

# License
This project is licensed under the [GNU License](https://www.gnu.org/licenses/gpl-3.0.en.html#license-text) [(File)](/LICENSE), 

# Contact
- [AGORI Discord](https://discord.gg/8RrzKnNtKW) / [GuglioIsStupid Discord](https://discord.gg/ehY5gMMPW8)
- [AGORI Twitter](https://twitter.com/AGORIStudios) / [GuglioIsStupid Twitter](https://twitter.com/GuglioIsStupid)

# Useful links
- [Quaver](https://quavergame.com/)
- [osu!](https://osu.ppy.sh/)
- [LÖVE](https://love2d.org/)
