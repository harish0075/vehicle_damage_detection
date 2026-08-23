from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import shutil
import os
from pathlib import Path
from uuid import uuid4

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

UPLOAD_DIR = Path(__file__).resolve().parent / "uploads"
UPLOAD_DIR.mkdir(exist_ok=True)

@app.get("/")
async def root():
    return {"message": "Vehicle Damage Detection API", "status": "running"}

@app.post("/detect-damage")
async def damage_api(file: UploadFile = File(...)):
    """
    Detect vehicle damage from uploaded image.
    Returns damages with bounding boxes and image dimensions.
    """
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=415, detail="Upload an image file.")

    suffix = Path(file.filename or "upload.jpg").suffix or ".jpg"
    path = UPLOAD_DIR / f"{uuid4()}{suffix}"
    try:
        with path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        return detect_damage(path)
    finally:
        path.unlink(missing_ok=True)
