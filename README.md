# 🌿 LeafSense (طبيب النباتات)

LeafSense is a smart, offline-first Flutter application designed to help farmers, gardeners, and plant enthusiasts diagnose plant diseases instantly using advanced on-device AI. 

Just point your camera at a leaf, and LeafSense will identify the plant, diagnose its health, and provide actionable treatment recommendations—all completely offline without needing an internet connection.

---

## ✨ Features

* **🤖 100% Offline AI Diagnostics**: Powered by a highly optimized custom TensorFlow Lite model (`leafsense_model.tflite`). No API keys, no cloud processing, and absolute privacy for your photos.
* **📸 Real-time Camera Integration**: Instantly snap a photo of any leaf for lightning-fast analysis.
* **🌍 Rich Arabic Knowledge Base**: Get highly detailed, localized information including symptoms, potential causes, and recommended treatments in clear Arabic.
* **🌤️ Live Weather Integration**: A built-in weather widget to help you understand environmental factors that might be affecting your plants' health.
* **🚀 Cross-Platform**: Optimized and completely ready for export on both Android and iOS.

---

## 🛠️ Technology Stack

* **Framework**: [Flutter](https://flutter.dev/) & Dart
* **AI & Machine Learning**: `tflite_flutter` (TensorFlow Lite)
* **Backend & Auth**: [Supabase](https://supabase.com/)
* **Local Storage**: `shared_preferences`
* **Architecture**: Clean Architecture with modular service layers

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (version 3.19.0 or higher recommended)
* Android Studio (for Android builds) or Xcode (for iOS builds)
* A valid `leafsense_model.tflite` model placed inside `mobile/assets/models/`

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/leafsense.git
   cd leafsense/mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Build for Android:**
   ```bash
   flutter build apk --release
   ```

---

## 📂 Project Structure

```text
mobile/
├── android/             # Android native code
├── ios/                 # iOS native code
├── assets/
│   └── models/          # Contains the offline TFLite AI model
├── lib/
│   ├── core/            # Constants, theme data, and core services (API, Auth)
│   ├── models/          # Dart data models (e.g., PredictionResult)
│   ├── screens/         # UI screens (Home, Result, Auth, History)
│   └── widgets/         # Reusable UI components
└── pubspec.yaml         # Dependencies and asset declarations
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/your-username/leafsense/issues).

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
