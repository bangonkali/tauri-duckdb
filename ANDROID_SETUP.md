# Android Setup and Build Guide

This document provides detailed instructions for setting up and building the Android DuckDB demo app.

## Prerequisites

### Required Software

1. **Rust** (latest stable)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Node.js** and **pnpm**
   ```bash
   # Install Node.js 20.x
   # Then install pnpm
   npm install -g pnpm
   ```

3. **Android Studio** (recommended) or Android SDK CLI tools
   - Download from https://developer.android.com/studio
   - During installation, ensure Android SDK is installed

4. **Android SDK Components**
   - Platform: Android 14 (API 34)
   - Build Tools: 35.0.0
   - NDK: 28.0.12674087

### Environment Variables

Add these to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
# macOS
export ANDROID_HOME="$HOME/Library/Android/sdk"

# Linux
export ANDROID_HOME="$HOME/Android/Sdk"

# Both
export NDK_HOME="$ANDROID_HOME/ndk/28.0.12674087"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
```

### Install Android Rust Targets

```bash
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
```

## Building the App

### 1. Clone and Setup

```bash
git clone https://github.com/bangonkali/tauri-duckdb.git
cd tauri-duckdb/examples/tauri-app
pnpm install
```

### 2. Build Frontend

```bash
pnpm build
```

### 3. Build Android

#### Debug Build (for development)

```bash
pnpm tauri android dev
```

This will:
- Build the Rust library for Android
- Compile the Android app
- Install and run on connected device/emulator

#### Release APK (universal)

```bash
pnpm tauri android build --apk
```

Output: `src-tauri/gen/android/app/build/outputs/apk/universal/release/app-universal-release-unsigned.apk`

#### Release AAB (for Google Play)

```bash
pnpm tauri android build --aab
```

Output: `src-tauri/gen/android/app/build/outputs/bundle/universalRelease/app-universal-release.aab`

#### Split APKs (by ABI)

```bash
pnpm tauri android build --apk --split-per-abi
```

This creates separate APKs for each architecture:
- `app-arm64-v8a-release-unsigned.apk` (64-bit ARM)
- `app-armeabi-v7a-release-unsigned.apk` (32-bit ARM)
- `app-x86_64-release-unsigned.apk` (64-bit x86)

## Installing on Device

### Via USB

1. Enable Developer Options on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times

2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging

3. Connect device and verify:
   ```bash
   adb devices
   ```

4. Install:
   ```bash
   adb install src-tauri/gen/android/app/build/outputs/apk/universal/release/*.apk
   ```

### Download Pre-built APK

1. Go to [GitHub Actions](https://github.com/bangonkali/tauri-duckdb/actions/workflows/android-duckdb.yml)
2. Click on the latest successful workflow run
3. Scroll to "Artifacts" section
4. Download `android-apk-universal` or `android-apk-debug`
5. Extract and install the APK on your device

## Signing for Release

For production releases, you need to sign the APK/AAB:

### 1. Generate Keystore

```bash
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

### 2. Configure Gradle Signing

Edit `src-tauri/gen/android/app/build.gradle.kts`:

```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file("/path/to/my-release-key.jks")
            storePassword = "your-store-password"
            keyAlias = "my-key-alias"
            keyPassword = "your-key-password"
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 3. Build Signed Release

```bash
pnpm tauri android build --apk
# or
pnpm tauri android build --aab
```

## Troubleshooting

### NDK Not Found

```bash
# Ensure NDK is installed
sdkmanager --install "ndk;28.0.12674087"

# Verify NDK_HOME is set
echo $NDK_HOME
```

### Build Fails with "No Android device found"

For APK/AAB builds, you don't need a device. Use:
```bash
pnpm tauri android build --apk --target aarch64-linux-android
```

### Gradle Build Fails

Try cleaning:
```bash
cd src-tauri/gen/android
./gradlew clean
cd ../../..
pnpm tauri android build --apk
```

### Rust Compilation Errors

Ensure Android targets are installed:
```bash
rustup target list | grep android
```

## CI/CD

The project includes a GitHub Actions workflow that automatically:
1. Builds DuckDB native libraries
2. Builds the Android app as APK and AAB
3. Uploads artifacts for download

Workflow location: `.github/workflows/android-duckdb.yml`

## Additional Resources

- [Tauri Mobile Docs](https://tauri.app/develop/mobile/)
- [Android Developer Guide](https://developer.android.com/guide)
- [DuckDB Documentation](https://duckdb.org/docs/)
