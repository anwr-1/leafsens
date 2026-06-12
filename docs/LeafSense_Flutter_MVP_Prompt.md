# LeafSense MVP – Flutter + FastAPI Prompt

## Project Overview
Build **LeafSense**, a Flutter mobile app for AI-powered plant disease detection.
The user captures or uploads a leaf photo, the FastAPI backend runs inference with
a pre-trained PyTorch model, and the app returns the disease name, confidence score,
and treatment recommendation.

---

## Tech Stack
| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| Backend | Python FastAPI |
| AI Model | PyTorch – EfficientNetV2-S (`best_model.pt`) |
| Auth | Firebase Auth (email/password) |
| Storage | Firebase Firestore (scan history) |
| HTTP | `dio` package |
| Image Pick | `image_picker` package |

---

## Model Details (critical – do not change these)

```json
{
  "model": "EfficientNetV2-S",
  "framework": "PyTorch",
  "model_file": "best_model.pt",
  "num_classes": 38,
  "input_size": 224,
  "norm_mean": [0.46689, 0.48948, 0.41100],
  "norm_std":  [0.19335, 0.16824, 0.21204]
}
```

### Class Names (index 0–37)
```python
CLASS_NAMES = [
    "Apple___Apple_scab",
    "Apple___Black_rot",
    "Apple___Cedar_apple_rust",
    "Apple___healthy",
    "Blueberry___healthy",
    "Cherry_(including_sour)___Powdery_mildew",
    "Cherry_(including_sour)___healthy",
    "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot",
    "Corn_(maize)___Common_rust_",
    "Corn_(maize)___Northern_Leaf_Blight",
    "Corn_(maize)___healthy",
    "Grape___Black_rot",
    "Grape___Esca_(Black_Measles)",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
    "Grape___healthy",
    "Orange___Haunglongbing_(Citrus_greening)",
    "Peach___Bacterial_spot",
    "Peach___healthy",
    "Pepper,_bell___Bacterial_spot",
    "Pepper,_bell___healthy",
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",
    "Raspberry___healthy",
    "Soybean___healthy",
    "Squash___Powdery_mildew",
    "Strawberry___Leaf_scorch",
    "Strawberry___healthy",
    "Tomato___Bacterial_spot",
    "Tomato___Early_blight",
    "Tomato___Late_blight",
    "Tomato___Leaf_Mold",
    "Tomato___Septoria_leaf_spot",
    "Tomato___Spider_mites Two-spotted_spider_mite",
    "Tomato___Target_Spot",
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus",
    "Tomato___Tomato_mosaic_virus",
    "Tomato___healthy"
]
```

---

## Backend – FastAPI (`backend/main.py`)

### Dependencies (`requirements.txt`)
```
fastapi
uvicorn
python-multipart
torch
torchvision
Pillow
```

### Endpoints

#### `POST /predict`
- Accepts: `multipart/form-data` with field `file` (image)
- Load `best_model.pt` ONCE at startup using a global variable, never per request
- Preprocessing pipeline (must match training exactly):
  1. Open image with Pillow, convert to RGB
  2. Resize to 224×224
  3. Convert to tensor (divide by 255)
  4. Normalize with mean `[0.46689, 0.48948, 0.41100]` and std `[0.19335, 0.16824, 0.21204]`
  5. Add batch dimension: `unsqueeze(0)`
- Run inference with `torch.no_grad()`, apply softmax
- Returns JSON:
```json
{
  "plant": "Tomato",
  "disease": "Early blight",
  "is_healthy": false,
  "confidence": 0.987,
  "raw_class": "Tomato___Early_blight",
  "top3": [
    {"class": "Tomato___Early_blight", "confidence": 0.987},
    {"class": "Tomato___Late_blight",  "confidence": 0.008},
    {"class": "Tomato___healthy",      "confidence": 0.003}
  ]
}
```

#### `GET /health`
- Returns `{"status": "ok", "model_loaded": true}`

### Helper: parse class name
Split `"Tomato___Early_blight"` →  `plant = "Tomato"`, `disease = "Early blight"` (replace underscores with spaces).
If the disease part contains `"healthy"` → set `is_healthy = true`.

### CORS
Allow all origins for development: `allow_origins=["*"]`

---

## Flutter App

### `pubspec.yaml` dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  image_picker: ^1.0.7
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  cached_network_image: ^3.3.1
  flutter_animate: ^4.5.0
  google_fonts: ^6.1.0
  percent_indicator: ^4.2.3
  intl: ^0.19.0
```

---

## App Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── treatments_data.dart      ← hardcoded treatment lookup
│   └── services/
│       ├── api_service.dart           ← FastAPI calls via dio
│       └── history_service.dart       ← Firestore scan history
├── models/
│   └── prediction_result.dart
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home_screen.dart               ← main scan screen
│   ├── result_screen.dart
│   └── history_screen.dart
└── widgets/
    ├── scan_button.dart
    ├── confidence_bar.dart
    ├── result_card.dart
    └── history_tile.dart
```

