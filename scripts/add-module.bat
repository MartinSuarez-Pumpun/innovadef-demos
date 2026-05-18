@echo off
:: add-module.bat — Añade un repo como submódulo y configura rama dev + CI/CD
:: Uso: scripts\add-module.bat <github-url> [nombre-carpeta]
:: Windows CMD

setlocal enabledelayedexpansion

set URL=%1
set NAME=%2

if "%URL%"=="" (
    echo Uso: scripts\add-module.bat ^<github-url^> [nombre-carpeta]
    echo Ej:  scripts\add-module.bat https://github.com/org/demo-nuevo.git
    exit /b 1
)

if "%NAME%"=="" (
    for %%F in ("%URL%") do set NAME=%%~nF
    set NAME=!NAME:.git=!
)

set SCRIPT_DIR=%~dp0
set ROOT_DIR=%SCRIPT_DIR%..

echo.
echo ^> Anyadiendo submodulo: %NAME%
echo   URL: %URL%
echo.

:: 1. Añadir como submódulo
git submodule add %URL% %NAME%
git add .gitmodules %NAME%
git commit -m "add %NAME% as submodule"

:: 2. Entrar en el submódulo
cd /d "%ROOT_DIR%\%NAME%"

echo ^> Configurando rama dev y workflows en %NAME%...

:: Crear rama dev
git checkout -b dev 2>nul || git checkout dev

:: Copiar plantillas de workflows
if not exist ".github\workflows" mkdir ".github\workflows"
copy /Y "%ROOT_DIR%\templates\workflows\ci.yml"            ".github\workflows\ci.yml"
copy /Y "%ROOT_DIR%\templates\workflows\notify-parent.yml" ".github\workflows\notify-parent.yml"

git add .github
git commit -m "add CI/CD workflows (ci -> dev, deploy -> main)"

:: Subir ambas ramas
git push -u origin main
git push -u origin dev

:: Intentar proteger rama main con gh CLI
where gh >nul 2>&1
if %errorlevel%==0 (
    echo ^> Intentando proteger rama main via gh CLI...
    for /f "delims=" %%R in ('gh repo view --json nameWithOwner -q .nameWithOwner 2^>nul') do set REPO=%%R
    echo   ! Protege main manualmente en GitHub -^> Settings -^> Branches si el comando falla
) else (
    echo ^> gh CLI no encontrado.
    echo   Protege main manualmente en GitHub -^> Settings -^> Branches
    echo   Regla: require pull request before merging, source branch: dev
)

cd /d "%ROOT_DIR%"

echo.
echo OK. Sube el padre con: git push
echo.
echo   Flujo de trabajo:
echo     Desarrolla en rama dev
echo     Abre PR de dev -^> main para publicar
echo.

endlocal