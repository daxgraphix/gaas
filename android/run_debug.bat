@echo off
setlocal
set "JAVA_HOME=C:\Users\CYBER SWAHILI\.p2\pool\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre"
set "PATH=%JAVA_HOME%\bin;%PATH%"
cd /d "C:\Users\CYBER SWAHILI\Documents\gaas\android"
call gradlew.bat assembleDebug 2>&1 > build.log
if %errorlevel% neq 0 (
  echo BUILD FAILED
  goto :end
)
findstr /c:"BUILD SUCCESSFUL" build.log >nul
if errorlevel 1 (
  echo BUILD FAILED
) else (
  echo BUILD SUCCEEDED
  echo APK at: app\build\outputs\flutter-apk\app-debug.apk
)
:end
endlocal