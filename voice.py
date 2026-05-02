#!/usr/bin/env python3
# voice.py — listens to mic, prints TRIGGER when phrase is heard

import sys
import json
import queue
import time
import sounddevice as sd
from vosk import Model, KaldiRecognizer

PHRASE = sys.argv[1].lower() if len(sys.argv) > 1 else "bear with me"
SAMPLE_RATE = 16000
COOLDOWN = 6

# Load model from ./model folder
try:
    model = Model("model")
except Exception as e:
    print(f"Could not load model: {e}", flush=True)
    print("Download from: https://alphacephei.com/vosk/models", flush=True)
    print("Get 'vosk-model-small-en-us-0.15' and rename the folder to 'model'", flush=True)
    sys.exit(1)

rec = KaldiRecognizer(model, SAMPLE_RATE)
rec.SetWords(True)

q = queue.Queue()

def callback(indata, frames, time, status):
    q.put(bytes(indata))

print(f"Listening for: '{PHRASE}'", flush=True)

last_triggered = 0
partial_triggered = False

with sd.RawInputStream(samplerate=SAMPLE_RATE, blocksize=8000,
                       dtype='int16', channels=1, callback=callback):
    while True:
        data = q.get()
        now = time.time()

        if rec.AcceptWaveform(data):
            result = json.loads(rec.Result())
            text = result.get("text", "").lower()
            if text:
                print(f"Heard: {text}", flush=True)
            if PHRASE in text and (now - last_triggered) > COOLDOWN:
                last_triggered = now
                print("TRIGGER", flush=True)
            partial_triggered = False
        else:
            partial = json.loads(rec.PartialResult())
            partial_text = partial.get("partial", "").lower()
            # Trigger on partial match too (faster response)
            if PHRASE in partial_text and not partial_triggered and (now - last_triggered) > COOLDOWN:
                partial_triggered = True
                last_triggered = now
                print("TRIGGER", flush=True)
