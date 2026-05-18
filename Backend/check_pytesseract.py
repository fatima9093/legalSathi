import importlib.util

spec = importlib.util.find_spec('pytesseract')
print('pytesseract' if spec else 'missing')
