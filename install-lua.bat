@echo off
chcp 65001 >nul
cd /d "%~dp0"

if exist "tools\lua\lua.exe" (
    echo [install-lua] tools\lua\lua.exe уже есть.
    exit /b 0
)

where curl >nul 2>&1
if errorlevel 1 (
    echo [install-lua] Нужен curl ^(Windows 10+^) или скачайте lua.exe в tools\lua\
    echo https://sourceforge.net/projects/luabinaries/files/5.1.5/Tools%%20Executables/
    exit /b 1
)

if not exist "tools\lua" mkdir "tools\lua"
set "ZIP=%TEMP%\lua-5.1.5_Win32_bin.zip"

echo [install-lua] Скачивание Lua 5.1 ...
curl -fsSL -L -o "%ZIP%" "https://downloads.sourceforge.net/project/luabinaries/5.1.5/Tools%%20Executables/lua-5.1.5_Win32_bin.zip"
if errorlevel 1 (
    echo [install-lua] Ошибка загрузки.
    exit /b 1
)

powershell -NoProfile -Command "Expand-Archive -LiteralPath '%ZIP%' -DestinationPath 'tools\lua-pack' -Force"
if errorlevel 1 (
    echo [install-lua] Ошибка распаковки.
    exit /b 1
)

for /r "tools\lua-pack" %%F in (lua5.1.exe) do (
    copy /Y "%%F" "tools\lua\lua.exe" >nul
    xcopy /Y /Q "%%~dpF*.dll" "tools\lua\" >nul 2>nul
    if exist "%%~dpFMicrosoft.VC80.CRT" xcopy /E /Y /Q "%%~dpFMicrosoft.VC80.CRT" "tools\lua\Microsoft.VC80.CRT\" >nul 2>nul
    goto copied
)
echo [install-lua] lua.exe не найден в архиве.
exit /b 1

:copied
echo [install-lua] Готово: tools\lua\lua.exe
exit /b 0
