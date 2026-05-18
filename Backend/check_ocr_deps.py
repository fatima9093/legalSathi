import importlib.util

pillow = importlib.util.find_spec('PIL') is not None
pytess = importlib.util.find_spec('pytesseract') is not None
print('PIL:', 'yes' if pillow else 'no')
print('pytesseract:', 'yes' if pytess else 'no')
