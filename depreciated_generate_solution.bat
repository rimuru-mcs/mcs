@echo off
setlocal

set "BUILD_DIR=build"

if not exist "%BUILD_DIR%" (
    mkdir "%BUILD_DIR%"
)

cd "%BUILD_DIR%"

echo Generating Visual Studio Solution...

set "CMAKE_PATH=cmake"
if not exist "%CMAKE_PATH%" (
    if exist "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" (
        set "CMAKE_PATH=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
    )
)

"%CMAKE_PATH%" .. -DEQEMU_BUILD_LOGIN=ON ^
    -DEQEMU_BUILD_HC=ON ^
    -DEQEMU_BUILD_TESTS=ON ^
    -DEQEMU_BUILD_CLIENT_FILES=ON

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] CMake generation failed. Check if CMake is installed and in your PATH.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [SUCCESS] Solution generated in %BUILD_DIR%\EQEmu.sln
echo To build, open %BUILD_DIR%\EQEmu.sln in Visual Studio 2022.
pause
