@echo off
:: add-module.bat — Añade un repo como submódulo
:: Uso: scripts\add-module.bat <github-url> [nombre-carpeta]
:: Windows CMD / PowerShell

setlocal

set URL=%1
set NAME=%2

if "%URL%"=="" (
    echo Uso: scripts\add-module.bat ^<github-url^> [nombre-carpeta]
    echo Ej:  scripts\add-module.bat https://github.com/org/demo-nuevo.git
    exit /b 1
)

if "%NAME%"=="" (
    for %%F in ("%URL%") do set NAME=%%~nF
    set NAME=%NAME:.git=%
)

echo.
echo ^> Anyadiendo submodulo: %NAME%
echo   URL: %URL%
echo.

git submodule add %URL% %NAME%
git add .gitmodules %NAME%
git commit -m "add %NAME% as submodule"

echo.
echo OK. Sube los cambios con: git push
echo.

endlocal