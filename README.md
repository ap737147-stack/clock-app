# 🎙️ Voice Alarm App

A personalized Flutter alarm application that uses your own recorded voice messages as alarm reminders instead of standard notification sounds.

## Features

✨ **Voice-Based Alarms** - Record your own voice messages as alarm reminders  
⏰ **Flexible Scheduling** - Set alarms for specific times, daily, weekdays, or weekends  
🎨 **Intuitive UI** - Beautiful interface with animated waveforms and spinning time pickers  
💾 **Persistent Storage** - All alarms are saved to your device using SharedPreferences  
🔊 **Playback Control** - Listen to recordings before saving or dismiss alarms quickly  
📱 **Cross-Platform** - Works on Android, iOS, Web, Windows, macOS, and Linux  

## Getting Started

### Prerequisites
- Flutter SDK (version 3.0 or higher)
- Dart 3.0+
- Android Studio / Xcode (for running on physical devices or emulators)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd clock_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### iOS-Specific Setup
Add microphone usage permission to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used to record your voice alarm reminders</string>
```

## Project Structure

```
lib/
├── main.dart                    # App entry point and navigation setup
├── models/
│   └── alarm_model.dart         # Alarm data model (title, time, voice file, etc.)
├── providers/
│   └── alarm_provider.dart      # State management - manages alarm list and persistence
├── screens/
│   ├── home_screen.dart         # Main alarm list view
│   ├── new_alarm_screen.dart    # Create/edit alarm interface
│   ├── record_voice_screen.dart # Voice recording interface
│   └── alarm_active_screen.dart # Active alarm notification view
├── widgets/
│   ├── alarm_card.dart          # Individual alarm card component
│   ├── drum_roll_time_picker.dart # Spinning time selector wheel
│   └── waveform_widget.dart     # Animated audio waveform visualization
├── services/
│   └── audio_service.dart       # Audio playback and recording logic
└── utils/
    ├── app_theme.dart           # App themes, colors, and typography
    └── app_routes.dart          # Route definitions and navigation
```

## Screens Overview

### Home Screen
The main dashboard displaying all your alarms in a list. Each alarm shows:
- Alarm title and time
- On/off toggle switch
- Swipe left to delete functionality
- Floating action button (+) to create new alarms

### New Alarm Screen
Create or edit an alarm with:
- Title input field
- Time selection using spinning drum wheel (hours & minutes)
- Recurrence options (Once, Daily, Weekdays, Weekends)
- Calendar date picker
- Options to record voice message or save without voice

### Record Voice Screen
Record your voice reminder:
- Large microphone button to start/stop recording
- Animated waveform visualization during recording
- Timer showing recording duration
- Playback controls to listen to your recording
- Re-record option if needed
- Save alarm button when satisfied

### Alarm Active Screen
Triggered when the alarm fires:
- Large time display
- Alarm title
- Pulsing speaker icon with playing audio
- Dismiss button to turn off alarm

## Dependencies

| Package | Purpose |
|---------|---------|
| **flutter_riverpod** | State management and data persistence |
| **audioplayers** | Audio playback functionality |
| **record** | Voice recording from device microphone |
| **shared_preferences** | Local device storage for alarms |
| **table_calendar** | Calendar widget for date selection |
| **uuid** | Generate unique IDs for each alarm |
| **permission_handler** | Request microphone permissions |

## Data Persistence

Alarms are stored locally using SharedPreferences as JSON objects. Data automatically persists across app sessions - no internet connection required. All data stays on your device.

## Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk
```

**iOS:**
```bash
flutter build ios
```

**Web:**
```bash
flutter build web
```

## Troubleshooting

**Microphone not working?**
- Ensure microphone permission is granted in app settings
- Check that your device's microphone is not muted

**Alarms not persisting?**
- Verify SharedPreferences is properly initialized
- Check device storage isn't full

**Audio playback issues?**
- Ensure volume isn't muted
- Try reinstalling the app to reset audio settings

---

**Made with ❤️ using Flutter**

