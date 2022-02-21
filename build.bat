echo OFF
if %random% == 0 echo penis
:build
lime test windows -dce no
pause
goto build