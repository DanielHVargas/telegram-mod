@echo off
echo =======================================================
echo Compilando Telegram Mod con tu Icono y Color Corporativo
echo =======================================================
echo.

:: Check for Java
where java >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Se detecto Java. Iniciando compilacion local...
    call gradlew.bat :TMessagesProj_AppStandalone:assembleAfatDebug
    goto end
)

:: If Java not found, check for Docker
echo [INFO] Java no esta configurado en tu sistema.
echo [INFO] Detectando si Docker esta disponible...
docker --version >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Se detecto Docker. Iniciando compilacion en contenedor...
    echo.
    echo Pasos:
    echo 1. Construyendo la imagen del contenedor (esto puede tardar la primera vez)...
    docker build -t telegram-android .
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Error construyendo la imagen de Docker.
        goto error_exit
    )
    echo 2. Compilando la aplicacion dentro del contenedor...
    docker run -v "%cd%:/home/source" telegram-android
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Error ejecutando la compilacion en Docker.
        goto error_exit
    )
    echo =======================================================
    echo COMPILACION EXITOSA CON DOCKER
    echo Los archivos APK compilados se guardaron en:
    echo TMessagesProj\build\outputs\apk\
    echo =======================================================
    goto end
)

:: If neither Java nor Docker is found
echo [ERROR] No se pudo compilar.
echo.
echo Para poder compilar la aplicacion necesitas una de estas dos opciones:
echo.
echo Opcion A: Instalar Java JDK 17
echo   1. Descarga JDK 17 desde: https://adoptium.net/temurin/releases/?version=17
echo   2. Instala el programa y asegurate de marcar la casilla "Add to PATH" y "Set JAVA_HOME".
echo   3. Vuelve a ejecutar este archivo.
echo.
echo Opcion B (Recomendada si no quieres instalar Java): Iniciar Docker
echo   Asegurate de que tu aplicacion "Docker Desktop" este abierta y ejecutandose.
echo.
goto error_exit

:end
pause
exit /b 0

:error_exit
echo.
echo =======================================================
echo ERROR EN LA COMPILACION
echo =======================================================
pause
exit /b 1
