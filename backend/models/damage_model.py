from ultralytics import YOLO

model = YOLO("../runs/detect/train/weights/best.pt")

def detect_damage(image_path):
    results = model(image_path)
    damages = []

    for r in results:
        for box in r.boxes:
            damages.append({
                "type": model.names[int(box.cls)],
                "confidence": float(box.conf)
            })

    return damages
