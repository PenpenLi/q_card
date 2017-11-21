@echo off 
	


setlocal enabledelayedexpansion

printf "start to delete file...\n"
rm -rf ..\..\DstRes 

if ERRORLEVEL 1 goto ERROR


printf "start to copy file...\n"
xcopy /s/e/i/q/y ..\..\Resources ..\..\DstRes

if ERRORLEVEL 1 goto ERROR

printf "\n start to build luajit file...\n "
for /r ..\..\DstRes\ %%i in (*.lua) do luajit.exe -b %%i %%i

if ERRORLEVEL 1 goto ERROR

printf "\n ==== build success ===== \n"
pause&exit



:ERROR
printf "\n ====  ERROR  ===== \n"
pause