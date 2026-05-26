@echo off
set "JAVA_HOME=C:\Users\CYBER SWAHILI\.p2\pool\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre"
set "PATH=%JAVA_HOME%\bin;%PATH%"
cd /d "C:\Users\CYBER SWAHILI\Documents\gaas\android"
rm -rf "C:\Users\CYBER SWAHILI\.gradle" "C:\Users\CYBER SWAHILI\Documents\gaas\build" "C:\Users\CYBER SWAHILI\Documents\gaas\.dart_tool" "C:\Users\CYBER SWAHILI\Documents\gaas\android\.gradle" "C:\Users\CYBER SWAHILI\Documents\gaas\android\build"
gradlew.bat assembleDebug %*