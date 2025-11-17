#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
DUCKDB_DIR="${DUCKDB_DIR:-"$REPO_ROOT/third_party/duckdb"}"
IOS_OUTPUT_DIR="${IOS_OUTPUT_DIR:-"$REPO_ROOT/ios/libduckdb"}"
BUILD_ROOT="${DUCKDB_BUILD_ROOT:-"$DUCKDB_DIR/build"}"
IOS_ARCHS=("arm64" "x86_64")

: "${CMAKE_OSX_DEPLOYMENT_TARGET:=13.0}"
: "${BUILD_TYPE:=Release}"
: "${GENERATOR:=Xcode}"

mkdir -p "$IOS_OUTPUT_DIR"

configure_and_build() {
  local arch="$1"
  local sdk="$2"
  local platform_label="$3"
  local build_dir="$BUILD_ROOT/ios_${arch}"
  local config_dir="${build_dir}/src/${BUILD_TYPE}-${platform_label}"

  echo "\n=== Building DuckDB for iOS (${arch}, SDK: ${sdk}) ==="
  cmake -S "$DUCKDB_DIR" -B "$build_dir" \
    -G "$GENERATOR" \
    -DBUILD_UNITTESTS=OFF \
    -DBUILD_SHELL=OFF \
    -DBUILD_EXTENSIONS="icu;json;parquet;vss;sqlite_scanner" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_OSX_ARCHITECTURES="$arch" \
    -DCMAKE_OSX_SYSROOT="$sdk" \
    -DCMAKE_IOS_INSTALL_COMBINED=YES \
    -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=YES \
    -DCMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET="$CMAKE_OSX_DEPLOYMENT_TARGET" \
    -DDUCKDB_EXPLICIT_PLATFORM="ios_${arch}" \
    -DENABLE_EXTENSION_AUTOLOADING=ON \
    -DENABLE_EXTENSION_AUTOINSTALL=ON \
    -DOVERRIDE_GIT_DESCRIBE="" \
    -DLOCAL_EXTENSION_REPO=""

  cmake --build "$build_dir" --config "$BUILD_TYPE" --target duckdb_static

  local source_lib="${config_dir}/libduckdb_static.a"
  if [[ ! -f "$source_lib" ]]; then
    echo "Expected static library not found at $source_lib" >&2
    exit 1
  fi

  local target_dir="$IOS_OUTPUT_DIR/$arch"
  mkdir -p "$target_dir"
  cp "$source_lib" "$target_dir/libduckdb.a"
  echo "Copied $source_lib -> $target_dir/libduckdb.a"
}

for arch in "${IOS_ARCHS[@]}"; do
  case "$arch" in
    arm64)
      configure_and_build "$arch" "iphoneos" "iphoneos"
      ;;
    x86_64)
      configure_and_build "$arch" "iphonesimulator" "iphonesimulator"
      ;;
    *)
      echo "Unsupported iOS architecture: $arch" >&2
      exit 1
      ;;
  esac
done
