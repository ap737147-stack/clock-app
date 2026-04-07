# Clock App - Quick Start

## First Time Setup (5 mins)

Make sure Flutter is installed, then:

```bash
# Get all the packages
flutter pub get

# Check everything is set up right
flutter doctor
```

Should show green checkmarks. If not, you need to fix stuff.

## Run It

```bash
flutter run
```

Installs on your phone/emulator and launches the app. Done.

## Build It

For the final app file:

```bash
# APK file you can send to someone
flutter build apk

# For Play Store
flutter build appbundle
```

## Something Broke?

```bash
flutter clean
flutter pub get
flutter run
```

Clears everything and starts fresh.

---

## What This App Does

- Create alarms with voice messages
- Alarms trigger with notifications
- Can set them to repeat (daily, weekly, etc)
- Turn them on/off with a toggle
- Delete by swiping

---

See **BUILD_DOCUMENTATION.md** for the full story of how this was built and what problems I had to fix.

**Last Updated:** April 7, 2026