---

## Design System (`core/constants/app_colors.dart`)

```dart
class AppColors {
  static const primary     = Color(0xFF1A4731);  // deep forest green
  static const accent      = Color(0xFFD47C2F);  // warm amber
  static const background  = Color(0xFFF5F0E8);  // soft cream
  static const surface     = Color(0xFFFFFFFF);  // white cards
  static const textDark    = Color(0xFF1C1C1E);
  static const textMuted   = Color(0xFF6B7280);
  static const success     = Color(0xFF22C55E);  // healthy green
  static const warning     = Color(0xFFF59E0B);  // medium confidence
  static const danger      = Color(0xFFEF4444);  // disease / low confidence
}
```

Font: `GoogleFonts.inter()` for body, `GoogleFonts.playfairDisplay()` for headings.

---

## Screens

### `splash_screen.dart`
- Show LeafSense logo (leaf icon + app name in Playfair Display) on cream background
- Check Firebase auth state → navigate to `HomeScreen` if logged in, else `LoginScreen`
- 2 second delay with fade-in animation using `flutter_animate`

### `login_screen.dart`
- Email + password fields
- "Sign In" button (primary green)
- "Don't have an account? Register" link
- Firebase `signInWithEmailAndPassword`
- On success → `HomeScreen`

### `register_screen.dart`
- Name, email, password fields
- "Create Account" button
- Firebase `createUserWithEmailAndPassword`
- On success → `HomeScreen`

### `home_screen.dart` — Main screen
- AppBar: LeafSense logo left, history icon right
- Body center:
  - Large circular scan zone with leaf illustration or placeholder
  - If image selected: show image preview in the circle
  - Two buttons below:
    - 📷 "Take Photo" → `ImagePicker().pickImage(source: ImageSource.camera)`
    - 🖼 "Choose from Gallery" → `ImagePicker().pickImage(source: ImageSource.gallery)`
  - "Analyze" FAB (amber, bottom center) — only visible when image is selected
  - On tap Analyze → show loading overlay → call `ApiService.predict()` → navigate to `ResultScreen`
- Loading overlay: semi-transparent dark overlay + circular progress + "Analyzing leaf..." text

### `result_screen.dart`
- Top: image thumbnail in a rounded card
- Result card below:
  - Plant name (large, Playfair Display)
  - Disease name OR "Healthy ✓" (green)
  - Confidence bar (`percent_indicator` linear bar):
    - >90% → green
    - 60–90% → amber
    - <60% → red + warning text "Low confidence – result may be inaccurate"
  - Top 3 predictions as small chips
  - Divider
  - Treatment section (only if not healthy):
    - "💊 Treatment" subtitle + treatment text
    - "🛡 Prevention" subtitle + prevention text
    - If class not in lookup: "Consult a local agricultural expert."
- Bottom: two buttons
  - "Scan Another" → pop back to HomeScreen and reset
  - "Save to History" → save to Firestore via `HistoryService`

### `history_screen.dart`
- AppBar: "Scan History"
- StreamBuilder from Firestore `users/{uid}/scans` ordered by timestamp desc
- Each tile: image thumbnail + plant/disease + confidence + date
- Empty state: "No scans yet. Start by scanning a leaf!"
- Tap tile → show result detail (read-only)

---

## `core/services/api_service.dart`

```dart
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // For real device use your machine's local IP e.g. 'http://192.168.1.x:8000'

  static final Dio _dio = Dio();

  static Future<PredictionResult> predict(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });
    final response = await _dio.post('$baseUrl/predict', data: formData);
    return PredictionResult.fromJson(response.data);
  }
}
```

---

## `models/prediction_result.dart`

```dart
class PredictionResult {
  final String plant;
  final String disease;
  final bool isHealthy;
  final double confidence;
  final String rawClass;
  final List<TopPrediction> top3;

  // fromJson constructor
  // toJson method
}

class TopPrediction {
  final String className;
  final double confidence;
}
```

---

## `core/constants/treatments_data.dart`

