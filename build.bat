@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "CFG=build\prometheus-vigmenu.lua"
set "LUA="
if defined LUA_BIN set "LUA=!LUA_BIN!"
if not defined LUA if exist "tools\lua\lua.exe" set "LUA=tools\lua\lua.exe"
if not defined LUA where lua >nul 2>&1 && set "LUA=lua"
if not defined LUA where luajit >nul 2>&1 && set "LUA=luajit"

set "PH="
if defined PROMETHEUS_HOME if exist "!PROMETHEUS_HOME!\cli.lua" set "PH=!PROMETHEUS_HOME!"
if not defined PH if exist "tools\Prometheus\cli.lua" set "PH=tools\Prometheus"

if not defined PH (
    echo [build] Prometheus не найден. setup-prometheus.bat
    exit /b 1
)
if not defined LUA (
    echo [build] Нужен Lua 5.1 — install-lua.bat или LUA_BIN=
    exit /b 1
)

if not exist "build" mkdir "build"
if not exist "VigMenu" mkdir "VigMenu"

call :obf_one "src\VigMenu.lua" "build\.vigmenu.obf.tmp.lua" main
if errorlevel 1 goto fail
powershell -NoProfile -ExecutionPolicy Bypass -File "build\prepend-headers.ps1" -Source "src\VigMenu.lua" -Obfuscated "build\.vigmenu.obf.tmp.lua" -Out "VigMenu.lua"
if errorlevel 1 goto fail
del /Q "build\.vigmenu.obf.tmp.lua" >nul 2>&1

call :obf_one "src\VigMenuLicense.lua" "VigMenu\VigMenuLicense.lua" mod
if errorlevel 1 goto fail
call :obf_one "src\VigMenuUpdate.lua" "VigMenu\VigMenuUpdate.lua" mod
if errorlevel 1 goto fail

"!LUA!" -e "for _,p in ipairs({'VigMenu.lua','VigMenu/VigMenuLicense.lua','VigMenu/VigMenuUpdate.lua'}) do local f,e=loadfile(p); if not f then print('[build] Lua compile FAIL: '..p..': '..tostring(e)); os.exit(1) end end; print('[build] Lua compile OK (3 files)')"
if errorlevel 1 goto fail

findstr /C:"РАЗРАБОТКА" "VigMenu.lua" >nul 2>&1 && goto fail
findstr /C:"script_version(" "VigMenu.lua" >nul 2>&1 || goto fail

echo.
echo [build] Готово:
for %%A in ("VigMenu.lua") do echo   VigMenu.lua ^(%%~zA байт^)
for %%A in ("VigMenu\VigMenuLicense.lua") do echo   VigMenu\VigMenuLicense.lua ^(%%~zA байт^)
for %%A in ("VigMenu\VigMenuUpdate.lua") do echo   VigMenu\VigMenuUpdate.lua ^(%%~zA байт^)
echo.
echo Положите в moonloader: VigMenu.lua + папка VigMenu\ с двумя модулями.
echo Push: VigMenu.lua, VigMenu\*.lua, VigUpdate.json
exit /b 0

:obf_one
set "OBF_IN=%~1"
set "OBF_OUT=%~2"
if not exist "%OBF_IN%" (
    echo [build] Нет %OBF_IN%
    exit /b 1
)
echo [build] obf %OBF_IN% ...
if exist "%CFG%" (
    "!LUA!" "!PH!\cli.lua" --Lua51 --nocolors --config "%CFG%" --out "%OBF_OUT%" "%OBF_IN%"
) else (
    "!LUA!" "!PH!\cli.lua" --Lua51 --preset Medium --nocolors --out "%OBF_OUT%" "%OBF_IN%"
)
if errorlevel 1 exit /b 1
exit /b 0

:fail
echo [build] Сборка не удалась.
exit /b 1
