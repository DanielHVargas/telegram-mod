@echo off
echo =======================================================
echo Compilando Telegram Mod con tu Icono y Color Corporativo
echo =======================================================
echo.
call gradlew.bat :TMessagesProj_AppStandalone:assembleAfatDebug
echo.
if %ERRORLEVEL% EQU 0 (
    echo =======================================================
    echo COMPILACION EXITOSA
    echo El archivo APK se encuentra en:
    echo TMessagesProj_AppStandalone\build\outputs\apk\afat\debug\TMessagesProj_AppStandalone-afat-debug.apk
    echo =======================================================
) else (
    echo =======================================================
    echo ERROR EN LA COMPILACION
    echo Por favor revisa los mensajes de error arriba.
    echo =======================================================
)
pause