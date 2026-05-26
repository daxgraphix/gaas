@echo off
REM GAAS Math Learning App Builder for Windows
REM ===========================================

echo =======================================
echo   GAAS Math Learning App Builder
echo =======================================
echo.

REM Check if Flutter is available
flutter --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter is not installed or not in PATH.
    echo Please install Flutter and add it to your PATH.
    echo Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Enable desktop support
echo Enabling Windows desktop support...
flutter config --enable-windows-desktop

:menu
cls
echo =======================================
echo   GAAS Math Learning App Builder
echo =======================================
echo 1. Build Android APK
echo 2. Build Android AAB (Play Store)
echo 3. Build Windows Executable
echo 4. Build All Platforms
echo 5. Clean Build Artifacts
echo 6. Run Tests
echo 7. Analyze Performance
echo 8. Exit
echo =======================================
echo.
set /p choice="Choose an option (1-8): "

if "%choice%"=="1" goto build_apk
if "%choice%"=="2" goto build_aab
if "%choice%"=="3" goto build_windows
if "%choice%"=="4" goto build_all
if "%choice%"=="5" goto clean
if "%choice%"=="6" goto test
if "%choice%"=="7" goto analyze
if "%choice%"=="8" goto exit_app

echo Invalid option. Please choose 1-8.
timeout /t 2 >nul
goto menu

:build_apk
echo.
echo 📱 Building Android APK...
echo.
flutter clean
flutter pub get
flutter build apk --release --split-per-abi

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Android APK built successfully!
    echo APK files are located in: build\app\outputs\flutter-apk\
    dir build\app\outputs\flutter-apk\
) else (
    echo.
    echo ❌ Android APK build failed!
)
goto end_build

:build_aab
echo.
echo 📦 Building Android App Bundle (AAB)...
echo.
flutter clean
flutter pub get
flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Android AAB built successfully!
    echo AAB file is located at: build\app\outputs\bundle\release\app-release.aab
    dir build\app\outputs\bundle\release\
) else (
    echo.
    echo ❌ Android AAB build failed!
)
goto end_build

:build_windows
echo.
echo 🖥️ Building Windows executable...
echo.
flutter clean
flutter pub get
flutter build windows --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Windows executable built successfully!
    echo Executable is located in: build\windows\runner\Release\
    dir build\windows\runner\Release\
) else (
    echo.
    echo ❌ Windows build failed!
)
goto end_build

:build_all
echo.
echo 🎯 Building for all supported platforms...
echo.

echo 📱 Building Android APK...
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Android APK build failed!
    goto end_build
)

echo.
echo 📦 Building Android AAB...
flutter build appbundle --release
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Android AAB build failed!
    goto end_build
)

echo.
echo 🖥️ Building Windows executable...
flutter build windows --release
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Windows build failed!
    goto end_build
)

echo.
echo 🎉 All builds completed successfully!
echo.
echo 📁 Build outputs:
echo   Android APK: build\app\outputs\flutter-apk\
echo   Android AAB: build\app\outputs\bundle\release\app-release.aab
echo   Windows EXE: build\windows\runner\Release\
goto end_build

:clean
echo.
echo 🧹 Cleaning build artifacts...
echo.
flutter clean
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool
echo ✅ Build artifacts cleaned!
goto end_build

:test
echo.
echo 🧪 Running tests...
echo.
flutter test
if %ERRORLEVEL% EQU 0 (
    echo ✅ All tests passed!
) else (
    echo ❌ Some tests failed!
)
goto end_build

:analyze
echo.
echo 📊 Analyzing performance...
echo.
flutter build apk --analyze-size
flutter build appbundle --analyze-size
goto end_build

:end_build
echo.
echo Press any key to continue...
pause >nul
goto menu

:exit_app
echo.
echo Goodbye! 👋
echo.
exit /b 0