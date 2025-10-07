@echo off
echo ========================================
echo Starting Attendance Portal Servers
echo ========================================
echo.

echo Step 1: Starting Backend...
echo.
cd Backend
start "Backend Server" cmd /k "npm start"
timeout /t 5 /nobreak >nul

echo Step 2: Starting Frontend...
echo.
cd ..\Frontend
start "Frontend Server" cmd /k "npm start"

echo.
echo ========================================
echo Both servers are starting!
echo ========================================
echo.
echo Backend: http://localhost:5000
echo Frontend: http://localhost:3000
echo.
echo Two windows will open - keep them running!
echo Close this window after servers start.
echo ========================================
echo.
pause
