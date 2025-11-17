#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
DUCKDB_DIR=${DUCKDB_DIR:-"${REPO_ROOT}/third_party/duckdb"}
BUILD_ROOT=${DUCKDB_BUILD_ROOT:-"${DUCKDB_DIR}/build"}

: "${DUCKDB_EXTENSIONS:=icu;json;parquet;vss;sqlite_scanner}"
: "${JAVA_HOME:=/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
: "${ANDROID_HOME:=$HOME/Library/Android/sdk}"
: "${NDK_HOME:=$ANDROID_HOME/ndk/28.0.12674087}"
: "${ANDROID_NDK_HOME:=$NDK_HOME}"
: "${ANDROID_NDK:=$ANDROID_NDK_HOME}"
: "${ANDROID_ABI:=arm64-v8a}"
: "${ANDROID_PLATFORM:=android-28}"
: "${VCPKG_ROOT:=$HOME/vcpkg}"

triplet_from_abi() {
  case "$1" in
    arm64-v8a) echo "arm64-android" ;;
    armeabi-v7a) echo "arm-android" ;;
    x86_64) echo "x64-android" ;;
    *) echo "Unsupported ANDROID_ABI: $1" >&2; return 1 ;;
  esac
}

: "${VCPKG_TARGET_TRIPLET:=$(triplet_from_abi "$ANDROID_ABI")}"
: "${VCPKG_DEFAULT_TRIPLET:=$VCPKG_TARGET_TRIPLET}"

export DUCKDB_EXTENSIONS JAVA_HOME ANDROID_HOME ANDROID_NDK_HOME ANDROID_NDK
export ANDROID_ABI ANDROID_PLATFORM VCPKG_ROOT VCPKG_DEFAULT_TRIPLET VCPKG_TARGET_TRIPLET

PATH="/opt/homebrew/bin:$PATH"
export PATH

PLATFORM_NAME="android_${ANDROID_ABI}"
BUILDDIR="${BUILD_ROOT}/${PLATFORM_NAME}"

mkdir -p "$BUILDDIR"
cd "$BUILDDIR"

cmake \
  -G "Ninja" \
  -DEXTENSION_STATIC_BUILD=1 \
  -DDUCKDB_EXTRA_LINK_FLAGS="-llog" \
  -DBUILD_EXTENSIONS=${DUCKDB_EXTENSIONS} \
  -DENABLE_EXTENSION_AUTOLOADING=1 \
  -DENABLE_EXTENSION_AUTOINSTALL=1 \
  -DCMAKE_VERBOSE_MAKEFILE=on \
  -DANDROID_PLATFORM=${ANDROID_PLATFORM} \
  -DLOCAL_EXTENSION_REPO="" \
  -DOVERRIDE_GIT_DESCRIBE="" \
  -DDUCKDB_EXPLICIT_PLATFORM=${PLATFORM_NAME} \
  -DBUILD_UNITTESTS=0 \
  -DBUILD_SHELL=1 \
  -DANDROID_ABI=${ANDROID_ABI} \
  -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
  -DVCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET} \
  -DCMAKE_BUILD_TYPE=Release ../..
cmake \
  --build . \
  --config Release
