import pytesseract
from PIL import Image
import pdfplumber
from pdf2image import convert_from_path
import os

def extract_text(file_path):
    text = ""

    if file_path.lower().endswith(".pdf"):
        with pdfplumber.open(file_path) as pdf:
            for page in pdf.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text

        if text.strip():
            return text

        images = convert_from_path(file_path)
        for img in images:
            text += pytesseract.image_to_string(img)

        return text

    return pytesseract.image_to_string(Image.open(file_path))
