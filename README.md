🎙️ Voice Alarm App 
What is this app?
Voice Alarm is a Flutter app that lets you set alarms where your own recorded voice plays as the reminder. Instead of a boring beep, you hear yourself say "Take your medicine!" or "Time for yoga!" — in your own words.

How the app is organized
Think of the app like a house with different rooms, each room doing one job:
lib/
├── main.dart              ← The front door. Starts the app, sets up navigation.
│
├── models/                ← The blueprint room
│   └── alarm_model.dart   ← Describes what an alarm looks like (title, time, voice file…)
│
├── providers/             ← The memory room
│   └── alarm_provider.dart ← Remembers all your alarms, saves them, deletes them
│
├── screens/               ← The rooms you actually see
│   ├── home_screen.dart        ← Your alarm list (the home page)
│   ├── new_alarm_screen.dart   ← Where you create a new alarm
│   ├── record_voice_screen.dart ← Where you record your voice message
│   └── alarm_active_screen.dart ← What you see when the alarm goes off
│
├── widgets/               ← Reusable building blocks (like LEGO pieces)
│   ├── alarm_card.dart         ← The alarm card shown in the list
│   ├── drum_roll_time_picker.dart ← The spinning wheel to pick hours and minutes
│   └── waveform_widget.dart   ← The animated bars you see while recording
│
├── services/              ← The engine room (things that work in the background)
│   └── audio_service.dart ← Handles playing and recording audio
│
└── utils/                 ← The toolbox
    ├── app_theme.dart     ← All colors and fonts used in the app
    └── app_routes.dart    ← The list of all screen names for navigation

The 4 screens
1. Home Screen
This is the first thing you see when you open the app. It shows all your alarms in a list. Each alarm shows its name, time, and whether it's turned on or off. You can swipe left to delete an alarm. Tap the + button at the bottom to create a new one.
2. New Alarm Screen
This is where you build a new alarm. You fill in:

A title — like "Morning Yoga" or "Take Medicine"
The time — using a spinning drum wheel for hours and minutes
How often — once, daily, weekdays, or weekends
A date — picked from a calendar

When you're done, tap Record Voice Message to add your voice, or Save Without Voice to skip that.
3. Record Voice Screen
Here you tap the big blue mic button and speak your reminder out loud. You'll see animated bars bouncing while you record, and a timer counting the seconds. When you stop, you can play it back to hear how it sounds, or re-record if you want to try again. When you're happy, tap Save Alarm.
4. Alarm Active Screen
This is what pops up when your alarm fires. It shows the time in big letters, your alarm's title, and a pulsing speaker icon playing your voice. Tap Dismiss Alarm to turn it off.

How data is saved
Alarms are saved to the phone using SharedPreferences — a simple built-in storage. Every alarm is converted to JSON (a text format) and stored. When you reopen the app, they're loaded back automatically. Nothing is lost when you close the app.

Packages used (and why)
PackageWhy we use itflutter_riverpodManages the app's data (the alarm list) cleanlyaudioplayersPlays back the recorded voice when the alarm firesrecordRecords your voice from the microphoneshared_preferencesSaves your alarms to the phone's storagetable_calendarShows the calendar for picking a dateuuidGives every alarm a unique ID so they don't get mixed uppermission_handlerAsks for microphone permission on first use

How to run the app
bash# Step 1 — Download all packages
flutter pub get

# Step 2 — Run on your phone or emulator
flutter run

Note for iOS: You need to add one line to ios/Runner/Info.plist to allow microphone access:
xml<key>NSMicrophoneUsageDescription</key>
<string>Used to record your voice alarm reminders</string>

