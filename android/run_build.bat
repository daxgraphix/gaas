@echo off
cd /d "C:\Users\CYBER SWAHILI\Documents\gaas\android"
cmd /c "build_simple.cmd" > build_output.log 2>&1
exit /b %errorlevel%