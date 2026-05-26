@echo off
setlocal enabledelayedexpansion

rem Set Java 1.8
set "JAVA_HOME=C:\Users\CYBER SWAHILI\.p2\pool\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre"
set "JRE_BIN=%JAVA_HOME%\bin"

rem Prepend JRE to PATH
set "OLD_PATH=%PATH%"
set "PATH=%JRE_BIN%;%PATH%"

cd /d "C:\Users\CYBER SWAHILI\Documents\gaas\android"

rem Run gradle and capture output
gradlew.bat assembleDebug > gradle_output.log 2>&1

rem Check result
set "BUILD_OK=0"
findstr /c:"BUILD SUCCESSFUL" gradle_output.log >nul
if !errorlevel! equ 0 set "BUILD_OK=1"

if !BUILD_OK! equ 1 (
  echo BUILD SUCCEEDED
  if exist "app\build\outputs\flutter-apk\app-debug.apk" (
    echo APK EXISTS: app\build\outputs\flutter-apk\app-debug.apk
  ) else (
    echo WARNING: APK not found
  )
) else (
  echo BUILD FAILED - output:
  type gradle_output.log
)

endlocal
rem Restore PATH (optional)
rem set "PATH=%OLD_PATH%"