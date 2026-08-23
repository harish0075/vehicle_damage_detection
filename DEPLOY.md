# Deploy the vehicle-damage app

This project is configured for a public Docker deployment on Render and a Flutter Android build that receives the public backend address at build time.

## 1. Publish the backend

1. Commit and push these changes to GitHub.
2. In [Render](https://render.com), choose **New > Blueprint** and select this repository. Render reads `render.yaml` and deploys the Docker image.
3. Wait until the service is live, then copy its HTTPS URL, for example `https://vehicle-damage-api.onrender.com`.
4. Open `<your-Render-URL>/docs` in a browser and test `POST /detect-damage` with an image.

The deployed service is public. Use a paid Render instance or another persistent host for reliable model inference; free instances can sleep and have a cold-start delay.

## 2. Install on your phone

From `frontend`, build an APK with the Render URL:

```powershell
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://vehicle-damage-api.onrender.com
```

Install `frontend/build/app/outputs/flutter-apk/app-release.apk` on your Android phone. The phone can use mobile data or any Wi-Fi network because it contacts the public HTTPS URL.

For quick testing on a USB-connected Android phone:

```powershell
flutter run --dart-define=API_BASE_URL=https://vehicle-damage-api.onrender.com
```

Do not use `127.0.0.1` in a phone build: it refers to the phone itself, not your computer.
