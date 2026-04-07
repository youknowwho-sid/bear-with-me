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

:: ── Check Node.js ─────────────────────────────────────────────────────────
echo.
echo  [1/5] Checking Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ❌ Node.js is not installed.
    echo.
    echo  Please install it first:
    echo  1. Go to https://nodejs.org
    echo  2. Click the big LTS button and install it
    echo  3. Restart your computer
    echo  4. Run this installer again
    echo.
    pause
    exit /b 1
)
echo  ✅ Node.js found!

:: ── Check Python ──────────────────────────────────────────────────────────
echo.
echo  [2/5] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ❌ Python is not installed.
    echo.
    echo  Please install it first:
    echo  1. Go to https://python.org/downloads
    echo  2. Download and run the installer
    echo  ⚠️  IMPORTANT: Check "Add Python to PATH" on the first screen!
    echo  3. Restart your computer
    echo  4. Run this installer again
    echo.
    pause
    exit /b 1
)
echo  ✅ Python found!

:: ── Install Python packages ───────────────────────────────────────────────
echo.
echo  [3/5] Installing voice detection packages...
echo  (this may take a minute)
echo.
pip install vosk sounddevice >nul 2>&1
if %errorlevel% neq 0 (
    echo  ❌ Failed to install packages. Check your internet connection and try again.
    pause
    exit /b 1
)
echo  ✅ Voice packages installed!

:: ── Install Node packages ─────────────────────────────────────────────────
echo.
echo  [4/5] Installing server packages...
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
echo  [5/5] Downloading voice recognition model (~40MB)...
echo  (this may take a few minutes depending on your internet)
echo.

if exist "%~dp0model" (
    echo  ✅ Voice model already exists, skipping download!
    goto :model_done
)

:: Use Python to download and extract the model
python -c "
import urllib.request, zipfile, os, sys, shutil

url = 'https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip'
dest = os.path.join(os.path.dirname(sys.argv[0]) if sys.argv[0] else '.', 'model.zip')
folder = os.path.join(os.path.dirname(sys.argv[0]) if sys.argv[0] else '.', 'model')

print('  Downloading...', flush=True)

def progress(count, block_size, total_size):
    pct = int(count * block_size * 100 / total_size)
    print(f'  {min(pct,100)}%%', end='\r', flush=True)

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
