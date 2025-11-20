# Tauri Plugin DuckDB - Android Edition

A Tauri plugin that integrates DuckDB database with Android mobile applications. This plugin provides a high-performance, embedded SQL database solution for Tauri v2 mobile apps.

## 🚀 Features

- ✅ DuckDB embedded database for Android
- ✅ Full Tauri v2 support
- ✅ Mobile-optimized sample application
- ✅ Automated CI/CD with GitHub Actions
- ✅ APK and AAB builds available for download

## 📱 Demo Application

The example app showcases the DuckDB plugin integration with a mobile-friendly UI. You can download pre-built APK or AAB files from the [GitHub Actions artifacts](../../actions/workflows/android-duckdb.yml).

### Quick Start

1. Download the latest APK from GitHub Actions
2. Install on your Android device (requires Android 9.0+ / API 28+)
3. Open the app and test DuckDB functionality

## 🛠️ Local Development Guide

Follow these instructions to set up a clean environment and build the project from scratch on macOS.

### 1. Prerequisites

1.  **Install Rust**
    ```sh
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```

2.  **Install Bun (and Node.js)**
    ```sh
    curl -fsSL https://bun.sh/install | bash
    ```

3.  **Install Build Tools** (via Homebrew)
    ```sh
    brew install cmake ninja
    ```

4.  **Install Android Studio**
    - Open Android Studio -> SDK Manager.
    - **SDK Platforms:** Check "Android 34".
    - **SDK Tools:** Check "NDK (Side by side)" and install version `28.0.12674087`.
    - Ensure `ANDROID_HOME` is set in your shell (usually `export ANDROID_HOME="$HOME/Library/Android/sdk"`).

### 2. Build the Project

**Step 1: Clone the repository**
```sh
git clone https://github.com/bangonkali/tauri-duckdb.git
cd tauri-duckdb
```

**Step 2: Build Native DuckDB Libraries**
Run the local build script. This handles `vcpkg` setup and compiles the C++ libraries for Android.
```sh
chmod +x scripts/ci/local-build-android.sh
./scripts/ci/local-build-android.sh
```
*Note: This step can take 10-20 minutes as it compiles DuckDB from source.*

**Step 3: Build the Demo App**
```sh
cd examples/tauri-app
bun install
bun tauri android init
bun tauri android build
```

### 3. Run the App

After the build completes, you can find the artifacts here:

- **APK:** `examples/tauri-app/src-tauri/gen/android/app/build/outputs/apk/universal/debug/app-universal-debug.apk`
- **AAB:** `examples/tauri-app/src-tauri/gen/android/app/build/outputs/bundle/universalDebug/app-universal-debug.aab`

Drag and drop the APK onto an Android Emulator or install it on your device using `adb install <path-to-apk>`.

## 📦 Using in Your Project

### 1. Add the Plugin

Add to your `src-tauri/Cargo.toml`:

```toml
[dependencies]
tauri-plugin-duckdb = { git = "https://github.com/bangonkali/tauri-duckdb" }
```

### 2. Register the Plugin

In your `src-tauri/src/lib.rs`:

```rust
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_duckdb::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 3. Use from JavaScript

```javascript
import { ping } from 'tauri-plugin-duckdb-api'

// Test the plugin
const result = await ping("Hello from DuckDB!")
console.log(result)
```

### 4. Initialize Android Project

```sh
cd your-app
bun tauri android init
```

## 🔧 Building DuckDB Libraries (Manual / Advanced)

The `local-build-android.sh` script above automates this process. Only follow these steps if you need to customize the build manually.

### Android

```sh
# Install vcpkg (if you haven't already)
git clone https://github.com/microsoft/vcpkg.git "$HOME/vcpkg"
"$HOME/vcpkg/bootstrap-vcpkg.sh" -disableMetrics
export VCPKG_ROOT="$HOME/vcpkg"

# Build DuckDB for Android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/28.0.12674087"
export ANDROID_PLATFORM=android-28
bash scripts/ci/build-android-duckdb.sh
```

This will create the native libraries in `android/src/main/jniLibs/` for different ABIs:
- `arm64-v8a/` - 64-bit ARM devices (most modern phones)
- `armeabi-v7a/` - 32-bit ARM devices
- `x86_64/` - 64-bit x86 emulators

## 🤖 CI/CD

The project uses GitHub Actions for automated builds:

- **Android DuckDB Build** - Builds native DuckDB libraries and the demo app
- **CI** - Runs Rust and TypeScript checks

### Workflow: Android DuckDB Plugin and Demo App

Located at `.github/workflows/android-duckdb.yml`, this workflow:

1. Builds DuckDB native libraries for all Android ABIs
2. Builds the example Tauri app as APK and AAB
3. Uploads artifacts for download

To download builds:
1. Go to [Actions](../../actions/workflows/android-duckdb.yml)
2. Click on the latest successful run
3. Scroll to "Artifacts" section
4. Download `android-apk-universal`, `android-apk-debug`, or `android-aab`

## 📝 API Reference

### Commands

#### `ping(message: string): Promise<string>`

Test command to verify the plugin is working.

```javascript
import { ping } from 'tauri-plugin-duckdb-api'

const response = await ping("Test message")
```

*More commands coming soon as the plugin API is expanded.*

## 🗺️ Roadmap

- [x] Basic plugin structure
- [x] Android build pipeline
- [x] Demo application
- [x] CI/CD for APK/AAB builds
- [ ] Complete DuckDB command API (query, execute, etc.)
- [ ] Database initialization and lifecycle management
- [ ] AppData storage integration
- [ ] Documentation and examples

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [DuckDB](https://duckdb.org/) - High-performance analytical database
- [Tauri](https://tauri.app/) - Build smaller, faster, and more secure desktop and mobile applications
