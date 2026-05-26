cd /d "C:\Users\CYBER SWAHILI\Documents\gaas\android"
gradlew.bat assembleDebug 2>&1 | findstr "BUILD" || echo "no output"