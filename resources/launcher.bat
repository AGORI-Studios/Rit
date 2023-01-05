rem Check the current version at https://raw.githubusercontent.com/GuglioIsStupid/Rit/master/VERSION.txt
rem If the version is different, download the new version and run it
rem If the version is the same, do nothing

@echo off
setlocal
set "version=v0.0.1-beta1"
set "versionFile=VERSION.txt"
set "updaterFile=updater.bat"
set "ritFile=game.love"
set "ritFileNew=game_new.love"

echo Checking for updates...
@echo off
curl -s https://raw.githubusercontent.com/GuglioIsStupid/Rit/master/VERSION.txt -o %versionFile%
for /f "tokens=*" %%a in (%versionFile%) do set "versionNew=%%a"
if not "%version%"=="%versionNew%" (
    echo %versionNew% found!
    echo New version found! Downloading...
    curl -L https://github.com/GuglioIsStupid/Rit/releases/download/%versionNew%/Rit.love -o %ritFileNew%
    rem rename %ritFile% %ritFileOld%
    rem rename %ritFileNew% %ritFile%
    "love.exe" %ritFile%
) else (
    echo No new version found.
    "love.exe" %ritFile%
)