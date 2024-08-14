# v0.1.0 - Public Steam Build
### Additions:

### Reworks:
- Rewrote the whole game to C#

### Removals:

### Fixes:


!! OUTDATED vv
# v0.1.0 - Public Steam Build
### Additions:
- New UI
- New Skin system
- New Modding system
- Added "fluXis" support
- MalodyV support
- Steamworks integration
- Multiplayer Servers (Comes online every once in a while for testing)
- Pre-included official songs
- Video background support
- 1k-10k mania support
- (Some) osu!Taiko support
- osu!Mania SV support
- New settings system
- Touch Screen support
- Replay system
- (Partial) Clone Hero support
- (Local only currently) Leaderboards
- Multiple Language support (en-US, en-UK, es-LATAM, fr-FR, pt-BR)
- Search feature for song selection menu
- Hold release timings

### Reworks:
- Entire game rewrite from ground up
- Rewrite input system
- Modscripting rewrite (Works similar to NotITG Mirin (not really))
- Reworked the health system

### Removals:
- Removed "FNF" support (No need to support it, if you want to play an fnf chart, just convert it lol)
- Removed old default songs (Was only pre-included for testing)

### Fixes:
- Game no longer crashes if a song is not found

!! OUTDATED ^^

# v0.0.5-SV Improvement
Changes:

- Default songs (pre-included to test the game out)
- Scroll Velocity rewrite (pretty 1:1 to quavers now)
- fixed NX build not working

# v0.0.5
NOTE: Game will crash if a song is not found!

STUFF!
1. MODSCRIPTING
- graphics.newCircle / graphics.newRectangle
- simulatedBeatTime (Used with setMusicPlaying(true/false))
- UI Elements can be set to visible/invisible
- Drunk + Tipsy mods improved

2. GAMEPLAY
- Input w/ hold notes was fixed (or well.. improved)
- Better rating system
- FNF BPM Changes
- Song speed changes 
- Difficulty Calculator (May break)
- Better song folder (no need for separate game folders)
- Backgrounds
- Scroll underlay
- SV's are slightly better

3. SKINS
- UI Colours can be changed in the skin.json

4. MENUS 
- Added results screen (Very barebones) 
- Added a start menu
- Added a settings menu

5. MISC
- Fixed debug overriding default lua debug
- Replays (Currently not viewable)
- Switched to HUMP.Gamestate instead of my own state library
- love.graphics.gradient
- (UI) Scoring + Accuracy lerps instead of Timer.tweens
- New settings system

# v0.0.4 - Modscripting
Rit now support modscripts!

To make a modscript, go into the songs folder and make a folder called mod with a mod.lua file in it.

Refer to this wiki for modscript functions!

# v0.0.3 Scrolling Notes Fix
Fixed LOTS of graphical issues with scrolling ways LOL

# v0.0.3-beta switch fix
Includes some fixes for the Nintendo Switch version & some slight code cleanups

# v0.0.3-beta
gonna make this later (I never did - 2024 me)

# v0.0.2-beta

- Gameover
- New default circle skin (Made by Getsaa)
- Downscroll
- Some new skinning options
- Auto updater
- And more!

To run this game on win32/win64 please launch launcher.bat. This makes it so it can check the current Git release!

# v0.0.1-beta1

## The very first release of Rit!

## Things currently supported:
- Quaver, osu!, and FNF json chart support
- (Quaver) Scroll velocities
- Custom scroll speed
- Custom start time (delay for song to start (700ms default))
- Probably more that i forgot

### NOTE
I have no clue if the macos version works or not. If someone can let me know that would be great! ^^