```dart
const Map<String, Map<String, String>> treatments = {
  "Tomato___Early_blight": {
    "treatment": "Apply copper-based fungicide. Remove and destroy infected leaves immediately.",
    "prevention": "Rotate crops yearly. Avoid overhead watering. Use resistant varieties.",
  },
  "Tomato___Late_blight": {
    "treatment": "Apply fungicide with chlorothalonil or mancozeb. Remove infected plants.",
    "prevention": "Plant resistant varieties. Avoid wet foliage. Ensure proper plant spacing.",
  },
  "Tomato___Leaf_Mold": {
    "treatment": "Improve ventilation. Apply fungicide. Remove affected leaves.",
    "prevention": "Reduce humidity. Avoid overhead irrigation. Space plants well.",
  },
  "Tomato___Septoria_leaf_spot": {
    "treatment": "Apply fungicide at first sign. Remove infected lower leaves.",
    "prevention": "Rotate crops. Mulch around plants. Water at soil level only.",
  },
  "Tomato___Bacterial_spot": {
    "treatment": "Apply copper-based bactericide. Remove heavily infected plants.",
    "prevention": "Use disease-free seeds. Avoid working with wet plants.",
  },
  "Tomato___Tomato_Yellow_Leaf_Curl_Virus": {
    "treatment": "No cure. Remove and destroy infected plants to prevent spread.",
    "prevention": "Control whitefly populations. Use reflective mulches. Plant resistant varieties.",
  },
  "Apple___Apple_scab": {
    "treatment": "Apply fungicide at first sign of infection. Remove fallen leaves.",
    "prevention": "Prune for airflow. Rake and destroy leaf litter in autumn.",
  },
  "Apple___Black_rot": {
    "treatment": "Prune infected branches 8 inches below visible infection. Apply fungicide.",
    "prevention": "Remove mummified fruit. Keep orchard clean. Apply dormant sprays.",
  },
  "Potato___Early_blight": {
    "treatment": "Apply fungicide containing chlorothalonil. Remove infected leaves.",
    "prevention": "Rotate crops. Use certified seed potatoes. Maintain plant vigor.",
  },
  "Potato___Late_blight": {
    "treatment": "Apply fungicide immediately. Destroy infected tubers. Harvest early.",
    "prevention": "Use certified disease-free seed. Avoid overhead irrigation.",
  },
  "Grape___Black_rot": {
    "treatment": "Apply fungicide. Remove mummified berries and infected leaves.",
    "prevention": "Prune for good air circulation. Apply protective sprays before rain.",
  },
  "Corn_(maize)___Common_rust_": {
    "treatment": "Apply fungicide if severe. Remove heavily infected leaves.",
    "prevention": "Plant resistant hybrids. Monitor fields regularly during humid weather.",
  },
  "Orange___Haunglongbing_(Citrus_greening)": {
    "treatment": "No cure available. Remove and destroy infected trees.",
    "prevention": "Control Asian citrus psyllid. Use certified disease-free nursery stock.",
  },
};
```
For any class containing `"healthy"` → show "No treatment needed. Your plant looks great!"
For any class not in the map → show "Consult a local agricultural expert for treatment advice."

---

## `core/services/history_service.dart`

```dart
// Save scan to Firestore
Future<void> saveScan(PredictionResult result, String imageLocalPath) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('scans')
      .add({
        'plant': result.plant,
        'disease': result.disease,
        'isHealthy': result.isHealthy,
        'confidence': result.confidence,
        'rawClass': result.rawClass,
        'timestamp': FieldValue.serverTimestamp(),
        'imagePath': imageLocalPath,
      });
}

// Get scan history stream
Stream<QuerySnapshot> getHistory() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('scans')
      .orderBy('timestamp', descending: true)
      .snapshots();
}
```

---

## Android Permissions (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

## iOS Permissions (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>LeafSense needs camera access to scan plant leaves</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>LeafSense needs photo library access to select leaf images</string>
```

---

## Project Structure
```
leafsense/
├── backend/
│   ├── main.py
│   ├── best_model.pt        ← place your model here
│   └── requirements.txt
├── flutter_app/             ← Flutter project root
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
└── README.md
```

---

## README to include
```markdown
## Setup

### Backend
cd backend
pip install -r requirements.txt
# Place best_model.pt in this folder
uvicorn main:app --reload --port 8000

### Flutter App
cd flutter_app
flutter pub get
# Configure Firebase: add google-services.json (Android) and GoogleService-Info.plist (iOS)
flutter run

### API URL
- Android emulator: http://10.0.2.2:8000
- Physical device: http://<your-local-ip>:8000
- Change in lib/core/services/api_service.dart
```

---

## What to Skip for MVP (add later)
- Arabic / multi-language support
- Offline mode / on-device inference
- Plant monitoring dashboard (temperature, growth tracking)
- Report generation / PDF export
- IoT sensor integration
- Push notifications
- Grad-CAM visualization overlay

---

## Quality Checklist
- [ ] Model loads once at backend startup, never per request
- [ ] Preprocessing uses exact mean/std from model metadata
- [ ] CORS allows Flutter app to reach FastAPI
- [ ] Camera + gallery both work on Android and iOS
- [ ] Loading state shown while waiting for API response
- [ ] Error state shown if API is unreachable or returns error
- [ ] Confidence < 60% shows a clear warning to the user
- [ ] History saves correctly per user (Firestore)
- [ ] App works on both Android emulator and physical device
