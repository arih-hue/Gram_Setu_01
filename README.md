# 🌉 Gram Setu — Rural Telemedicine Mobile App

> **Setu Banao, Sehat Pao** — Build the bridge. Reach the last mile.

Gram Setu is a mobile telemedicine application built with **Flutter & Dart**, designed to connect rural patients in India with qualified doctors via live video consultation — in their own language, on any Android device, with no extra hardware required.

---

## 📱 Overview

600 million+ rural Indians lack meaningful access to healthcare. Doctors are concentrated in cities, language barriers block diagnosis, and digital health infrastructure is virtually nonexistent at the last mile.

Gram Setu bridges that gap with:
- 📹 Live video consultations between patients and doctors
- 💓 Contactless heart rate monitoring via the phone camera (rPPG)
- 🌐 Dynamic multilingual UI powered by Sarvam AI
- 🩺 An active consultation dashboard for doctors

---

## ✨ Features

### 1. Video Call Module
- Doctors launch calls directly from the **Active Consultations** screen
- App requests camera and microphone permissions on launch
- Displays live camera feed fullscreen
- Single **Hang Up** button returns the doctor to the dashboard

### 2. rPPG Vitals Monitoring
- Uses **Remote Photoplethysmography (rPPG)** to estimate heart rate from the phone's front camera
- Powered by the [rPPG-Toolbox](https://github.com/ubicomplab/rPPG-Toolbox) by UbiComp Lab
- Zero wearables, zero cost, real clinical value

### 3. Multilingual Support
- Language selector button in the app header
- Powered by the **Sarvam AI Translation API**
- Supports Hindi, Tamil, Bengali, Telugu, and more
- Entire UI translates dynamically on language change

### 4. Doctor Consultation Dashboard
- Active consultations view for doctors
- One-tap video call launch per patient
- Real-time rPPG vitals display during calls

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Vitals Monitoring | rPPG-Toolbox (UbiComp Lab) |
| Translation | Sarvam AI API |
| Video Calls | WebRTC-ready architecture |
| State Management | Provider / Riverpod (as used in project) |
| Platform | Android & iOS |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.0.0
- Dart >= 3.0.0
- Android Studio or VS Code with Flutter plugin
- Android SDK (API level 21+) for Android builds
- Xcode 14+ for iOS builds (macOS only)

Verify your Flutter installation:

```bash
flutter doctor
```

### Installation

```bash
# Clone the repository
git clone https://github.com/arih-hue/Gram_Setu_01.git
cd Gram_Setu_01

# Install dependencies
flutter pub get
```

### Running the App

### Step 1 — Start the Backend (Node.js)

1. Open a terminal and navigate to the backend/ folder:
   bash
   cd backend
   npm install
   npm start
   

2. Once the server starts, you will see output like this in your terminal:
   
   ✅ Server running on:
   🖥  Local:    http://localhost:3000
   🌐 Network:  http://192.168.1.5:3000   ← YOUR IPv4 ADDRESS WILL APPEAR HERE
   

3. *Copy the Network IP address* (e.g. 192.168.1.5). You will need it in the next step.

> 💡 *Don't see a Network address?* Find your IPv4 manually:
> - *Windows*: Open Command Prompt → run ipconfig → look for IPv4 Address
> - *Mac/Linux*: Open Terminal → run ifconfig or ip a → look for inet under your Wi-Fi adapter

---

### Step 2 — Configure the Flutter App with YOUR IPv4 Address

> 🔴 *THIS STEP IS MANDATORY IF YOU ARE RUNNING THE APP ON A PHYSICAL MOBILE DEVICE.*
> Without this, the app will not connect to your backend and nothing will work.

Open this file in your code editor:


lib/core/constants.dart


You will see something like this:

dart
// ─────────────────────────────────────────────────────────────
// JUDGES / EVALUATORS — READ THIS CAREFULLY
// ─────────────────────────────────────────────────────────────
//
// If you are running the app on a PHYSICAL Android/iOS device:
//
//   1. Set usePhysicalIp = true
//   2. Replace the IP below with YOUR computer's IPv4 address
//      (the one shown in the backend terminal after npm start)
//
// If you are running on an EMULATOR or WEB, leave it as false.
// ─────────────────────────────────────────────────────────────

const bool usePhysicalIp = false;        // ← Change to TRUE for physical device

const String _manualIp  = '192.168.1.5'; // ← REPLACE THIS WITH YOUR IPv4 ADDRESS


#### ✅ If running on a physical phone:
dart
const bool usePhysicalIp = true;
const String _manualIp  = 'YOUR.COMPUTER.IP.HERE'; // e.g. '192.168.1.42'


#### ✅ If running on an emulator or browser:
dart
const bool usePhysicalIp = false; // No changes needed — localhost works automatically


> ⚠️ *Your phone and your computer MUST be connected to the same Wi-Fi network.*
> The app will not reach the backend over mobile data or a different network.

---

```bash
# Run on connected Android device or emulator
flutter run

# Run on iOS simulator (macOS only)
flutter run -d ios

# Build APK for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## 🔬 rPPG Integration

Gram Setu uses the [rPPG-Toolbox](https://github.com/ubicomplab/rPPG-Toolbox) for contactless heart rate estimation.

**How it works:**
1. The front camera captures a continuous video feed via Flutter's `camera` plugin
2. rPPG detects subtle color changes in the face caused by blood flow (photoplethysmography)
3. Heart rate (BPM) is estimated and displayed in real time — no wearables required

All rPPG logic is isolated in `lib/services/rppg_service.dart` and does not touch any backend or existing app state.

**Key Flutter packages used:**

```yaml
dependencies:
  camera: ^0.10.5
  permission_handler: ^11.0.1
```

---

## 🌍 Multilingual Support (Sarvam AI)

The language change button in the app header allows patients and doctors to switch the UI language instantly.

**Supported languages:**

| Language | Code |
|---|---|
| Hindi | hi |
| Tamil | ta |
| Bengali | bn |
| Telugu | te |
| English | en |

All translation logic lives in `lib/services/translation_service.dart`. Language state is managed globally via `lib/providers/language_provider.dart`. Translations are fetched dynamically via the Sarvam AI API — nothing is hardcoded.

---

## 📂 Project Structure

```
gram_setu/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── video_call_screen.dart      # New: live camera feed + hang up
│   │   ├── rppg_monitor_screen.dart    # New: rPPG vitals display
│   │   ├── active_consultations.dart   # Existing: doctor dashboard
│   │   └── ...                         # Other existing screens
│   ├── services/
│   │   ├── translation_service.dart    # New: Sarvam AI API wrapper
│   │   └── rppg_service.dart           # New: rPPG logic
│   ├── providers/
│   │   └── language_provider.dart      # New: global language state
│   ├── widgets/                        # Reusable UI widgets
│   └── models/                         # Data models
├── android/
├── ios/
├── assets/
├── pubspec.yaml
├── .env                                # API keys (not committed)
└── README.md
```

---

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5               # Camera feed for video call & rPPG
  permission_handler: ^11.0.1   # Camera & mic permissions
  flutter_dotenv: ^5.1.0        # Environment variable management
  http: ^1.1.0                  # API calls to Sarvam AI
  provider: ^6.1.1              # State management (language context)
```

---

## 📋 How It Works

```
Patient                          Doctor
  │                                │
  ├─ Opens app                     │
  ├─ Selects language (Sarvam AI)  │
  ├─ Joins consultation queue      │
  │                                ├─ Views Active Consultations
  │                                ├─ Taps video call button
  │◄──────── Video Call ──────────►│
  │  (rPPG monitors heart rate)    │
  │                                ├─ Diagnoses & advises
  └─ Hang up → back to home        └─ Hang up → back to dashboard
```

---

## 🗺 Roadmap

- [x] Live video consultations
- [x] rPPG heart rate monitoring
- [x] Multilingual UI (Sarvam AI)
- [x] Doctor consultation dashboard
- [x] E-prescription module
- [x] ASHA worker integration
- [ ] District health API integration
- [ ] Offline-first mode
- [ ] Live rPPG deployment at scale

---

## 🙏 Acknowledgements

- [rPPG-Toolbox](https://github.com/ubicomplab/rPPG-Toolbox) — UbiComp Lab, University of Washington
- [Sarvam AI](https://api.sarvam.ai) — Indian language translation API
- [Flutter](https://flutter.dev) — Google's UI toolkit for cross-platform apps
- Built with ❤️ for rural India at the Mobile App Development Hackathon 2026
