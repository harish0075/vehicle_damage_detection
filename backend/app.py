from fastapi import FastAPI, UploadFile, File
import shutil
import os

from models.damage_model import detect_damage
from services.ocr_service import extract_text
from models.nlp_model import parse_insurance
from services.bill_service import generate_bill

app = FastAPI()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.post("/detect-damage")
async def damage_api(file: UploadFile = File(...)):
    path = f"{UPLOAD_DIR}/{file.filename}"
    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    damages = detect_damage(path)
    return {"damages": damages}


@app.post("/process-insurance")
async def insurance_api(file: UploadFile = File(...)):
    path = f"{UPLOAD_DIR}/{file.filename}"
    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    text = extract_text(path)
    info = parse_insurance(text)
    return info


@app.post("/generate-bill")
async def bill_api(data: dict):
    return generate_bill(data["damages"], data["insurance"])


@app.post("/claim")
async def claim_api(
    vehicle_image: UploadFile = File(...),
    insurance_doc: UploadFile = File(...)
):
    vehicle_path = f"{UPLOAD_DIR}/{vehicle_image.filename}"
    insurance_path = f"{UPLOAD_DIR}/{insurance_doc.filename}"

    with open(vehicle_path, "wb") as buffer:
        shutil.copyfileobj(vehicle_image.file, buffer)

    with open(insurance_path, "wb") as buffer:
        shutil.copyfileobj(insurance_doc.file, buffer)

    damages = detect_damage(vehicle_path)

    text = extract_text(insurance_path)
    policy = parse_insurance(text)

    bill = generate_bill(damages, policy)

    return {
        "damages": damages,
        "policy": policy,
        "bill": bill
    }
