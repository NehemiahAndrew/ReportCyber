@echo off
echo Starting ReportCyber Backend...
echo.

REM Add Node.js to PATH
set PATH=%PATH%;C:\Program Files\nodejs;%APPDATA%\npm

REM Kill any existing node processes on port 3000
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000 ^| findstr LISTENING') do (
    taskkill /F /PID %%a 2>nul
)

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Start the server
cd /d "%~dp0"
npm run dev
