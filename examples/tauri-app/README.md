# DuckDB Demo - Tauri Mobile App

A sample Tauri v2 mobile application demonstrating the DuckDB plugin integration.

## Features

- 🦆 DuckDB plugin integration
- 📱 Mobile-friendly responsive UI
- 🎨 Modern gradient design
- 🔌 Real-time plugin connectivity test

## Building

### Prerequisites

- Node.js and pnpm
- Rust toolchain
- Android SDK and NDK (for Android builds)

### Development

```sh
# Install dependencies
pnpm install

# Run development server
pnpm dev
```

### Android Build

```sh
# Build frontend
pnpm build

# Build APK
pnpm tauri android build --apk

# Build AAB for Play Store
pnpm tauri android build --aab
```

### Testing on Device

1. Enable "Developer Options" on your Android device
2. Enable "USB Debugging"
3. Connect your device via USB
4. Run: `pnpm tauri android dev`

Or install the built APK:
```sh
adb install src-tauri/gen/android/app/build/outputs/apk/universal/release/*.apk
```

## Project Structure

```
.
├── src/                    # Frontend source code
│   ├── App.svelte         # Main application component
│   └── main.js            # Application entry point
├── src-tauri/             # Tauri/Rust backend
│   ├── src/
│   │   └── lib.rs         # Rust application code
│   ├── gen/android/       # Generated Android project
│   └── tauri.conf.json    # Tauri configuration
└── package.json           # Node.js dependencies
```

## Download Pre-built APK

You can download pre-built APK files from the [GitHub Actions page](https://github.com/bangonkali/tauri-duckdb/actions/workflows/android-duckdb.yml).

## Learn More

- [Tauri Documentation](https://tauri.app/)
- [DuckDB Documentation](https://duckdb.org/)
- [Svelte Documentation](https://svelte.dev/)
