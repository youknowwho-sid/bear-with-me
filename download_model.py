import urllib.request, zipfile, os, sys, shutil

base = sys.argv[1].strip().strip('"').strip("\\")
url = 'https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip'
dest = os.path.join(base, 'model.zip')
folder = os.path.join(base, 'model')

print(f'  Installing to: {base}', flush=True)

print('  Downloading...', flush=True)

def progress(count, block_size, total_size):
    pct = min(int(count * block_size * 100 / total_size), 100)
    print(f'  {pct}%', end='\r', flush=True)

urllib.request.urlretrieve(url, dest, progress)
print('\n  Download complete! Extracting...', flush=True)

with zipfile.ZipFile(dest, 'r') as z:
    z.extractall(base)

extracted = os.path.join(base, 'vosk-model-small-en-us-0.15')
if os.path.exists(extracted):
    shutil.move(extracted, folder)

os.remove(dest)
print('  Done!', flush=True)