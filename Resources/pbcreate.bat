@echo off
set DIR=%~dp0
set DIR=%DIR%\pbs
cd /d "%DIR%"
setlocal enabledelayedexpansion
for /r %%i in (*.proto) do ( 
set pbname=%%i 
set pbname=!pbname:~0,-5!b
..\..\Tools\protoc-generator\protoc -I %DIR% --descriptor_set_out !pbname! %%i 
)
echo "finished"
pause