# I am a fucking dumbass and really don't want to mess with MINGW for unix shell so here is a parody of Makefile in pwsh for Windows.
# i should've switched to linux but oh well
# script is verbosified, original makefile code probably would work too
Param(
  [string] $Architecture = "win64"
)

'''
if ($Architecture -ne "win64" -and $Architecture -ne "win32") {
  Write-Error "dude do you expect this script to be the most advanced shit ever? stop, get some help, and use normal Makefile for builds other than win32 and win64"
  exit
}
Write-Host "Arch: $Architecture"
'''
function Download-Love {
  Write-Host "Downloading Love..."
  if ($Architecture -ne "nx"){
    Invoke-WebRequest -Uri "https://github.com/love2d/love/releases/download/11.4/love-11.4-$Architecture.zip" -OutFile resources/$Architecture/love-$Architecture.zip
    Expand-Archive -DestinationPath ./resources/$Architecture/ -Path ./resources/$Architecture/love-$Architecture.zip -Force
    Move-Item -Path ./resources/$Architecture/love-11.4-$Architecture/* -Destination ./resources/$Architecture -Force
    Remove-Item -Recurse -Path  ./resources/$Architecture/love-11.4-$Architecture -Force
    Remove-Item -Path ./resources/$Architecture/love-$Architecture.zip -Force
  } else {
    Write-Host "Download love.elf..." #https://github.com/retronx-team/love-nx/releases/download/11.4-nx1/love.elf
    # create build\nx
    New-Item -ItemType Directory -Force -Path build/nx
    Invoke-WebRequest -Uri "https://github.com/retronx-team/love-nx/releases/download/11.4-nx1/love.elf" -OutFile build/nx/love.elf
  }
}

function Build-Lovefile {
  Remove-Item -Recurse -Force build/lovefile
  New-Item -ItemType Directory -Force -Path build/lovefile

  Set-Location -Path love # this is so psycho wtf
  Compress-Archive -Path ./* -DestinationPath ../build/lovefile/Rit.zip -CompressionLevel Optimal
  Rename-Item -Path ../build/lovefile/Rit.zip -NewName Rit.love
  Set-Location -Path ..
}

function Collect-Bundle {
  if ($Architecture -ne "nx"){
    Remove-Item -Recurse -Force -Path build/$Architecture
    New-Item -ItemType Directory -Force -Path build/$Architecture
  }
 
  
  Copy-Item -Recurse -Path build/lovefile/Rit.love -Destination build/$Architecture/game.love
  if ($Architecture -ne "nx"){
    Copy-Item -Recurse -Path resources/$Architecture/* -Destination build/$Architecture
    Copy-Item -Recurse -Path resources/$Architecture/discord-rpc.dll -Destination build/$Architecture

    Set-Location build/$Architecture
    cmd.exe /c "copy /b love.exe+game.love Rit.exe"
    Remove-Item -Path game.love -Force
    Remove-Item -Path love.exe -Force
  } else {
    cmd.exe /c "tools\switch\nacptool.exe --create 'Rit' 'GuglioIsStupid' '0.0.3-beta' build\nx\Rit.nacp"
    # make romfs folder
    New-Item -ItemType Directory -Force -Path build\nx\romfs
    # copy game.love to romfs
    Copy-Item -Recurse -Path build\lovefile\Rit.love -Destination build\nx\romfs\game.love
    # delete game.love
    Remove-Item -Path build\lovefile\Rit.love -Force

    cmd.exe /c "tools\switch\elf2nro.exe build\nx\love.elf build\nx\Rit.nro --icon=resources\nx\icon.jpg --nacp=build\nx\Rit.nacp"
    # move to build\nx\build 
    New-Item -ItemType Directory -Force -Path build\nx\build
    New-Item -ItemType Directory -Force -Path build\nx\build\rit
    Move-Item -Path build\nx\Rit.nro -Destination build\nx\build\rit\Rit.nro

    # if build/release doesn't exist, create it
    if (!(Test-Path build/release)) {
      New-Item -ItemType Directory -Force -Path build/release
    }
    # zip build\nx\build\rit to build\release\Rit.zip
    Compress-Archive -Path build\nx\build\rit\* -DestinationPath build\release\Rit.zip -CompressionLevel Optimal
  }
  Set-Location ../..
}

Download-Love
Build-Lovefile
Collect-Bundle