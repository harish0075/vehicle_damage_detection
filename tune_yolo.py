from ultralytics import YOLO

model = YOLO("yolo11s.pt")

model.tune(
    data="vehicle_damage_dataset/data.yaml",
    epochs=20,          # short training per trial
    iterations=20,      # number of GA generations
    imgsz=640,
    device=0,
    optimizer="AdamW"
)
