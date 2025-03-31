@echo off
setlocal

:: Config
set PSEXEC=C:\ps\PsExec64.exe
set COMPUTERLIST=C:\ps\laptoplist.txt
set PS_SCRIPT=\\192.168.103.245\gpo\Remove-Enrollment.ps1
set LOGFILE=C:\ps\ScriptLog_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.log
set LOGCOLLECT=C:\ps\collected_logs

:: Clean up logfile formatting
set LOGFILE=%LOGFILE: =0%
if not exist "%LOGCOLLECT%" mkdir "%LOGCOLLECT%"

echo --- Script Execution Log --- > "%LOGFILE%"
echo Started at %DATE% %TIME% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: Loop through each computer
for /f %%A in (%COMPUTERLIST%) do (
    echo.
    echo Checking %%A...
    echo [%DATE% %TIME%] Checking %%A... >> "%LOGFILE%"

    ping -n 1 -w 1000 %%A >nul
    if errorlevel 1 (
        echo %%A is unreachable. Skipping...
        echo [%DATE% %TIME%] %%A is unreachable. Skipped. >> "%LOGFILE%"
    ) else (
        echo %%A is online. Running script...
        echo [%DATE% %TIME%] %%A is online. Executing script... >> "%LOGFILE%"
        "%PSEXEC%" -accepteula \\%%A -s powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%" >> "%LOGFILE%" 2>&1

        if errorlevel 1 (
            echo [%DATE% %TIME%] ERROR: Script failed on %%A >> "%LOGFILE%"
        ) else (
            echo [%DATE% %TIME%] Script finished successfully on %%A >> "%LOGFILE%"
        )

        :: Try to collect the deleted_keys.log from remote machine
        copy "\\%%A\C$\ps\deleted_keys.log" "%LOGCOLLECT%\deleted_keys_%%A.log" >nul 2>&1
        if errorlevel 1 (
            echo [%DATE% %TIME%] WARNING: Could not collect log from %%A >> "%LOGFILE%"
        ) else (
            echo [%DATE% %TIME%] Collected deleted_keys.log from %%A >> "%LOGFILE%"
        )
    )
)

echo. >> "%LOGFILE%"
echo Finished at %DATE% %TIME% >> "%LOGFILE%"
echo Log saved to: %LOGFILE%
echo.
pause
