@echo off
title Bale Ody Booking System - Local Server
cd /d "%~dp0"

echo =======================================================
echo   BALE ODY VILLA & CAMPING GROUND - LOCAL SIMULATION
echo =======================================================
echo.

set PHP_BIN=php
where php >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    if exist "C:\php\php.exe" (
        set PHP_BIN=C:\php\php.exe
    ) else (
        echo [ERROR] PHP tidak ditemukan di PATH maupun di C:\php\php.exe
        echo Silakan pastikan PHP sudah terpasang.
        pause
        exit /b 1
    )
)

echo [OK] Menggunakan PHP: %PHP_BIN%
echo [INFO] Menjalankan Web Server Lokal di http://localhost:8000 ...
echo [INFO] Tekan CTRL + C di jendela ini untuk mematikan server.
echo.

start "" "http://localhost:8000"
%PHP_BIN% -S localhost:8000
