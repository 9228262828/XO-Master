# XO Master – Tic Tac Toe

A modern, polished Tic Tac Toe mobile game built with Flutter.

## Features

- **Player vs Player** – Play with a friend on the same device
- **Player vs AI** – Challenge the computer with Easy or Medium difficulty
- **Score Tracking** – Keeps track of wins, losses, and draws
- **Smooth Animations** – Tap animations, win line drawing, score transitions
- **Dark Mode** – Full dark mode support with a toggle
- **Modern UI** – Clean, responsive, production-ready design

## Project Structure

```
lib/
├── core/
│   ├── app_theme.dart       # Theme definitions (light/dark)
│   └── constants.dart        # App constants and enums
├── features/
│   └── game/
│       ├── logic/
│       │   ├── game_logic.dart      # Win/draw detection, AI (minimax)
│       │   └── game_controller.dart # Game state management
│       ├── presentation/
│       │   ├── home_screen.dart     # Main menu
│       │   └── game_screen.dart     # Game play screen
│       └── widgets/
│           ├── game_board.dart      # 3x3 grid board
│           ├── game_cell.dart       # Individual cell with animations
│           ├── score_board.dart     # Score display
│           └── win_line_painter.dart # Animated win line
├── services/
│   └── theme_service.dart    # Theme mode management
└── main.dart                 # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android SDK (for Android builds)

### Run the App

```bash
# Get dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

## Keystore Setup (for Release Builds)

### 1. Generate a Keystore

```bash
keytool -genkey -v \
  -keystore android/app/xo-master-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias xo_master
```

### 2. Create key.properties

Create `android/key.properties` with:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=xo_master
storeFile=app/xo-master-release.jks
```

### 3. Build Release

```bash
flutter build apk --release
flutter build appbundle --release
```

## App Identity

- **App Name:** XO Master
- **Package Name:** com.xomaster.game
- **Min SDK:** 21 (Android 5.0)

## License

This project is proprietary. All rights reserved.
