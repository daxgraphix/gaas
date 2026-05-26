cd /d "C:\Users\CYBER SWAHILI\Documents\gaas\android"
gradlew.bat assembleDebug 2>&1 > "C:\\Users\\CYBER SWAHILI\\Documents\\gaas\\android_build.log"
find "C:\\Users\\CYBER SWAHILI\\Documents\\gaas\\android_build.log" "BUILD" || echo "Build check done"