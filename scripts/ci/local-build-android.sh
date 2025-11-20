#!/usr/bin/env zsh
set -euo pipefail

# Get the directory of this script
SCRIPT_DIR=${0:a:h}
REPO_ROOT=${SCRIPT_DIR:h:h}

# --- Configuration ---
# Match versions from .github/workflows/android-duckdb.yml where possible
export ANDROID_PLATFORM="android-28"
REQUIRED_NDK_VERSION="28.0.12674087"
REQUIRED_BUILD_TOOLS="35.0.0"
REQUIRED_PLATFORM="android-34"

# --- Environment Setup ---

# 1. Check for Homebrew tools (cmake, ninja)
if ! command -v cmake &> /dev/null; then
    echo "Error: cmake is not installed. Please install it (e.g., brew install cmake)."
    exit 1
fi

if ! command -v ninja &> /dev/null; then
    echo "Error: ninja is not installed. Please install it (e.g., brew install ninja)."
    exit 1
fi

# 2. Setup Android SDK
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
if [[ ! -d "$ANDROID_HOME" ]]; then
    echo "Error: ANDROID_HOME not found at $ANDROID_HOME."
    echo "Please install Android SDK or set ANDROID_HOME."
    exit 1
fi

# 3. Setup Android NDK
# Try to find the specific NDK version used in CI
DEFAULT_NDK_PATH="$ANDROID_HOME/ndk/$REQUIRED_NDK_VERSION"
export ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-$DEFAULT_NDK_PATH}"
export ANDROID_NDK="$ANDROID_NDK_HOME"

if [[ ! -d "$ANDROID_NDK_HOME" ]]; then
    echo "Warning: Specific NDK version $REQUIRED_NDK_VERSION not found at $ANDROID_NDK_HOME."
    echo "Checking for any NDK..."
    # Fallback to side-by-side NDK if available
    if [[ -d "$ANDROID_HOME/ndk" ]]; then
        LATEST_NDK=$(ls -1 "$ANDROID_HOME/ndk" | sort -V | tail -n 1)
        if [[ -n "$LATEST_NDK" ]]; then
            export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/$LATEST_NDK"
            export ANDROID_NDK="$ANDROID_NDK_HOME"
            echo "Using found NDK: $ANDROID_NDK_HOME"
        else
             echo "Error: No NDK found in $ANDROID_HOME/ndk."
             exit 1
        fi
    else
        echo "Error: NDK directory not found at $ANDROID_HOME/ndk."
        exit 1
    fi
else
    echo "Using NDK: $ANDROID_NDK_HOME"
fi

# 4. Setup Java Home
# Try to find a valid JAVA_HOME if not set
if [[ -z "${JAVA_HOME:-}" ]]; then
    if command -v /usr/libexec/java_home >/dev/null 2>&1; then
        export JAVA_HOME=$(/usr/libexec/java_home)
        echo "Using JAVA_HOME: $JAVA_HOME"
    else
        echo "Warning: JAVA_HOME not set and /usr/libexec/java_home not found."
    fi
fi

# 5. Setup vcpkg
export VCPKG_ROOT="${VCPKG_ROOT:-$HOME/vcpkg}"
if [[ ! -d "$VCPKG_ROOT" ]]; then
    echo "vcpkg not found at $VCPKG_ROOT."
    echo "Cloning vcpkg to $VCPKG_ROOT..."
    git clone https://github.com/microsoft/vcpkg.git "$VCPKG_ROOT"
    "$VCPKG_ROOT/bootstrap-vcpkg.sh" -disableMetrics
else
    echo "Using vcpkg at: $VCPKG_ROOT"
fi

# --- Execution ---

echo "Starting local Android build..."
echo "Repo Root: $REPO_ROOT"

# Ensure the build script is executable
chmod +x "$SCRIPT_DIR/build-android-duckdb.sh"

# Run the build script
"$SCRIPT_DIR/build-android-duckdb.sh"

echo "Local Android build completed."
