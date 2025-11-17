# TODO

## Immediate Goals
- [ ] Mirror Tauri SQL plugin command surface (`initDb`, `execute`, `query`, `close`, etc.) in `src/commands.rs`, `src/models.rs`, `permissions/default.toml`, and `guest-js/index.ts`.
- [ ] Add DuckDB dependency plus AppData-backed storage lifecycle in `src/lib.rs`, `src/desktop.rs`, and `src/error.rs` (bundle DB copied into AppData on first use).
- [ ] Implement mobile plumbing: `src/mobile.rs` glue plus new `ios/Plugin.swift` and `android/src/main/java/.../DuckDbPlugin.kt` exposing AppData paths and copying the seeded DB.
- [ ] Update `README.md` and `examples/tauri-app` to document Option A onboarding and demonstrate real DuckDB queries.

## Manual (User-Run) Tasks
- [ ] Build DuckDB for Android per https://duckdb.org/docs/stable/dev/building/android.html and place resulting `libduckdb.so` per ABI under `android/src/main/jniLibs/<abi>/`. *(arm64-v8a artifacts generated; copy them plus build remaining ABIs)*
- [ ] Build DuckDB for iOS per https://duckdb.org/docs/stable/dev/building/ios.html and place `libduckdb.a` per architecture under `ios/libduckdb/<arch>/`.
- [ ] Optionally seed a starter DuckDB database file to bundle with the plugin (drop under `resources/duckdb/seed.db` TBD).

## Automation / CI
- [x] Add macOS GitHub Actions workflow (`.github/workflows/android-duckdb.yml`) that installs vcpkg/Android SDK+NDK and runs `scripts/ci/build-android-duckdb.sh` to stage `android/src/main/jniLibs/**` artifacts.

## Assistant Tasks
- [ ] Wire new commands + models + permissions + guest API.
- [ ] Manage DuckDB initialization logic, including copying bundled DB into Tauri `AppData` directory and exposing SQLx-like helper methods.
- [ ] Add mobile path helpers and platform plugin bindings invoking the native DuckDB libraries you provide.
- [ ] Expand documentation and the example app so plugin consumers follow SQL plugin conventions.
