from ultralytics import YOLO

model = YOLO("runs/detect/train/weights/best.pt")

results = model("try1.png")

for r in results:
    for box in r.boxes:
        cls = int(box.cls)
        conf = float(box.conf)
        print(model.names[cls], conf)
