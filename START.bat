@echo off
title Bear With Me 
color 0A
cd /d "%~dp0"

echo.
echo  =============================================
echo    [Bear With Me] - Starting...
echo  =============================================
echo.

:: Check if setup has been done
if not exist "model" (
    echo  [CHECK]  Looks like you haven't run the installer yet!
    echo.
    echo  Please double-click INSTALL.bat first, then come back.
    echo.
    pause
    exit /b 1
)

if not exist "node_modules" (
    echo  Installing packages...
    npm install >nul 2>&1
)

echo   [OK] Running! 
echo.
echo  In OBS, add a Browser Source with this URL:
echo.
echo      http://localhost:3500
echo.
echo  Then say "bear with me" on stream!
echo.
echo  =============================================
echo  Close this window to stop the bear overlay.
echo  =============================================
echo.

node server.js
