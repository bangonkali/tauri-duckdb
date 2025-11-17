#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
DUCKDB_DIR="$REPO_ROOT/third_party/duckdb"
PREP_SCRIPT="$REPO_ROOT/scripts/ci/prep.sh"
ANDROID_OUTPUT_DIR="$REPO_ROOT/android/src/main/jniLibs"
ANDROID_ABIS=("arm64-v8a" "armeabi-v7a" "x86_64")

export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-28}"
export ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-$ANDROID_HOME/ndk/28.0.12674087}"
export ANDROID_NDK="${ANDROID_NDK:-$ANDROID_NDK_HOME}"
if [[ -z "${JAVA_HOME:-}" ]]; then
  if command -v /usr/libexec/java_home >/dev/null 2>&1; then
    export JAVA_HOME=$(/usr/libexec/java_home)
  fi
fi
export VCPKG_ROOT="${VCPKG_ROOT:-$HOME/vcpkg}"

if [[ ! -d "$VCPKG_ROOT" ]]; then
  echo "VCPKG_ROOT ($VCPKG_ROOT) not found" >&2
  exit 1
fi

mkdir -p "$ANDROID_OUTPUT_DIR"

for abi in "${ANDROID_ABIS[@]}"; do
  echo "\n=== Building DuckDB for ABI: $abi ==="
  export ANDROID_ABI="$abi"
  case "$abi" in
    arm64-v8a) export VCPKG_TARGET_TRIPLET="arm64-android" ;;
    armeabi-v7a) export VCPKG_TARGET_TRIPLET="arm-android" ;;
    x86_64) export VCPKG_TARGET_TRIPLET="x64-android" ;;
    *) echo "Unsupported ABI $abi" >&2; exit 1 ;;
  esac
  export VCPKG_DEFAULT_TRIPLET="$VCPKG_TARGET_TRIPLET"

  DUCKDB_DIR="$DUCKDB_DIR" bash "$PREP_SCRIPT"

  SOURCE_LIB="$DUCKDB_DIR/build/android_${abi}/src/libduckdb.so"
  TARGET_DIR="$ANDROID_OUTPUT_DIR/$abi"
  if [[ ! -f "$SOURCE_LIB" ]]; then
    echo "DuckDB shared library not found at $SOURCE_LIB" >&2
    exit 1
  fi
  mkdir -p "$TARGET_DIR"
  cp "$SOURCE_LIB" "$TARGET_DIR/"
  echo "Copied $SOURCE_LIB -> $TARGET_DIR/"

done
