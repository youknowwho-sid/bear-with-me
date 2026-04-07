# 🐻 Bear With Me — OBS Overlay

Whenever you say "bear with me" on stream, a bear pops up for 5 seconds.

---

## ONE-TIME SETUP (takes <10 minutes)

### Step 1 — Install Node.js
Download and install from: https://nodejs.org  
(Click the LTS version, install with all defaults)

### Step 2 — Install Python
Download and install from: https://www.python.org/downloads  
✅ On the first screen, CHECK "Add Python to PATH" before clicking Install

### Step 3 — Install Python packages
Open a terminal / command prompt and run:
```
pip install vosk sounddevice
```

### Step 4 — Download the voice model
1. Go to: https://alphacephei.com/vosk/models
2. Download **vosk-model-small-en-us-0.15** (about 40MB)
3. Unzip it
4. Rename the unzipped folder to just `model`
5. Put the `model` folder inside this bear-overlay folder

Your folder should look like:
```
bear-overlay/
  model/          ← the voice model goes here
  overlay.html
  server.js
  voice.py
  START.bat
  trigger.html
  README.md
```

### Step 5 — Install Node packages
Open a terminal in this folder and run:
```
npm install
```

---

## EVERY STREAM — HOW TO START

1. **Double-click START.bat** (or run `node server.js` in terminal)
   - You'll see "🐻 Bear Overlay is running!"
   - Keep this window open while streaming

2. **Add Browser Source in OBS:**
   - In OBS, click + under Sources → Browser
   - URL: `http://localhost:3500`
   - Width: 1920, Height: 1080
   - ✅ Check "Shutdown source when not visible"
   - Click OK

3. **That's it!** Say "bear with me" and the bear appears 🐻

---

## TESTING

Open `trigger.html` in your browser to manually fire the bear (great for testing your OBS layout).

---

## CUSTOMIZING

- **Change the phrase:** Open `server.js`, find `const PHRASE = 'bear with me'` and change it
- **Change display time:** In `overlay.html`, find `showBear()` calls and change the `5000` (milliseconds)
- **Change position:** In `overlay.html` CSS, `left: 50%` controls horizontal position (try `left: 20%` for left side)
