# Vehicle Damage Detection

An AI-powered mobile application for detecting, analyzing, and tracking vehicle damage using machine learning and computer vision.

## 📱 Overview

Vehicle Damage Detection is a comprehensive solution that combines Flutter frontend development with advanced machine learning capabilities to identify and assess vehicle damage in real-time. The application provides users with an intuitive interface to capture vehicle images and receive instant damage analysis.

## 🎯 Features

- **Real-time Damage Detection**: AI-powered image recognition to identify vehicle damage
- **Image Capture & Processing**: Easy-to-use camera integration for damage documentation
- **Damage Analysis**: Detailed assessment and tracking of identified damage
- **Cloud Integration**: Firebase backend for authentication and data storage
- **Material Design UI**: Modern, responsive user interface built with Flutter
- **Data Visualization**: Charts and analytics for damage tracking
- **User Authentication**: Secure login with Google Sign-In support

## 🛠 Tech Stack

### Frontend
- **Framework**: Flutter/Dart (68% of codebase)
- **UI Components**: Material Design with Cupertino icons
- **State Management**: Provider pattern
- **HTTP Client**: Dio for API requests
- **Image Handling**: Image Picker & File Picker
- **Charts**: FL Chart for data visualization
- **Backend Services**: Firebase (Auth, Firestore, Google Sign-In)

### Backend & ML
- **Languages**: C++ (13.7%), Python (4.9%), Swift (1.3%)
- **Build System**: CMake (10.5%)
- **ML Framework**: TensorFlow/ML model integration for damage detection

### Supporting Technologies
- C (0.8%) for performance-critical components
- Custom native modules for image processing

## 📋 Requirements

### Development Environment
- **Dart SDK**: >=3.2.0 <4.0.0
- **Flutter**: Latest stable version
- **Node.js/npm**: For backend services (if applicable)
- **CMake**: For building native components

### Dependencies
Key packages included:
- `flutter` - Core Flutter framework
- `provider: ^6.1.5+1` - State management
- `dio: ^5.4.0` - HTTP networking
- `image_picker: ^1.0.7` - Camera/gallery integration
- `firebase_core: ^4.4.0`, `firebase_auth: ^6.1.4`, `cloud_firestore: ^6.1.2` - Backend services
- `fl_chart: ^0.66.0` - Data visualization
- `google_sign_in: 6.2.1` - Authentication

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Git
- Firebase project setup
- Android SDK (for Android development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/harish0075/vehicle_damage_detection.git
cd vehicle_damage_detection
```

2. Navigate to the frontend directory:
```bash
cd frontend
```

3. Install Flutter dependencies:
```bash
flutter pub get
```

4. Set up Firebase configuration:
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place them in their respective platform directories

5. Run the application:
```bash
flutter run
```

## 📁 Project Structure

```
vehicle_damage_detection/
├── frontend/                 # Flutter/Dart frontend application
│   ├── lib/                 # Main application code
│   ├── pubspec.yaml         # Dart dependencies
│   ├── android/             # Android-specific files
│   └── ios/                 # iOS-specific files
├── CMakeLists.txt           # Build configuration for native code
├── src/                     # C++ source files (ML/processing)
├── python/                  # Python scripts (data processing/training)
└── README.md               # This file
```

## 🤖 Machine Learning

The application integrates ML models for vehicle damage detection:
- Image preprocessing and normalization
- Object detection and classification
- Damage severity assessment
- Training scripts for model improvement

## 🔐 Authentication

- **Firebase Authentication**: Secure user login
- **Google Sign-In**: One-click authentication
- **Session Management**: Persistent user sessions

## 📊 Data Management

- **Cloud Firestore**: Real-time database for damage records
- **Local Storage**: Offline capability with path_provider
- **Analytics**: Usage tracking and damage statistics

## 🎨 UI/UX

- **Material Design**: Follows Google Material Design guidelines
- **Responsive Layout**: Adapts to various screen sizes
- **Loading States**: Shimmer effects for better UX
- **Internationalization**: Multi-language support with Intl package

## 🔄 API Integration

The application communicates with backend services via:
- **Dio HTTP Client**: For API requests
- **RESTful endpoints**: Structured API communication
- **Error Handling**: Comprehensive error management

## 📝 Development Guidelines

### Code Style
- Follow Dart style guide
- Use meaningful variable/function names
- Comment complex logic
- Maintain consistent formatting

### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🐛 Known Issues & Limitations

- iOS deployment may require additional configuration
- ML model requires adequate device memory
- Internet connection needed for cloud features

## 🚀 Future Enhancements

- Offline ML model deployment
- Multi-language support expansion
- Advanced damage severity classification
- Integration with insurance APIs
- Real-time damage assessment reports
- Mobile app optimization for low-end devices

## 📄 License

This project is currently unlicensed. Please check with the repository owner for licensing information.

## 📞 Contact & Support

- **Author**: harish0075
- **Repository**: https://github.com/harish0075/vehicle_damage_detection
- **Issues**: Please use the GitHub Issues tab for bug reports and feature requests

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Firebase for backend services
- ML/AI community for research and tools

---

**Last Updated**: 2026-07-05
**Status**: Active Development
