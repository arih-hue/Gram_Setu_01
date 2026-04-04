# Gram Setu - ग्राम सेतु

*Bridging Rural Healthcare*  
A Flutter + Node.js platform that connects *villagers, ASHA workers, doctors, and panchayat* for seamless healthcare access, registration, and video consultations.

![Gram Setu Logo](assets/images/logo.png)  

## 🎯 Problem It Solves
In rural India, accessing quality healthcare is difficult due to distance, lack of doctors, and poor connectivity.  
*Gram Setu* acts as a digital bridge to enable:
- Easy patient registration & login
- Telemedicine (video consultation with doctors)
- Role-based access for ASHA workers, doctors, and panchayat members
- Patient vitals and records sharing

## ✨ Key Features (Current + Planned)

### Implemented
- Beautiful, clean Flutter UI with medical theme (light mode)
- Home Dashboard with 4 role-based cards (Patient, ASHA Worker, Doctor, Panchayat)
- Fully designed *Patient Login Screen* (UID/Phone + Password)
- Emergency access button
- Complete *Node.js backend* structure (MongoDB ready)
- Assets and images integrated

### In Progress / Next
- Jitsi Meet video calling for doctor-patient consultation
- Language support (English ↔ Hindi)
- Doctor & ASHA dashboards to view patient details

## 🛠 Tech Stack

- *Frontend*: Flutter (Dart) – Cross-platform (Android, iOS, Web)
- *Backend*: Node.js + Express (MongoDB planned)
- *Video Calling*: Jitsi Meet SDK (planned)
- *Translation*: LibreTranslate (planned)

## 🚀 How to Run the Project

### 1. Flutter App
```bash
# Clone the repo and switch to harsh branch
git clone https://github.com/arih-hue/Gram_Setu_01.git
cd Gram_Setu_01
git checkout harsh

# Install dependencies
flutter pub get

# Run the app
flutter run