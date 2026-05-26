@echo off
set "JAVA_HOME=C:\Users\CYBER SWAHILI\.p2\pool\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre"
set "PATH=%JAVA_HOME%\bin;%PATH%"
cd /d "C:\Users\CYBER SWAHILI\Documents\gaas\android"
if exist "C:\Users\CYBER SWAHILI\.gradle" rd /s /q "C:\Users\CYBER SWAHILI\.gradle"
if exist "C:\Users\CYBER SWAHILI\Documents\gaas\build" rd /s /q "C:\Users\CYBER SWAHILI\Documents\gaas\build"
if exist "C:\Users\CYBER SWAHILI\Documents\gaas\.dart_tool" rd /s /q "C:\Users\CYBER SWAHILI\Documents\gaas\.dart_tool"
if exist "C:\Users\CYBER SWAHILI\Documents\gaas\android\.gradle" rd /s /q "C:\Users\CYBER SWAHILI\Documents\gaas\android\.gradle"
if exist "C:\Users\CYBER SWAHILI\Documents\gaas\android\build" rd /s /q "C:\Users\CYBER SHAGAIN\Documents\gaas\android\build"
gradlew.bat assembleDebug %*