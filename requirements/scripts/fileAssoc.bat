@echo off
goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Detecting permissions...
    
    net session >nul 2>&1
    if %errorLevel% == 0 (
        assoc .rit=Rit.Chart
        rem Set ftype, so when a .rit file is opened, it will run the program with the argument of the file path.
        ftype Rit.Chart="%~dp0../Rit.exe" "%1"
        reg add "HKEY_CLASSES_ROOT\Rit.Chart\DefaultIcon" /ve /t REG_SZ /d "%~dp0icon.ico" /f
        echo Success: File association complete.
    ) else (
        echo Failure: Current permissions inadequate.
    )
    
    pause >nul