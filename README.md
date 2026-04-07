# 🎙️ Voice Alarm

A Flutter app that lets you wake up to **your own voice**. Record a personal reminder — *"Take your medicine!"*, *"Time for yoga!"* — and it plays back when the alarm fires.

<br/>


<br/>

## ✨ Features

- 🎤 **Record your own voice** as the alarm sound
- 🔁 **Flexible repeat** — Once, Daily, Weekdays, Weekends
- 📅 **Date picker** with a calendar to pick a specific day
- ⏰ **Drum-roll time picker** — smooth scrolling HH : MM wheel
- 🔊 **Playback preview** before saving the alarm
- 💾 **Persistent storage** — alarms survive app restarts
- 🗑️ **Swipe to delete** any alarm
- 🔔 **Active alarm screen** with ripple animation and dismiss button

<br/>

## 🗂️ Project Structure

```
lib/
├── main.dart                          # App entry point & named routes
│
├── models/
│   └── alarm_model.dart               # Alarm data class (toJson / fromJson)
│
├── providers/
│   └── alarm_provider.dart            # Riverpod StateNotifier — CRUD + persistence
│
├── screens/
│   ├── home_screen.dart               # Alarm list screen
│   ├── new_alarm_screen.dart          # Create / edit alarm screen
│   ├── record_voice_screen.dart       # Mic recording screen
│   └── alarm_active_screen.dart       # Firing alarm screen
│
├── widgets/
│   ├── alarm_card.dart                # Swipeable alarm list card with toggle
│   ├── drum_roll_time_picker.dart     # Custom ListWheelScrollView time picker
│   └── waveform_widget.dart          # Animated recording waveform bars
│
├── services/
│   └── audio_service.dart             # Audio playback + recording state providers
│
└── utils/
    ├── app_theme.dart                 # AppColors & ThemeData
    └── app_routes.dart                # Route name constants
```

<br/>

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / Xcode (for device/emulator)

### Installation

```bash
# 1. Clone the repo
git clone https://github.com/your-username/voice_alarm_app.git
cd voice_alarm_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

<br/>

## 🔑 Permissions

### Android
Already declared in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### iOS
Add this to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used to record your voice alarm reminders</string>
```

<br/>

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.4.9 | State management |
| `audioplayers` | ^5.2.1 | Voice playback |
| `record` | ^5.0.4 | Microphone recording |
| `shared_preferences` | ^2.2.2 | Alarm persistence |
| `table_calendar` | ^3.0.9 | Date picker calendar |
| `uuid` | ^4.3.3 | Unique alarm IDs |
| `intl` | ^0.18.1 | Date formatting |
| `permission_handler` | ^11.1.0 | Runtime permissions |

<br/>

## 🧭 Navigation Flow

```
HomeScreen
    │
    ├──► NewAlarmScreen
    │         │
    │         └──► RecordVoiceScreen
    │                     │
    │                     └──► HomeScreen (after save)
    │
    └──► AlarmActiveScreen (when alarm fires)
```

<br/>

## 🛠️ How to Extend

**Add a new screen**
1. Create `lib/screens/your_screen.dart`
2. Add a route constant in `lib/utils/app_routes.dart`
3. Register it in `main.dart` under `routes:`

**Add a new field to alarms**
1. Add the field in `alarm_model.dart`
2. Update `toJson()` and `fromJson()` in the same file
3. Update `copyWith()` so existing code still works

**Change colors or fonts**
Edit `lib/utils/app_theme.dart` — changes apply everywhere automatically.

<br/>


<p align="center">Built with ❤️ using Flutter</p>
