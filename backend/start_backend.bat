@echo off
echo ========================================
echo Starting WidMate Backend Server
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please run setup.bat first
    pause
    exit /b 1
)

REM Check if dependencies are installed
if not exist "downloads" mkdir downloads
if not exist "logs" mkdir logs

echo Starting server on http://127.0.0.1:8000
echo API Documentation: http://127.0.0.1:8000/docs
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

REM Start the server
python start_server.py

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to start server
    echo Please check the error messages above
    pause
)