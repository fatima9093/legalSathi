from pypdf import PdfReader

reader = PdfReader("E:\legalSathi\data\PAHAW 2010.pdf")

full_text = ""

for page in reader.pages:
    text = page.extract_text()
    if text:
        full_text += text + "\n"

print(full_text[:1000])




