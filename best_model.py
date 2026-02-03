from ultralytics import YOLO
import yaml

def main():
    with open("runs/detect/tune/best_hyperparameters.yaml") as f:
        hyp = yaml.safe_load(f)

    model = YOLO("yolo11s.pt")

    model.train(
        data="vehicle_damage_dataset/data.yaml",
        epochs=100,
        imgsz=640,
        device=0,
        **hyp
    )

if __name__ == "__main__":
    main()
