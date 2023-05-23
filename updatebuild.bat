@echo off
rem get commit count

set /a count=0
for /f "delims=" %%a in ('git rev-list HEAD --count') do @set count=%%a

rem build goes "commitcount - dd-mm-yyyy"

rem get current date
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do (
    set yyyy=%%a
)

rem edit love/buildver.txt
echo %count% - %yyyy% > love/buildver.txt