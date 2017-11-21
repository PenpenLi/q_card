@ECHO OFF

ECHO "Copying big5_android files..."
XCOPY /s/e/i/q/y Resources.big5.android\script\config Resources\script\config>nul
XCOPY /s/e/i/q/y Resources.big5.android\fonts Resources\fonts>nul
XCOPY /s/e/i/q/y Resources.big5.android\img Resources\img>nul

IF ERRORLEVEL 1 GOTO ERROR

ECHO "Done."
PAUSE&EXIT

:ERROR
ECHO "Error!"
PAUSE