@ECHO OFF

ECHO "Reverting to zhcn..."
svn revert -R Resources\script\config>nul
svn revert -R Resources\fonts>nul
svn revert -R Resources\img>nul

IF ERRORLEVEL 1 GOTO ERROR

ECHO "Done."
PAUSE&EXIT

:ERROR
ECHO "Error!"
PAUSE