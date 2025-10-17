#!/bin/bash

# Build script for espeak-ng on Apple platforms
# This script builds espeak-ng for macOS (x86_64, arm64) and iOS (arm64, x86_64 simulator)
# and packages them into an XCFramework

set -e

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$PROJECT_ROOT/vendor/espeak-ng"
BUILD_DIR="$PROJECT_ROOT/build"
OUTPUT_DIR="$PROJECT_ROOT/Output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Clean previous builds
clean_build() {
    echo_info "Cleaning previous builds..."
    rm -rf "$BUILD_DIR"
    rm -rf "$OUTPUT_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$OUTPUT_DIR"
}

# Build for a specific architecture
build_for_arch() {
    local platform=$1
    local arch=$2
    local sdk=$3
    local min_version=$4

    echo_info "Building for $platform ($arch)..."

    local build_path="$BUILD_DIR/${platform}-${arch}"
    mkdir -p "$build_path"

    cd "$VENDOR_DIR"

    # Clean any previous configuration
    if [ -f Makefile ]; then
        make distclean || true
    fi

    # Run autogen if needed
    if [ ! -f configure ]; then
        echo_info "Running autogen.sh..."
        ./autogen.sh
    fi

    # Set up compiler flags based on platform
    local cflags="-arch $arch -isysroot $(xcrun --sdk $sdk --show-sdk-path)"
    local ldflags="-arch $arch -isysroot $(xcrun --sdk $sdk --show-sdk-path)"

    if [ "$platform" == "macos" ]; then
        cflags="$cflags -mmacosx-version-min=$min_version"
        ldflags="$ldflags -mmacosx-version-min=$min_version"
    elif [ "$platform" == "ios" ]; then
        cflags="$cflags -mios-version-min=$min_version"
        ldflags="$ldflags -mios-version-min=$min_version"
    elif [ "$platform" == "iossimulator" ]; then
        cflags="$cflags -mios-simulator-version-min=$min_version"
        ldflags="$ldflags -mios-simulator-version-min=$min_version"
    fi

    # Configure and build
    echo_info "Configuring..."
    CC=clang \
    CXX=clang++ \
    CFLAGS="$cflags" \
    CXXFLAGS="$cflags" \
    LDFLAGS="$ldflags" \
    ./configure \
        --prefix="$build_path" \
        --host=${arch}-apple-darwin \
        --disable-shared \
        --enable-static \
        --without-pcaudiolib \
        --without-klatt \
        --without-sonic \
        --without-mbrola

    echo_info "Building..."
    make -j$(sysctl -n hw.ncpu)

    echo_info "Installing to $build_path..."
    make install

    cd "$PROJECT_ROOT"
}

# Create XCFramework from built libraries
create_xcframework() {
    echo_info "Creating XCFramework..."

    local framework_args=""

    # Add each built library
    for build_path in "$BUILD_DIR"/*; do
        if [ -d "$build_path" ]; then
            local lib_path="$build_path/lib/libespeak-ng.a"
            local headers_path="$build_path/include/espeak-ng"

            if [ -f "$lib_path" ]; then
                framework_args="$framework_args -library $lib_path -headers $headers_path"
            fi
        fi
    done

    # Create the XCFramework
    xcodebuild -create-xcframework \
        $framework_args \
        -output "$OUTPUT_DIR/EspeakNG.xcframework"

    echo_info "XCFramework created at $OUTPUT_DIR/EspeakNG.xcframework"
}

# Copy espeak-ng-data
copy_data() {
    echo_info "Copying espeak-ng-data..."

    # Use the data from the first successful build
    local data_source=""
    for build_path in "$BUILD_DIR"/*; do
        if [ -d "$build_path/share/espeak-ng-data" ]; then
            data_source="$build_path/share/espeak-ng-data"
            break
        fi
    done

    if [ -z "$data_source" ]; then
        echo_error "Could not find espeak-ng-data in any build output"
        exit 1
    fi

    cp -r "$data_source" "$PROJECT_ROOT/Sources/EspeakNG/Resources/"
    echo_info "Data copied to Sources/EspeakNG/Resources/espeak-ng-data"
}

# Main build process
main() {
    echo_info "Starting espeak-ng build process..."

    clean_build

    # Detect native architecture
    local native_arch=$(uname -m)
    echo_info "Native architecture: $native_arch"

    # In CI or for quick builds, only build for native architecture
    if [ -n "$CI" ] || [ "$1" == "--native-only" ]; then
        echo_info "Building for native architecture only..."
        build_for_arch "macos" "$native_arch" "macosx" "11.0"
    else
        # Build for both architectures for local development
        echo_info "Building for multiple architectures..."
        build_for_arch "macos" "x86_64" "macosx" "11.0"
        build_for_arch "macos" "arm64" "macosx" "11.0"

        # Build for iOS (uncomment when ready to support iOS)
        # build_for_arch "ios" "arm64" "iphoneos" "14.0"
        # build_for_arch "iossimulator" "x86_64" "iphonesimulator" "14.0"
        # build_for_arch "iossimulator" "arm64" "iphonesimulator" "14.0"
    fi

    # Create XCFramework
    create_xcframework

    # Copy data files
    copy_data

    echo_info "Build complete! 🎉"
    echo_info "XCFramework: $OUTPUT_DIR/EspeakNG.xcframework"
    echo_info "Data: $PROJECT_ROOT/Sources/EspeakNG/Resources/espeak-ng-data"
}

# Run main
main "$@"
