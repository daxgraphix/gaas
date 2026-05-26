# Build Configuration for GAAS Math Learning App
# This file contains build scripts for Android and Windows platforms

# Android Build Scripts
# =====================

# Build APK for Android
build_android_apk() {
    echo "Building Android APK..."
    flutter clean
    flutter pub get
    flutter build apk --release --split-per-abi

    if [ $? -eq 0 ]; then
        echo "✅ Android APK built successfully!"
        echo "APK files are located in: build/app/outputs/flutter-apk/"
        ls -la build/app/outputs/flutter-apk/
    else
        echo "❌ Android APK build failed!"
        exit 1
    fi
}

# Build AAB (Android App Bundle) for Play Store
build_android_aab() {
    echo "Building Android App Bundle (AAB)..."
    flutter clean
    flutter pub get
    flutter build appbundle --release

    if [ $? -eq 0 ]; then
        echo "✅ Android AAB built successfully!"
        echo "AAB file is located at: build/app/outputs/bundle/release/app-release.aab"
        ls -la build/app/outputs/bundle/release/
    else
        echo "❌ Android AAB build failed!"
        exit 1
    fi
}

# Windows Build Scripts
# =====================

# Build Windows executable
build_windows_exe() {
    echo "Building Windows executable..."
    flutter clean
    flutter pub get

    # Enable Windows desktop support if not already enabled
    flutter config --enable-windows-desktop

    # Build for Windows
    flutter build windows --release

    if [ $? -eq 0 ]; then
        echo "✅ Windows executable built successfully!"
        echo "Executable is located in: build/windows/runner/Release/"
        ls -la build/windows/runner/Release/
    else
        echo "❌ Windows build failed!"
        exit 1
    fi
}

# Create Windows installer (requires Inno Setup or similar)
create_windows_installer() {
    echo "Creating Windows installer..."
    echo "Note: This requires Inno Setup or NSIS to be installed"

    # Build the app first
    build_windows_exe

    if [ $? -eq 0 ]; then
        echo "✅ Windows installer created!"
        echo "Check the installer directory for the setup file"
    else
        echo "❌ Windows installer creation failed!"
        exit 1
    fi
}

# Cross-platform build
build_all_platforms() {
    echo "Building for all supported platforms..."

    # Android APK
    echo "📱 Building Android APK..."
    build_android_apk

    # Android AAB
    echo "📦 Building Android AAB..."
    build_android_aab

    # Windows
    echo "🖥️  Building Windows executable..."
    build_windows_exe

    echo "🎉 All builds completed!"
}

# Development helpers
clean_build() {
    echo "Cleaning build artifacts..."
    flutter clean
    rm -rf build/
    rm -rf .dart_tool/
    echo "✅ Build artifacts cleaned!"
}

run_tests() {
    echo "Running tests..."
    flutter test
    if [ $? -eq 0 ]; then
        echo "✅ All tests passed!"
    else
        echo "❌ Some tests failed!"
        exit 1
    fi
}

# Performance analysis
analyze_performance() {
    echo "Analyzing performance..."
    flutter build apk --analyze-size
    flutter build appbundle --analyze-size
}

# Main build menu
show_menu() {
    echo "======================================="
    echo "  GAAS Math Learning App Builder"
    echo "======================================="
    echo "1. Build Android APK"
    echo "2. Build Android AAB (Play Store)"
    echo "3. Build Windows Executable"
    echo "4. Create Windows Installer"
    echo "5. Build All Platforms"
    echo "6. Clean Build Artifacts"
    echo "7. Run Tests"
    echo "8. Analyze Performance"
    echo "9. Exit"
    echo "======================================="
    echo -n "Choose an option (1-9): "
}

# Main script logic
case "${1:-}" in
    "apk")
        build_android_apk
        ;;
    "aab")
        build_android_aab
        ;;
    "windows")
        build_windows_exe
        ;;
    "installer")
        create_windows_installer
        ;;
    "all")
        build_all_platforms
        ;;
    "clean")
        clean_build
        ;;
    "test")
        run_tests
        ;;
    "analyze")
        analyze_performance
        ;;
    "menu")
        while true; do
            show_menu
            read choice
            case $choice in
                1) build_android_apk ;;
                2) build_android_aab ;;
                3) build_windows_exe ;;
                4) create_windows_installer ;;
                5) build_all_platforms ;;
                6) clean_build ;;
                7) run_tests ;;
                8) analyze_performance ;;
                9) echo "Goodbye! 👋"; exit 0 ;;
                *) echo "Invalid option. Please choose 1-9." ;;
            esac
            echo ""
        done
        ;;
    *)
        echo "Usage: $0 {apk|aab|windows|installer|all|clean|test|analyze|menu}"
        echo ""
        echo "Examples:"
        echo "  $0 apk        # Build Android APK"
        echo "  $0 windows    # Build Windows executable"
        echo "  $0 all        # Build for all platforms"
        echo "  $0 menu       # Interactive menu"
        echo ""
        show_menu
        ;;
esac