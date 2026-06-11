# SafeWear — AI-Powered Personal Safety System

> Wearable safety platform for the MENA region. Detects threats, dispatches emergency alerts, and streams live location — all without the user having to speak or act.

Developed for the **INJAZ Al-Arab Company Program 2025–2026** (Algeria).

---

## Overview

SafeWear is a two-component personal safety system consisting of a **Flutter mobile app** (iOS & Android) and a **smartwatch companion** (Wear OS + Apple Watch). When danger is detected — manually, via voice command, or automatically through biometric anomaly detection — the system simultaneously:

- Pushes FCM notifications to all trusted contacts with a live GPS link
- Falls back to **Twilio SMS** when internet is unavailable
- Streams **live GPS** to Firestore every 5 seconds
- Records **audio evidence** and uploads to Firebase Storage
- Optionally notifies **Algerian police (Alshorta)** or medical services

A 20-second cancellable countdown prevents false alarms.

---

## Features

| Feature | Details |
|---|---|
| **SOS Button** | One tap triggers 20-second countdown → simultaneous alert to all contacts |
| **Voice Trigger** | "SafeWear contacts / police / save me" activates silent mode |
| **3 Response Modes** | Contacts only · Contacts + police · Maximum (contacts + police + medical) |
| **Heart Rate Monitor** | Continuous via watch — detects spikes, grey-zone (110–130 bpm), fall |
| **Fall Detection** | 3g impact + 10s inactivity via accelerometer |
| **Wrist Removal Alert** | Fires if watch is forcibly detached |
| **Safe Zones** | Geofence alerts when a family member leaves home/school |
| **Risk Map** | Crowd-sourced heatmap of high-risk areas in Algiers |
| **SMS Fallback** | Twilio SMS via Firebase Cloud Function when offline |
| **Subscription Tiers** | Free · App · Watch+App · Family — manual SOS always free |

---

## Tech Stack

**Mobile App**
- Flutter (Dart) — iOS & Android
- Firebase: Auth (Phone OTP) · Firestore · Storage · FCM · Cloud Functions
- Riverpod 2.x · GoRouter
- Google Maps Flutter · Geolocator
- `record` package for audio · `flutter_blue_plus` for BLE

**Wear OS App** (`/wear_os`)
- Kotlin · Android HealthServices API
- Heart rate + accelerometer + gyroscope
- DataClient → Flutter method channel

**Apple Watch App** (`/ios/SafeWearWatch`)
- Swift · WatchKit · HealthKit · CoreMotion
- WatchConnectivity → Flutter platform channel

**Backend** (`/functions`)
- Firebase Cloud Functions (TypeScript)
- Twilio SMS API
- FCM push dispatch · Risk pin aggregation · Watch connection monitoring

---

## Project Structure

```
safewear/
├── lib/
│   ├── app/              # Theme, router
│   ├── features/
│   │   ├── auth/         # Onboarding flow (language → profile → contacts → mode)
│   │   ├── dashboard/    # Home, Alerts, Device, Profile tabs
│   │   ├── emergency/    # 20-second countdown screen
│   │   └── contacts/     # Trusted contacts management
│   ├── services/
│   │   ├── alert_service.dart     # Core SOS dispatch logic
│   │   ├── location_service.dart  # Background GPS
│   │   ├── audio_service.dart     # Recording + Firebase Storage upload
│   │   └── sms_service.dart       # Twilio fallback
│   └── shared/
│       └── models/       # UserProfile, AlertEvent, TrustedContact...
├── wear_os/              # Kotlin Wear OS app
│   └── SensorService.kt  # HR + fall detection + grey zone
├── ios/SafeWearWatch/    # Native Swift Apple Watch app
│   ├── ContentView.swift
│   └── SensorManager.swift
└── functions/            # Firebase Cloud Functions
    └── src/index.ts
```

---

## Getting Started

### Prerequisites
- Flutter 3.x
- Firebase project with Phone Auth, Firestore, Storage, FCM enabled
- Twilio account (for SMS fallback)

### Setup

1. Clone the repo
   ```bash
   git clone https://github.com/nour-zamiche/safewear.git
   cd safewear
   ```

2. Add Firebase config files (not committed — keep these secret):
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart` (generate with `flutterfire configure`)

3. Install dependencies
   ```bash
   flutter pub get
   ```

4. Run
   ```bash
   flutter run
   ```

---

## Roadmap

- [x] Onboarding flow (language · profile · contacts · mode · safe zones)
- [x] Manual SOS + 20-second countdown
- [x] Dashboard (Home · Alerts · Device · Profile tabs)
- [x] Alert dispatch service (FCM + SMS fallback + GPS + audio)
- [x] Wear OS sensor service (HR + fall + grey zone)
- [x] Apple Watch app (HealthKit + WatchConnectivity)
- [x] Firebase Cloud Functions (SMS · FCM · heatmap)
- [x] Risk map heatmap (Algiers, crowd-sourced reports)
- [x] Safe zones (add/remove, persisted)
- [x] Medical profile screen (blood type, conditions, medications)
- [x] Alert history screen (local records)
- [x] Fake call feature (discreet exit from unsafe situations)
- [x] Local persistence — works fully offline, Firebase optional
- [ ] Voice activation
- [ ] Subscription tier gating
- [ ] Live Google Maps integration (replaces painted maps)

---

## License

MIT — see [LICENSE](LICENSE)

---

*Built by [Nour Zamiche](https://nourzamiche.vercel.app) · INJAZ Al-Arab 2025–2026*
