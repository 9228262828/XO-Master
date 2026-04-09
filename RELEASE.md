# XO Master - Release & Google Play Upload Guide

## Keystore Information

A release keystore has been generated for signing the app.

| Property | Value |
|----------|-------|
| Keystore file | `android/app/xo-master-release.jks` |
| Key alias | `xo-master-key` |
| Algorithm | RSA 2048-bit |
| Validity | 10,000 days (~27 years) |
| Signing config | `android/key.properties` |

> **IMPORTANT:** Keep the keystore file (`xo-master-release.jks`) and `key.properties` safe. If you lose them, you cannot update your app on Google Play. Back them up securely. These files are excluded from git via `.gitignore`.

### Generating a New Keystore

If you need to generate a new keystore (first-time setup or fresh clone):

```bash
keytool -genkey -v \
  -keystore android/app/xo-master-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias xo-master-key \
  -dname "CN=XO Master, OU=Development, O=XO Master, L=Unknown, ST=Unknown, C=US"
```

Then create `android/key.properties` from the example template:

```bash
cp android/key.properties.example android/key.properties
```

Edit `android/key.properties` and replace `YOUR_STORE_PASSWORD` and `YOUR_KEY_PASSWORD` with the passwords you chose during keystore generation.

### Verifying the Keystore

```bash
keytool -list -v -keystore android/app/xo-master-release.jks
```

## Building the Release

### App Bundle (recommended for Google Play)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### APK (for direct distribution)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Google Play Upload Checklist

Before uploading to Google Play Console, make sure you have:

- [ ] **App Bundle** (`.aab`) file built with release signing
- [ ] **App icon** — 512x512 PNG (Google Play resizes from the 1024x1024 in `app-icon/`)
- [ ] **Feature graphic** — 1024x500 PNG
- [ ] **Screenshots** — at least 2 screenshots per device type (phone, tablet)
- [ ] **Short description** — max 80 characters
- [ ] **Full description** — max 4000 characters
- [ ] **Privacy Policy URL** — host the privacy policy text from the app online
- [ ] **Content rating** — complete the IARC questionnaire
- [ ] **Target audience** — select age groups

## Suggested Store Listing

**App name:** XO Master - Tic Tac Toe

**Short description:**
Play the classic Tic Tac Toe game with a modern twist. Challenge friends or AI!

**Full description:**
XO Master is a beautifully designed Tic Tac Toe game with a modern, polished interface.

Features:
- Player vs Player mode — play with a friend on the same device
- Player vs AI mode — challenge the computer at Easy or Medium difficulty
- Beautiful animations and smooth transitions
- Dark mode support
- Sound and haptic feedback
- Score tracking across games
- Clean, modern Material 3 design

Whether you're looking for a quick game to pass the time or a competitive match against the AI, XO Master delivers a premium gaming experience.

**Category:** Games > Board

**Content rating:** Everyone

## Updating the Keystore Password

If you want to change the keystore password:

1. Edit `android/key.properties` with your new passwords
2. The keystore file password can be changed with:

```bash
keytool -storepasswd -keystore android/app/xo-master-release.jks
```

## File Structure

```
android/
  key.properties              # Signing config (gitignored)
  key.properties.example      # Template for other developers
  app/
    xo-master-release.jks     # Release keystore (gitignored)
    build.gradle.kts           # Build config with signing
    proguard-rules.pro         # ProGuard rules for release
```
