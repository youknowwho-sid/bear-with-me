@echo off
setlocal enabledelayedexpansion
title Bear With Me - Setup
color 0A

echo.
echo  =============================================
echo   🐻  Bear With Me - One Time Setup
echo  =============================================
echo.
echo  This will set everything up automatically.
echo  Just sit back and wait!
echo.
pause

:: ── Check ALL dependencies first ──────────────────────────────────────────
echo.
echo  [1/4] Checking dependencies...

set MISSING=0

:: Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  ❌ Node.js is not installed
    set MISSING=1
) else (
    for /f "tokens=2 delims=v." %%a in ('node --version') do set NODE_MAJOR=%%a
    if !NODE_MAJOR! LSS 18 (
        echo  ❌ Node.js v18+ required - you have v!NODE_MAJOR!
        set MISSING=1
    ) else (
        echo  ✅ Node.js v!NODE_MAJOR! found
    )
)

:: Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  ❌ Python is not installed
    set MISSING=1
) else (
    for /f "tokens=2 delims= " %%a in ('python --version') do set PY_VERSION=%%a
    for /f "tokens=1 delims=." %%a in ("!PY_VERSION!") do set PY_MAJOR=%%a
    for /f "tokens=2 delims=." %%a in ("!PY_VERSION!") do set PY_MINOR=%%a
    if !PY_MAJOR! LSS 3 (
        echo  ❌ Python 3.9+ required - you have !PY_VERSION!
        set MISSING=1
    ) else if !PY_MAJOR! EQU 3 if !PY_MINOR! LSS 9 (
        echo  ❌ Python 3.9+ required - you have !PY_VERSION!
        set MISSING=1
    ) else (
        echo  ✅ Python !PY_VERSION! found
    )
)

:: Exit if anything is missing
if %MISSING% EQU 1 (
    echo.
    echo  ─────────────────────────────────────────────
    echo  Please install the missing items above:
    echo.
    echo  Node.js v18+  →  https://nodejs.org
    echo  Python 3.9+   →  https://python.org/downloads
    echo  ⚠️  During Python install: check "Add Python to PATH"!
    echo.
    echo  Then restart your computer and run this again.
    echo  ─────────────────────────────────────────────
    echo.
    pause
    exit /b 1
)

:: ── Install Python packages ───────────────────────────────────────────────
echo.
echo  [2/4] Installing voice detection packages...
pip install vosk sounddevice >nul 2>&1
if %errorlevel% neq 0 (
    echo  ❌ Failed to install packages. Check your internet connection and try again.
    pause
    exit /b 1
)
echo  ✅ Voice packages installed!

:: ── Install Node packages ─────────────────────────────────────────────────
echo.
echo  [3/4] Installing server packages...
cd /d "%~dp0"
npm install >nul 2>&1
if %errorlevel% neq 0 (
    echo  ❌ Failed to install Node packages. Check your internet connection and try again.
    pause
    exit /b 1
)
echo  ✅ Server packages installed!

:: ── Download voice model ──────────────────────────────────────────────────
echo.
echo  [4/4] Downloading voice recognition model (~40MB)...
echo  (this may take a few minutes depending on your internet)
echo.

if exist "%~dp0model" (
    echo  ✅ Voice model already exists, skipping download!
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
    echo.
    echo  ❌ Failed to download the voice model.
    echo  Check your internet connection and try again.
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
