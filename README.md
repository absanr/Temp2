@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
title Optimizador avanzado de colas de impresion - Por Roger

echo ==============================================
echo        Optimizador Avanzado de Impresoras
echo ================================================

:: Verificación de privilegios administrativos
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Este script debe ejecutarse como administrador.
    pause
    exit
)

:: Verificando estado del servicio de impresión
sc query spooler | find "RUNNING" >nul
if %errorlevel%==0 (
    echo Servicio Spooler activo. Procediendo a detener...
    net stop spooler
) else (
    echo El servicio de impresión ya está detenido.
)

:: Limpieza de trabajos pendientes
echo Eliminando trabajos pendientes...
del /F /Q %windir%\System32\spool\PRINTERS\*.* >nul 2>&1

:: Puertos comunes de impresión y escaneo bloqueados
set puertos=515 631 9100 9001 9101 9102 9220 9500

for %%p in (%puertos%) do (
    netstat -aon | findstr "%%p" >nul
    if !ERRORLEVEL! == 0 (
        for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%%p"') do (
            echo Terminando proceso en el puerto %%p con PID %%a...
            taskkill /PID %%a /F >nul 2>&1
        )
)

:: Reiniciando servicio de impresión
net start spooler >nul 2>&1
echo Servicio de cola de impresión reiniciado.

:: Test de conexión a impresoras de ejemplo
for %%i in (192.168.8.10 192.168.8.11 192.168.8.12) do (
    ping -n 1 %%i | find "TTL=" >nul
    if errorlevel 1 (
        echo Impresora %%i no responde, verifica conexión.
    ) else (
        echo Impresora %%i responde correctamente.
    )
)

echo ==============================================
echo      Proceso completado exitosamente.
echo                Por Roger
echo ==============================================
pause
