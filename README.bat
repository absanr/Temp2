@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

:: Solicitud de privilegios administrativos
echo Verificando privilegios...
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Debes ejecutar este script como administrador.
    pause
    exit
)

:: Verificación del servicio de impresión
echo Comprobando servicio de cola de impresion...
sc query spooler | find "RUNNING" >nul
if %ERRORLEVEL%==0 (
    echo Deteniendo servicio de impresión...
    net stop spooler
) else (
    echo El servicio de impresión ya está detenido.
)

:: Limpieza de la cola de impresión
echo Limpiando trabajos pendientes...
del /F /Q %windir%\System32\spool\PRINTERS\*.* >nul 2>&1

:: Comprobación de puertos comunes de impresión bloqueados
set puertos=515 631 9100 9001
for %%p in (%puertos%) do (
    echo Verificando puerto %%p...
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%%p') do (
        echo Encontrado proceso bloqueando puerto %%p con PID %%a, procediendo a terminar...
        taskkill /PID %%a /F >nul 2>&1
    )

:: Reiniciar servicio de cola de impresión
echo Iniciando servicio de impresión...
net start spooler

:: Comprobación final del estado del servicio
sc query spooler | find "ESTADO"

:: Comprobación rápida de conectividad a impresoras (ping)
echo Comprobando conectividad con impresoras...
for %%I in (192.168.8.10 192.168.8.11 192.168.8.12) do (
    ping -n 2 %%I | find "TTL=" >nul
    if errorlevel 1 (
        echo Impresora %%I no responde.
    ) else (
        echo Impresora %%I activa.
    )
)

echo.
echo Operacion completada.
echo.
echo =========================
echo      Realizado por Roger
echo ==========================
pause
