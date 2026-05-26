cd /d "C:\Users\CYBER SWAHILI\Documents\gaas\android"
gradlew.bat assembleDebug 2>&1 > "C:\Users\CYBER SWAHILI\Documents\gaas\android_build_output.log"
if errorlevel 1 (
  echo BUILD FAILED
  goto end
)
findstr "BUILD SUCCESSFUL" "C:\Users\CYBER SWAHILI\Documents\gaas\android_build_output.log" >nul 2>&1
if errorlevel 1 (
  echo BUILD FAILED
) else (
  echo BUILD SUCCEEDED
  echo APK at: app\build\outputs\flutter-apk\app-debug.apk
)
:end