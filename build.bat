@REM echo OFF
if %random% == 0 echo penis
:build
echo "Testing game"
lime test windows -dce no %*
pause
goto build