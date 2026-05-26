@echo off
set "JAVA_HOME=C:\Users\CYBER SWAHILI\.p2\pool\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre"
set "PATH=%JAVA_HOME%\bin;%PATH%"
cd /d "C:\Users\CYBER SWAHILI\Documents\gaas\android"
gradlew.bat assembleDebug 2>&1 > "C:\Users\CYBER SWAHILI\Documents\gaas\android\build_run.log"
if not exist "C:\Users\CYBER SWAHILI\Documents\gaas\android\build_run.log" goto error
type "C:\Users\CYBER SWAHILI\Documents\gaas\android\build_run.log" | find "BUILD SUCCESSFUL" >nul
if errorlevel 1 (
  echo BUILD FAILED
  type "C:\Users\CYBER SWAHILI\Documents\gaas\android\build_run.log"
) else (
  echo BUILD SUCCEEDED
  if exist "app\build\outputs\flutter-apk\app-debug.apk" (
    echo APK EXISTS
  ) else (
    echo APK NOT FOUND
  )
)
goto end
:error
echo ERROR: Could not read log
:end