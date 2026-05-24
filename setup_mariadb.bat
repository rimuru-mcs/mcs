@echo off
REM ============================================================
REM EQEmu MariaDB Automated Setup Script
REM ============================================================
REM This script will:
REM 1. Download MariaDB 10.11 LTS (compatible with vcpkg libmariadb)
REM 2. Install MariaDB silently with root/root credentials
REM 3. Extract and import the THJ PEQ database
REM 4. Verify the installation
REM ============================================================

setlocal enabledelayedexpansion

echo.
echo ============================================================
echo EQEmu MariaDB Automated Setup
echo ============================================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires Administrator privileges.
    echo Please right-click and select "Run as Administrator"
    pause
    exit /b 1
)

REM Configuration
set MARIADB_VERSION=10.11.10
set MARIADB_URL=https://archive.mariadb.org/mariadb-10.11.10/winx64-packages/mariadb-10.11.10-winx64.msi
set MARIADB_INSTALLER=mariadb-installer.msi
set DB_NAME=thj_peq
set DB_USER=root
set DB_PASS=root
set SCRIPT_DIR=%~dp0
set ASSETS_DIR=%SCRIPT_DIR%assets
set DB_BACKUP=%ASSETS_DIR%\thj_peq_backup.rar

REM Step 1: Download MariaDB
echo [1/5] Downloading MariaDB %MARIADB_VERSION%...
echo.

if exist "%MARIADB_INSTALLER%" (
    echo MariaDB installer already exists, skipping download.
) else (
    echo Downloading from: %MARIADB_URL%
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%MARIADB_URL%' -OutFile '%MARIADB_INSTALLER%'}"
    
    if !errorLevel! neq 0 (
        echo ERROR: Failed to download MariaDB installer.
        pause
        exit /b 1
    )
    echo Download complete.
)

echo.
echo [2/5] Installing MariaDB...
echo.

REM Install MariaDB silently with root/root credentials
msiexec /i "%MARIADB_INSTALLER%" /qn SERVICENAME=MySQL PORT=3306 PASSWORD=%DB_PASS% UTF8=ON INSTALLDIR="C:\Program Files\MariaDB 10.11"

if !errorLevel! neq 0 (
    echo ERROR: MariaDB installation failed.
    pause
    exit /b 1
)

echo MariaDB installed successfully.
echo Waiting for service to start...
timeout /t 10 /nobreak >nul

REM Add MariaDB to PATH for this session
set PATH=%PATH%;C:\Program Files\MariaDB 10.11\bin

echo.
echo [3/5] Extracting database backup...
echo.

REM Check if backup exists
if not exist "%DB_BACKUP%" (
    echo ERROR: Database backup not found at: %DB_BACKUP%
    echo Please ensure thj_peq_backup.rar exists in the assets folder.
    pause
    exit /b 1
)

REM Check if 7-Zip is installed, if not, download and install it
set SEVENZIP_INSTALLED=0
if exist "C:\Program Files\7-Zip\7z.exe" set SEVENZIP_INSTALLED=1
if exist "C:\Program Files (x86)\7-Zip\7z.exe" set SEVENZIP_INSTALLED=1

if !SEVENZIP_INSTALLED! equ 0 (
    echo 7-Zip not found. Installing 7-Zip...
    echo.
    
    set SEVENZIP_URL=https://www.7-zip.org/a/7z2408-x64.exe
    set SEVENZIP_INSTALLER=7zip-installer.exe
    
    echo Downloading 7-Zip from: !SEVENZIP_URL!
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!SEVENZIP_URL!' -OutFile '!SEVENZIP_INSTALLER!'}"
    
    if !errorLevel! neq 0 (
        echo ERROR: Failed to download 7-Zip installer.
        echo Please manually install 7-Zip from https://www.7-zip.org/
        pause
        exit /b 1
    )
    
    echo Installing 7-Zip silently...
    !SEVENZIP_INSTALLER! /S
    
    if !errorLevel! neq 0 (
        echo ERROR: Failed to install 7-Zip.
        pause
        exit /b 1
    )
    
    echo Waiting for installation to complete...
    timeout /t 5 /nobreak >nul
    
    REM Clean up installer
    if exist "!SEVENZIP_INSTALLER!" del /q "!SEVENZIP_INSTALLER!"
    
    echo 7-Zip installed successfully.
    echo.
)

