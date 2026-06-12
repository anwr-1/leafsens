# LeafSense 🌿

AI-powered plant disease detection — Flutter mobile app + FastAPI backend.

Upload or photograph a plant leaf and get instant disease identification, confidence score, and treatment recommendations powered by a pre-trained EfficientNetV2-S PyTorch model.

---

## Project Structure

```
leafsense/
├── backend/
│   ├── main.py           ← FastAPI app (inference endpoint)
│   ├── best_model.pt     ← Place your PyTorch model here
│   └── requirements.txt
├── flutter_app/          ← Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── firebase_options.dart   ← STUB – replace with real Firebase config
│   │   ├── core/
│   │   │   ├── constants/          ← colors, text styles, treatments
│   │   │   └── services/           ← ApiService (Dio), HistoryService (Firestore)
│   │   ├── models/                 ← PredictionResult, TopPrediction
│   │   ├── screens/                ← splash, login, register, home, result, history
│   │   └── widgets/                ← scan_button, confidence_bar, result_card, history_tile
│   ├── android/
│   └── ios/
└── README.md
```

---

## Backend Setup

### Requirements
- Python 3.9+
- PyTorch (CPU is fine for development)

### Install & Run

```bash
cd backend
pip install -r requirements.txt

# Place your trained model in the backend folder:
# cp /path/to/best_model.pt ./best_model.pt

uvicorn main:app --reload --port 8000
```

### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET`  | `/health` | Check if server and model are ready |
| `POST` | `/predict` | Upload image → get disease prediction |

### Test the API

```bash
curl -F "file=@leaf.jpg" http://localhost:8000/predict
```

---

## Flutter App Setup

### Prerequisites
- Flutter SDK 3.x ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio / Xcode for running on device/emulator
- Android emulator or physical device

### Install dependencies

```bash
cd flutter_app
flutter pub get
```

### Configure Firebase (Required for Auth + History)

1. Go to [Firebase Console](https://console.firebase.google.com) and create a project.
2. Enable **Authentication** → Email/Password sign-in method.
3. Enable **Firestore Database** (start in test mode for development).
4. Add an Android app (package: `com.leafsense.leafsense`):
   - Download `google-services.json`
   - Place it in `flutter_app/android/app/`
5. Add an iOS app (bundle ID: `com.leafsense.leafsense`):
   - Download `GoogleService-Info.plist`
   - Place it in `flutter_app/ios/Runner/`
6. Run FlutterFire CLI to regenerate `firebase_options.dart`:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

> **Without Firebase config**: The app will still run. Image capture and API calls work,
> but auth screens will fail and history won't save.

### Run the app

```bash
cd flutter_app
flutter run
```

---

## API URL Configuration

The app is configured for **Android emulator** by default (`http://10.0.2.2:8000`).

For a **physical device** (both Android & iOS), change the base URL in:
`lib/core/services/api_service.dart`

```dart
// Change this line:
static const String baseUrl = 'http://10.0.2.2:8000';
// To your machine's local IP:
static const String baseUrl = 'http://192.168.1.42:8000';  // example
```

Find your local IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux).

---

## Model Details

| Property | Value |
|----------|-------|
| Architecture | EfficientNetV2-S |
| Framework | PyTorch |
| Classes | 38 (plant diseases + healthy) |
| Input size | 224 × 224 px |
| Normalization mean | `[0.46689, 0.48948, 0.41100]` |
| Normalization std | `[0.19335, 0.16824, 0.21204]` |

---

## Features

- 📸 **Camera capture** and gallery image selection
- 🤖 **AI inference** via EfficientNetV2-S (38 plant disease classes)
- 📊 **Confidence bar** — color coded (green/amber/red) with low-confidence warning
- 💊 **Treatment + Prevention** recommendations for all disease classes
- 🏆 **Top 3 predictions** displayed per scan
- 🔐 **Firebase Auth** — email/password login & registration
- 📜 **Scan History** — stored in Firestore per user
- 🗑 **Delete scans** from history

---

## What's Planned (Post-MVP)

- Arabic / multi-language support
- Offline mode / on-device inference (TFLite)
- Plant monitoring dashboard
- PDF report generation
- IoT sensor integration
- Push notifications
- Grad-CAM heatmap overlay

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile | Flutter (Dart) |
| Backend | Python FastAPI |
| AI Model | PyTorch – EfficientNetV2-S |
| Auth | Firebase Authentication |
| Storage | Cloud Firestore |
| HTTP | Dio |
| Image | image_picker |
| UI | flutter_animate, google_fonts, percent_indicator |
