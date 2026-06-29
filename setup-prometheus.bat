@echo off
chcp 65001 >nul
cd /d "%~dp0"

if exist "tools\Prometheus\cli.lua" (
    echo [setup] tools\Prometheus уже установлен.
    exit /b 0
)

where git >nul 2>&1
if errorlevel 1 (
    echo [setup] Нужен Git: https://git-scm.com/download/win
    exit /b 1
)

if not exist "tools" mkdir "tools"

echo [setup] Клонирование Prometheus в tools\Prometheus ...
git clone --depth 1 https://github.com/prometheus-lua/Prometheus.git "tools\Prometheus"
if errorlevel 1 (
    echo [setup] Ошибка git clone.
    exit /b 1
)

echo.
echo [setup] Готово. Установите Lua 5.1 / LuaJIT и добавьте в PATH.
echo        Или задайте: set LUA_BIN=C:\путь\lua.exe
echo        Затем: build.bat
exit /b 0