REM Extract the database backup (RAR files require 7-Zip or WinRAR)
cd /d "%ASSETS_DIR%"

echo Checking for extraction tools...
set EXTRACTED=0

REM Try 7-Zip first
if exist "C:\Program Files\7-Zip\7z.exe" (
    echo Using 7-Zip to extract...
    "C:\Program Files\7-Zip\7z.exe" x "%DB_BACKUP%" -o"%ASSETS_DIR%" -y
    if !errorLevel! equ 0 set EXTRACTED=1
) else if exist "C:\Program Files (x86)\7-Zip\7z.exe" (
    echo Using 7-Zip to extract...
    "C:\Program Files (x86)\7-Zip\7z.exe" x "%DB_BACKUP%" -o"%ASSETS_DIR%" -y
    if !errorLevel! equ 0 set EXTRACTED=1
) else if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    echo Using WinRAR to extract...
    "C:\Program Files\WinRAR\WinRAR.exe" x -y "%DB_BACKUP%" "%ASSETS_DIR%"
    if !errorLevel! equ 0 set EXTRACTED=1
) else if exist "C:\Program Files (x86)\WinRAR\WinRAR.exe" (
    echo Using WinRAR to extract...
    "C:\Program Files (x86)\WinRAR\WinRAR.exe" x -y "%DB_BACKUP%" "%ASSETS_DIR%"
    if !errorLevel! equ 0 set EXTRACTED=1
)

if !EXTRACTED! equ 0 (
    echo.
    echo ERROR: Could not extract RAR file.
    echo.
    echo RAR files require 7-Zip or WinRAR to extract.
    echo Please either:
    echo   1. Install 7-Zip from: https://www.7-zip.org/
    echo   2. Install WinRAR from: https://www.win-rar.com/
    echo   3. Manually extract thj_peq_backup.rar to the assets folder
    echo.
    pause
    exit /b 1
)

REM Find the extracted SQL file
set SQL_FILE=
for %%f in ("%ASSETS_DIR%\*.sql") do set SQL_FILE=%%f

if not defined SQL_FILE (
    echo ERROR: Could not find extracted SQL file in assets folder.
    pause
    exit /b 1
)

echo Database backup extracted: !SQL_FILE!

echo.
echo [4/5] Creating and importing database...
echo.

REM Create database
echo Creating database '%DB_NAME%'...
"C:\Program Files\MariaDB 10.11\bin\mysql.exe" -u%DB_USER% -p%DB_PASS% -e "CREATE DATABASE IF NOT EXISTS %DB_NAME%;"

if !errorLevel! neq 0 (
    echo ERROR: Failed to create database.
    echo Please check if MariaDB service is running.
    pause
    exit /b 1
)

echo Database created successfully.
echo.
echo Importing database (this may take several minutes)...
"C:\Program Files\MariaDB 10.11\bin\mysql.exe" -u%DB_USER% -p%DB_PASS% %DB_NAME% < "!SQL_FILE!"

if !errorLevel! neq 0 (
    echo ERROR: Failed to import database.
    pause
    exit /b 1
)

echo Database imported successfully.

echo.
echo [5/5] Verifying installation...
echo.

REM Verify database exists and has tables
"C:\Program Files\MariaDB 10.11\bin\mysql.exe" -u%DB_USER% -p%DB_PASS% -e "USE %DB_NAME%; SHOW TABLES;" > nul 2>&1

if !errorLevel! neq 0 (
    echo WARNING: Could not verify database tables.
) else (
    echo Database verification successful.
)

echo.
echo ============================================================
echo MariaDB Setup Complete!
echo ============================================================
echo.
echo Database Name: %DB_NAME%
echo Username: %DB_USER%
echo Password: %DB_PASS%
echo Port: 3306
echo.
echo MariaDB is installed at: C:\Program Files\MariaDB 10.11
echo.
echo IMPORTANT: Your eqemu_config.json and login.json are already
echo configured with these credentials (root/root).
echo.
echo You can now start the EQEmu server.
echo ============================================================
echo.

REM Cleanup
if exist "%MARIADB_INSTALLER%" (
    echo Cleaning up installer...
    del /q "%MARIADB_INSTALLER%"
)

pause
