# 🐻 Bear With Me — OBS Overlay for Twitch/Kick/Youtube 

An OBS overlay that listens to your microphone and automatically triggers a bear animation whenever you say **"bear with me"** on stream.

---

## Requirements

Before anything else, install these two free programs:

- **Node.js v18 or higher** — [nodejs.org](https://nodejs.org) (click the LTS button, install with all defaults)
- **Python 3.9 or higher** — [python.org/downloads](https://python.org/downloads) ⚠️ During install, check **"Add Python to PATH"** on the first screen!

---

## Setup (One Time Only)

1. Download this repo — click the green **Code** button → **Download ZIP**
2. Unzip the folder somewhere on your computer
3. Double-click **`INSTALL.bat`** and wait for it to finish

That's it! The installer handles everything else automatically.

---

## Every Stream

1. Double-click **`START.bat`**
2. First time only — in OBS add a **Browser Source**:
   - URL: `http://localhost:3500`
   - Width: `1920`
   - Height: `1080`
3. Say **"bear with me"** on stream and the bear appears! 🐻

> After the first time, you only need to double-click START.bat — OBS remembers the Browser Source.

---

## Multiple Scenes

If you have more than one scene in OBS (e.g. a small corner cam and a large center cam), add a Browser Source to each scene with a different URL:

| Scene | URL |
|---|---|
| Webcam in bottom-right corner | `http://localhost:3500?pos=right` |
| Large center webcam | `http://localhost:3500?pos=center` |
| Webcam in bottom-left corner | `http://localhost:3500?pos=left` |

---

## Manual Trigger

Open `trigger.html` in your browser to fire the bear manually — great for testing your OBS layout before going live.

---

## Customizing

**Change the trigger phrase** — open `server.js` and find:
```
const PHRASE = 'bear with me';
```

**Change how long the bear stays** — open `overlay.html` and find:
```
function showBear(ms = 6000)
```
Change `6000` to however many milliseconds you want (1000 = 1 second).

**Move the bear left/right** — open `overlay.html` and find:
```
wrap.style.right = '0px';
```
Increase the number to move it further left, decrease to move it right.

---

## Troubleshooting

**Bear doesn't appear:**
- Make sure `START.bat` is still running (don't close that window while streaming)
- Right-click the Browser Source in OBS → Refresh

**Voice not detecting:**
- Make sure your mic is set as the default recording device in Windows
- Check the START.bat window — it prints what it hears in real time

**INSTALL.bat failed:**
- Make sure you checked "Add Python to PATH" during Python install
- Check your internet connection and run INSTALL.bat again

---

## Privacy

Voice recognition runs **completely offline** using [Vosk](https://alphacephei.com/vosk/). Your mic audio never leaves your computer.
