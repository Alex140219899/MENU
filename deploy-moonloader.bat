@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

set "ML=C:\Program Files\Arizona Games\moonloader"
if not exist "%ML%" (
    echo [deploy] Папка moonloader не найдена: %ML%
    echo Укажите путь вручную или скопируйте файлы сами.
    exit /b 1
)

if not exist "VigMenu.lua" (
    echo [deploy] Сначала запустите build.bat
    exit /b 1
)

if not exist "VigMenu\VigMenuLicense.lua" (
    echo [deploy] Нет VigMenu\VigMenuLicense.lua — запустите build.bat
    exit /b 1
)

if not exist "%ML%\VigMenu" mkdir "%ML%\VigMenu"

copy /Y "VigMenu.lua" "%ML%\VigMenu.lua"
copy /Y "VigMenu\VigMenuLicense.lua" "%ML%\VigMenu\VigMenuLicense.lua"
copy /Y "VigMenu\VigMenuUpdate.lua" "%ML%\VigMenu\VigMenuUpdate.lua"

echo.
echo [deploy] Готово:
echo   %ML%\VigMenu.lua
echo   %ML%\VigMenu\VigMenuLicense.lua
echo   %ML%\VigMenu\VigMenuUpdate.lua
echo.
echo Перезагрузите скрипты в игре (reload_all или перезаход).
exit /b 0
