# I am a fucking dumbass and really don't want to mess with MINGW for unix shell so here is a parody of Makefile in pwsh for Windows.
# i should've switched to linux but oh well
# script is verbosified, original makefile code probably would work too
Param(
  [string] $Architecture = "win64"
)


if ($Architecture -ne "win64" -and $Architecture -ne "win32") {
  Write-Error "dude do you expect this script to be the most advanced shit ever? stop, get some help, and use normal Makefile for builds other than win32 and win64"
  exit
}
Write-Host "Arch: $Architecture"

function Download-Love {
  if (Test-Path -Path resources/$Architecture/love.exe -PathType Leaf) {
    return
  }
  Write-Host "Downloading Love..."
  Invoke-WebRequest -Uri "https://github.com/love2d/love/releases/download/11.4/love-11.4-$Architecture.zip" -OutFile resources/$Architecture/love-$Architecture.zip
  Expand-Archive -DestinationPath ./resources/$Architecture/ -Path ./resources/$Architecture/love-$Architecture.zip -Force
  Move-Item -Path ./resources/$Architecture/love-11.4-$Architecture/* -Destination ./resources/$Architecture -Force
  Remove-Item -Recurse -Path  ./resources/$Architecture/love-11.4-$Architecture -Force
  Remove-Item -Path ./resources/$Architecture/love-$Architecture.zip -Force
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
  Remove-Item -Recurse -Force -Path build/$Architecture
  New-Item -ItemType Directory -Force -Path build/$Architecture
      
  Copy-Item -Recurse -Path build/lovefile/Rit.love -Destination build/$Architecture/game.love
  Copy-Item -Recurse -Path resources/$Architecture/* -Destination build/$Architecture
  Copy-Item -Recurse -Path resources/$Architecture/discord-rpc.dll -Destination build/$Architecture

  # Shortcut
  # $shell = New-Object -ComObject WScript.Shell
  # $shortcut = $shell.CreateShortcut("build/$Architecture/Launch Rit.lnk")
  # $shortcut.TargetPath = "C:\Windows\System32\cmd.exe"
  # $shortcut.WorkingDirectory = "."
  # $shortcut.Arguments = "/c love.exe game.love"
  # $shortcut.Save()

  # love.exe + Rit.love joined into Rit.exe
  Set-Location build/$Architecture
  cmd /c "copy /b love.exe+game.love Rit.exe"
  Set-Location ../..
}

Download-Love
Build-Lovefile
Collect-Bundle