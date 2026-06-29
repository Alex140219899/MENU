@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "SRC=src\VigMenu.lua"
set "OUT=VigMenu.lua"
set "TMP=build\.vigmenu.obf.tmp.lua"
set "CFG=build\prometheus-vigmenu.lua"

if not exist "%SRC%" (
    echo [build] Ошибка: нет %SRC%
    echo         Редактируйте только src\VigMenu.lua
    exit /b 1
)

where prometheus-lua >nul 2>&1
if not errorlevel 1 (
    echo [build] prometheus-lua ...
    if exist "%CFG%" (
        prometheus-lua --Lua51 --nocolors --config "%CFG%" --out "%TMP%" "%SRC%"
    ) else (
        prometheus-lua --Lua51 --preset Medium --nocolors --out "%TMP%" "%SRC%"
    )
    if errorlevel 1 goto fail
    goto prepend
)

set "PH="
if defined PROMETHEUS_HOME (
    if exist "!PROMETHEUS_HOME!\cli.lua" set "PH=!PROMETHEUS_HOME!"
)
if not defined PH if exist "tools\Prometheus\cli.lua" set "PH=tools\Prometheus"

if defined PH (
    set "LUA="
    if defined LUA_BIN set "LUA=!LUA_BIN!"
    if not defined LUA if exist "tools\lua\lua.exe" set "LUA=tools\lua\lua.exe"
    if not defined LUA (
        where lua >nul 2>&1 && set "LUA=lua"
    )
    if not defined LUA (
        where luajit >nul 2>&1 && set "LUA=luajit"
    )
    if not defined LUA (
        echo [build] Нужен Lua 5.1 или LuaJIT в PATH, либо переменная LUA_BIN=путь\lua.exe
        exit /b 1
    )
    echo [build] !PH!\cli.lua ...
    if exist "%CFG%" (
        "!LUA!" "!PH!\cli.lua" --Lua51 --nocolors --config "%CFG%" --out "%TMP%" "%SRC%"
    ) else (
        "!LUA!" "!PH!\cli.lua" --Lua51 --preset Medium --nocolors --out "%TMP%" "%SRC%"
    )
    if errorlevel 1 goto fail
    goto prepend
)

echo.
echo [build] Prometheus не найден.
echo.
echo   1^) setup-prometheus.bat
echo   2^) install-lua.bat
echo   3^) build.bat
echo.
echo Исходник: src\VigMenu.lua   Релиз для GitHub: %OUT% ^(после obf^)
exit /b 1

:prepend
if not exist "build" mkdir "build"
if not exist "%TMP%" goto fail
powershell -NoProfile -ExecutionPolicy Bypass -File "build\prepend-headers.ps1" -Source "%SRC%" -Obfuscated "%TMP%" -Out "%OUT%"
if errorlevel 1 goto fail
del /Q "%TMP%" >nul 2>&1

:verify
if not exist "%OUT%" goto fail
findstr /C:"РАЗРАБОТКА" "%OUT%" >nul 2>&1
if not errorlevel 1 goto fail
findstr /C:"return(function" "%OUT%" >nul 2>&1
if errorlevel 1 goto fail
findstr /C:"script_version(" "%OUT%" >nul 2>&1
if errorlevel 1 goto fail
goto success

:fail
echo [build] Сборка не удалась.
exit /b 1

:success
if not exist "%OUT%" (
    echo [build] Ошибка: файл %OUT% не создан
    exit /b 1
)
for %%A in ("%OUT%") do echo [build] Готово: %OUT% ^(%%~zA байт^)
echo.
echo Проверьте в moonloader, затем push на GitHub ^(коммитьте %OUT%, не src/^).
exit /b 0
