from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import shutil
import os

from models.damage_model import detect_damage

app = FastAPI(title="Vehicle Damage Detection API")

# Enable CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.get("/")
async def root():
    return {"message": "Vehicle Damage Detection API", "status": "running"}

@app.post("/detect-damage")
async def damage_api(file: UploadFile = File(...)):
    """
    Detect vehicle damage from uploaded image.
    Returns damages with bounding boxes and image dimensions.
    """
    path = f"{UPLOAD_DIR}/{file.filename}"
    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    result = detect_damage(path)
    return result
