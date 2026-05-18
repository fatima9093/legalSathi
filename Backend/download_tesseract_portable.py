import os
import sys
import json
import urllib.request
from pathlib import Path
import zipfile
import shutil

BASE = Path(__file__).resolve().parent
TOOLS = BASE / "tools" / "tesseract"
TOOLS.mkdir(parents=True, exist_ok=True)

API = 'https://api.github.com/repos/UB-Mannheim/tesseract/releases/latest'
headers = {'User-Agent': 'legalSathi-agent'}

print('Querying latest UB-Mannheim tesseract release...')
req = urllib.request.Request(API, headers=headers)
with urllib.request.urlopen(req) as resp:
    data = json.load(resp)

assets = data.get('assets', [])
print(f'Found {len(assets)} assets in latest release')
for i, a in enumerate(assets[:20], 1):
    print(f'{i}: {a.get("name")} -> {a.get("browser_download_url")}')

# Prefer a windows zip asset
candidate = None
for a in assets:
    name = (a.get('name') or '').lower()
    url = a.get('browser_download_url')
    if not url:
        continue
    if name.endswith('.zip') and ('win' in name or 'windows' in name or 'win64' in name or 'win32' in name):
        candidate = (name, url)
        break

if candidate is None:
    print('\nNo zip asset found for Windows in latest release. Saving installer assets list to tools/tesseract/assets.json and downloading first .exe if available.')
    (BASE / 'tools' / 'tesseract').mkdir(parents=True, exist_ok=True)
    with open(TOOLS / 'assets.json', 'w', encoding='utf-8') as f:
        json.dump(assets, f, indent=2)
    # try to find an exe asset
    exe = None
    for a in assets:
        name = (a.get('name') or '').lower()
        url = a.get('browser_download_url')
        if url and (name.endswith('.exe') or 'installer' in name):
            exe = (name, url)
            break
    if exe:
        print(f"Found installer asset: {exe[0]}; downloading to tools/tesseract/")
        dest = TOOLS / exe[0]
        urllib.request.urlretrieve(exe[1], str(dest))
        print(f"Downloaded installer to {dest}")
    else:
        print('No installer .exe asset found either. Please provide a portable zip or installer.')
    sys.exit(0)

name, url = candidate
print(f'Chosen asset: {name} -> {url}')
zip_path = TOOLS / name
print(f'Downloading to {zip_path} ...')
urllib.request.urlretrieve(url, str(zip_path))
print('Download complete. Extracting...')

try:
    with zipfile.ZipFile(zip_path, 'r') as z:
        z.extractall(TOOLS)
    print(f'Extracted zip to {TOOLS}')
except zipfile.BadZipFile:
    print('Downloaded file is not a zip or is corrupted. Saved at', zip_path)
    sys.exit(1)

# Search for tesseract.exe and copy needed files into TOOLS dir
exe_paths = list(TOOLS.rglob('tesseract.exe'))
if not exe_paths:
    print('tesseract.exe not found in extracted files. Listing TOOLS contents:')
    for p in TOOLS.iterdir():
        print(' -', p)
    print('Please examine the extracted artifacts. If you have a portable tesseract.exe, place it under Backend/tools/tesseract/')
    sys.exit(1)

found = exe_paths[0]
print('Found tesseract executable at', found)
# If found is not directly in TOOLS, copy the containing folder files to TOOLS
parent = found.parent
if parent != TOOLS:
    print('Copying runtime files from', parent, 'to', TOOLS)
    for item in parent.iterdir():
        dest = TOOLS / item.name
        if item.is_dir():
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(item, dest)
        else:
            shutil.copy2(item, dest)
    print('Copy complete')

final_exe = TOOLS / 'tesseract.exe'
if final_exe.exists():
    print('Portable tesseract ready at', final_exe)
else:
    print('Expected tesseract.exe at', final_exe, 'but not present.')

print('Done.')
