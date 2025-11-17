# Tauri Plugin duckdb

## Requirements

1. Install & bootstrap vcpkg (if you haven’t already)

```sh
git clone https://github.com/microsoft/vcpkg.git "$HOME/vcpkg"
"$HOME/vcpkg/bootstrap-vcpkg.sh" -disableMetrics
echo 'export VCPKG_ROOT="$HOME/vcpkg"' >> ~/.zshrc
source ~/.zshrc
```

1. Install spatial deps for macOS host builds (optional but recommended)
```sh
cd "$VCPKG_ROOT"
./vcpkg install proj gdal sqlite3 --triplet=arm64-osx
```

1. Install spatial deps for Android triplets used by DuckDB

```sh
cd "$VCPKG_ROOT"
./vcpkg install proj gdal sqlite3 --triplet=arm64-android
./vcpkg install proj gdal sqlite3 --triplet=arm-android
./vcpkg install proj gdal sqlite3 --triplet=x64-android
```

1. Run the DuckDB Android build script with vcpkg wired in

```sh
cd /Users/gilmichael/Desktop/Projects/tauri-plugin-duckdb
export VCPKG_ROOT="$HOME/vcpkg"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/28.0.12674087"
export ANDROID_PLATFORM=android-28
bash scripts/ci/build-android-duckdb.sh
```