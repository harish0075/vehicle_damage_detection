from ultralytics import YOLO
from PIL import Image
from pathlib import Path

# Resolve from this file so the API works both locally and inside a container.
MODEL_PATH = Path(__file__).resolve().parents[2] / "runs" / "detect" / "train14" / "weights" / "best.pt"
model = YOLO(MODEL_PATH)

def detect_damage(image_path):
    results = model(image_path)
    damages = []
    
    img = Image.open(image_path)
    img_width, img_height = img.size

    for r in results:
        for box in r.boxes:
            xyxy = box.xyxy[0].cpu().numpy()
            x1, y1, x2, y2 = float(xyxy[0]), float(xyxy[1]), float(xyxy[2]), float(xyxy[3])
            
            x = x1
            y = y1
            width = x2 - x1
            height = y2 - y1
            
            confidence = float(box.conf)
            damage_type = model.names[int(box.cls)]
            
            bbox_area = width * height
            img_area = img_width * img_height
            area_ratio = bbox_area / img_area if img_area > 0 else 0
            
            if confidence > 0.8 and area_ratio > 0.15:
                severity = "Critical"
            elif confidence > 0.6 and area_ratio > 0.08:
                severity = "Severe"
            elif confidence > 0.4:
                severity = "Moderate"
            else:
                severity = "Minor"
            
            damages.append({
                "type": damage_type,
                "confidence": confidence,
                "severity": severity,
                "bbox": [x, y, width, height]  # [x, y, width, height] in pixels
            })

    return {
        "damages": damages,
        "image_width": img_width,
        "image_height": img_height
    }
