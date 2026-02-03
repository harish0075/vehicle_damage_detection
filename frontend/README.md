# Vehicle Health Tracker - Flutter Frontend

A premium Flutter mobile application for tracking vehicle damage history, repairs, and insurance claims.

## Features

- **Damage Detection**: AI-powered damage detection via camera or gallery images
- **Insurance Processing**: Automated OCR + NLP for insurance document processing
- **Claim Submission**: Complete claim workflow with bill breakdown
- **Health Timeline**: Visual timeline of all damage events and repairs
- **Cost Trends**: Charts and insights showing repair costs over time

## Prerequisites

- Flutter SDK (3.2.0 or higher)
- Android Studio / Xcode (for emulator/simulator)
- FastAPI backend running

## Setup Instructions

### 1. Install Dependencies

```bash
cd frontend
flutter pub get
```

### 2. Configure API Base URL

Edit `lib/services/api_config.dart` and update the `baseUrl`:

```dart
// For Android emulator:
static const String baseUrl = 'http://10.0.2.2:8000';

// For iOS simulator:
static const String baseUrl = 'http://localhost:8000';

// For physical device (use your computer's IP):
static const String baseUrl = 'http://192.168.x.x:8000';
```

### 3. Run the App

```bash
flutter run
```

## Project Structure

- `models/` - Data models (Damage, Insurance, Bill, HealthRecord)
- `providers/` - State management (Provider pattern)
- `services/` - API integration and utilities
- `screens/` - All app screens
- `widgets/` - Reusable UI components
- `theme/` - Dark theme configuration

## API Endpoints

- `POST /detect-damage` - Damage detection from image
- `POST /process-insurance` - Insurance PDF processing
- `POST /generate-bill` - Bill generation
- `POST /claim` - Full claim submission

## Theme

Car dashboard-inspired dark theme with electric blue accent, neon green highlights, and premium gradients.

## Troubleshooting

**Camera/Gallery not working**: Add permissions in AndroidManifest.xml or Info.plist

**Backend connection issues**: 
- Check API base URL in `api_config.dart`
- Use `10.0.2.2` for Android emulator
- Ensure backend is running on port 8000

**Build issues**: Run `flutter clean && flutter pub get`

## Testing Flows

1. Damage Detection: Camera → Detect → Save to Timeline
2. Insurance Upload: Select PDF → Process → View details
3. Claim Submission: Upload both → Submit → View bill
4. Timeline: View all damage records
5. Trends: View cost and frequency charts
