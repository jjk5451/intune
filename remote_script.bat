@echo off
echo Running Enrollment Process on %COMPUTERNAME%
echo Timestamp: %DATE% %TIME%

:: Attempt to join the device to Azure AD
echo Running dsregcmd /join...
dsregcmd /join

:: Restart necessary services
echo Restarting required services...
net stop dmwappushservice && net start dmwappushservice
net stop wuauserv && net start wuauserv
net stop iphlpsvc && net start iphlpsvc
net stop winmgmt && net start winmgmt

:: Check if the device joined successfully
echo Checking Enrollment Status...
dsregcmd /status | findstr /C:"AzureAdJoined" > nul
if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: Device is enrolled in Azure AD.
) else (
    echo ERROR: Device enrollment failed.
)

echo Script execution completed.
exit /b
