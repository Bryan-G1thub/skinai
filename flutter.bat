@echo off
setlocal

set "PROJECT_FLUTTER=C:\Users\Bryan\fvm\versions\3.41.6\bin\flutter.bat"

if exist "%PROJECT_FLUTTER%" (
  call "%PROJECT_FLUTTER%" %*
  exit /b %ERRORLEVEL%
)

echo [skinai] Expected Flutter SDK is missing:
echo   C:\Users\Bryan\fvm\versions\3.41.6\bin\flutter.bat
echo Reinstall with: fvm install 3.41.6
exit /b 1
