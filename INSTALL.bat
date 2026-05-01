@echo off
setlocal enabledelayedexpansion
title Bear With Me - Setup
color 0A
cd /d "%~dp0"

echo.
echo  =============================================
echo   🐻  Bear With Me - One Time Setup
echo  =============================================
echo.

:: ── Check for Admin ───────────────────────────────────────────────────────
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  This installer needs admin permissions to install Node.js and Python.
    echo  Right-click INSTALL.bat and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

:: ── Check Node.js ─────────────────────────────────────────────────────────
set NEED_NODE=0
set NEED_PYTHON=0

node --version >nul 2>&1
if %errorlevel% neq 0 (
    set NEED_NODE=1
) else (
    for /f "tokens=2 delims=v." %%a in ('node --version') do set NODE_MAJOR=%%a
    if !NODE_MAJOR! LSS 18 set NEED_NODE=1
)

:: ── Check Python ──────────────────────────────────────────────────────────
python --version >nul 2>&1
if %errorlevel% neq 0 (
    set NEED_PYTHON=1
) else (
    for /f "tokens=2 delims= " %%a in ('python --version') do set PY_VERSION=%%a
    for /f "tokens=1 delims=." %%a in ("!PY_VERSION!") do set PY_MAJOR=%%a
    for /f "tokens=2 delims=." %%a in ("!PY_VERSION!") do set PY_MINOR=%%a
    if !PY_MAJOR! LSS 3 set NEED_PYTHON=1
    if !PY_MAJOR! EQU 3 if !PY_MINOR! LSS 9 set NEED_PYTHON=1
)

:: ── Install Node.js if needed ─────────────────────────────────────────────
if %NEED_NODE% EQU 1 (
    echo  [INFO] Downloading Node.js...
    curl -L "https://nodejs.org/dist/v20.19.0/node-v20.19.0-x64.msi" -o "%TEMP%\node_installer.msi"
    if %errorlevel% neq 0 (
        echo  ❌ Failed to download Node.js. Check your internet connection.
        pause
        exit /b 1
    )
    echo  [INFO] Installing Node.js...
    msiexec /i "%TEMP%\node_installer.msi" /qn /norestart
    if %errorlevel% neq 0 (
        echo  ❌ Failed to install Node.js.
        pause
        exit /b 1
    )
    del "%TEMP%\node_installer.msi"
    :: Refresh PATH so node is available immediately
    for /f "tokens=*" %%a in ('where node 2^>nul') do set NODE_PATH=%%a
    if not defined NODE_PATH (
        set "PATH=%PATH%;C:\Program Files\nodejs"
    )
    echo  ✅ Node.js installed!
) else (
    echo  ✅ Node.js already installed
)

:: ── Install Python if needed ──────────────────────────────────────────────
if %NEED_PYTHON% EQU 1 (
    echo  [INFO] Downloading Python...
    curl -L "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" -o "%TEMP%\python_installer.exe"
    if %errorlevel% neq 0 (
        echo  ❌ Failed to download Python. Check your internet connection.
        pause
        exit /b 1
    )
    echo  [INFO] Installing Python...
    "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    if %errorlevel% neq 0 (
        echo  ❌ Failed to install Python.
        pause
        exit /b 1
    )
    del "%TEMP%\python_installer.exe"
    :: Refresh PATH so python is available immediately
    for /f "tokens=*" %%a in ('where python 2^>nul') do set PYTHON_PATH=%%a
    if not defined PYTHON_PATH (
        set "PATH=%PATH%;C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python311;C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python311\Scripts"
    )
    echo  ✅ Python installed!
) else (
    echo  ✅ Python already installed
)

:: ── Install Python packages ───────────────────────────────────────────────
echo.
echo  [INFO] Installing voice detection packages...
python -m pip install vosk sounddevice >nul 2>&1
if %errorlevel% neq 0 (
    echo  ❌ Failed to install voice packages. Check your internet connection.
    pause
    exit /b 1
)
echo  ✅ Voice packages installed!

:: ── Install Node packages ─────────────────────────────────────────────────
echo  [INFO] Installing server packages...
npm install >nul 2>&1
if %errorlevel% neq 0 (
    echo  ❌ Failed to install server packages. Check your internet connection.
    pause
    exit /b 1
)
echo  ✅ Server packages installed!

:: ── Download voice model ──────────────────────────────────────────────────
echo.
echo  [INFO] Downloading voice recognition model (~40MB)...

if exist "%~dp0model" (
    echo  ✅ Voice model already exists, skipping!
    goto :model_done
)

python -c "
import urllib.request, zipfile, os, sys, shutil

url = 'https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip'
dest = os.path.join(os.path.dirname(sys.argv[0]) if sys.argv[0] else '.', 'model.zip')
folder = os.path.join(os.path.dirname(sys.argv[0]) if sys.argv[0] else '.', 'model')

print('  Downloading...', flush=True)

def progress(count, block_size, total_size):
    pct = int(count * block_size * 100 / total_size)
    print(f'  {min(pct,100)}%%', end=chr(13), flush=True)

urllib.request.urlretrieve(url, dest, progress)
print('  Download complete! Extracting...', flush=True)

with zipfile.ZipFile(dest, 'r') as z:
    z.extractall(os.path.dirname(dest) or '.')

extracted = os.path.join(os.path.dirname(dest) or '.', 'vosk-model-small-en-us-0.15')
if os.path.exists(extracted):
    shutil.move(extracted, folder)

os.remove(dest)
print('  Done!', flush=True)
" "%~dp0"

if %errorlevel% neq 0 (
    echo  ❌ Failed to download voice model. Check your internet and try again.
    pause
    exit /b 1
)

:model_done

:: ── Done! ─────────────────────────────────────────────────────────────────
echo.
echo  =============================================
echo   ✅  Setup Complete!
echo  =============================================
echo.
echo  HOW TO USE EVERY STREAM:
echo.
echo  1. Double-click START.bat
echo.
echo  2. In OBS, add a Browser Source:
echo       URL:    http://localhost:3500
echo       Width:  1920
echo       Height: 1080
echo.
echo  3. Say "bear with me" and the bear appears!
echo.
echo  =============================================
echo.
pause
