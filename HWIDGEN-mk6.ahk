; <COMPILER: v1.1.26.01>
#NoEnv
SendMode, Input
SetWorkingDir, %A_ScriptDir%
#SingleInstance, Force
#NoTrayIcon
for n, param in A_Args
{
if (param == "hwid") {
Mode = HWID
go = h
GoSub, SilentRun
} else if (param == "kms38") {
Mode = KMS38
go = k
GoSub, SilentRun
}
}
if(!InStr(A_OSVersion, "10.0.")) {
MsgBox, 16, Error, This application is compatible with Windows 10 only
ExitApp
}
if(A_Is64bitOS) {
system32 = %A_WinDir%\sysnative
vera = x64
} else {
system32 = %A_WinDir%\system32
vera = x86
}
FileInstall, pkconfig.txt, %A_Temp%\pkconfig.txt, 1
fileread, pkconfig, %A_Temp%\pkconfig.txt
FileDelete, %A_Temp%\pkconfig.txt
Gui, Startup: Color, 0067B3
Gui, Startup: Font, CFFFFFF, Segoe UI
Gui, Startup: Margin, 24, 24
Gui, Startup: Add, Picture, Icon-104 w32 h32, user32.dll
Gui, Startup: Font, S16
Gui, Startup: Add, Text, x+8 ym-8 w392, The tool is starting up...
Gui, Startup: Font, S9
Gui, Startup: Add, Text, y+8 wp, The tool is performing necessary startup checks. This operation is needed to ensure that the activation process will go smoothly.
Gui, Startup: Add, Progress, x80 y+24 h16 w320 +0x8 -smooth vStartupProgress
SetTimer, MoveStartupProgress, 33
Gui, Startup: -MinimizeBox
Gui, Startup: Show, ,
gosub, WUCheck
gosub, ClipSVCCheck
gosub, wlidsvcCheck
gosub, sppsvcCheck
gosub, GetOnlineAdapter
gosub, GetOfflineAdapter
Goto, ChecksDone
StartupGuiClose:
ExitApp
ChecksDone:
if (online == "online") {
gosub, GetOnlineAdapter
} else if (online == "offline") {
gosub, GetOfflineAdapter
}
Pversion := "0.62.01"
, AppName := "HWID GEN MkVI 0.62.01 (c) Dumpster Inc."
, hAutoWnd
Try {
Gui Font, s7, Arial
Gui Add, % "Tab3",       x4      y2      w671    h395    +Theme, GENERATION
Gui Font
} Catch {
Gui Font, s7, Arial
Gui Add, Tab2,           x4      y2      w671    h395    +Theme, GENERATION
Gui Font
}
Gui Font, s8, Arial
Gui, Add, Text,             x22     y30     w40     h12,	INFO:
Gui, Add, Text,             x72     y30     w100    h12     gLaunchAIOWares, AiOwares.com
Gui, Add, Text,             x155    y30     w40     h12,	||
Gui, Add, Text,             x175    y30     w110    h12     gLaunchNsane, NsaneForums.com
Gui, Add, Text,             x465    y30     w80     h12,	Work Mode:
Gui, Add, DropDownList,     x545    y25     w114            vMode,LicenseSwitch|SetOffline|SetOnline|Rearm|Clean|Clean_ClipSVC|gVLK|HWID_Key|KMS38|HWID|INFO||
Gui, Add, Button,           x22     y350    w114    h24     Default gPatch, START
Gui, Add, Edit,             x23     y58     w636    h280    vLogF Readonly HwndhOut
Gui, Add, Progress,         x182    y350    w330    h24     -smooth vStatusProgress, 0
Gui Add, Button,            x560    y350    w99     h24     gGuiClose, EXIT
gosub, SystemInfo
Gui Tab
Gui Show,                                       w679    h400,   %AppName% [ %ProductFamily% %buildlabex%.%buildlabex2% | %vera% ]
Gui, -MinimizeBox
SetTimer, MoveStartupProgress, Off
Gui, Startup: Destroy
return
MoveStartupProgress:
GuiControl, Startup:, StartupProgress, 0
return
Patch:
InProcess = 1
Gui, +Disabled
starttime := a_now
GuiControlGet, Mode
if (Mode == "HWID_Key") {
GoSub, KeyInstallOnly
Gui, -Disabled
InProcess = 0
return
} else if (Mode == "gVLK") {
GoSub, KeyInstallOnly
Gui, -Disabled
InProcess = 0
return
} else if (Mode == "Clean") {
GoSub, CleanTokens
Gui, -Disabled
InProcess = 0
return
} else if (Mode == "Clean_ClipSVC") {
GoSub, Clean_ClipSVC
Gui, -Disabled
InProcess = 0
return
} else if (Mode == "Rearm") {
GoSub, RearmSystem
Gui, -Disabled
InProcess = 0
return
} else if (Mode == "INFO" ) {
GoSub, InfoSplash
Gui, -Disabled
InProcess = 0
return
} else if (Mode == "LicenseSwitch") {
FileInstall, lic.switcher.exe, lic.switcher.exe, 1
Run, lic.switcher.exe
Gui, -Disabled
InProcess = 0
return
} else if (Mode == "SetOnline") {
gosub, RefreshGUILicenseInformation
gosub, SystemChecks
if (online == "offline") {
GuiControl, , StatusProgress, 20
GoSub, AdapterHandleSetEnabled
Gui, -Disabled
InProcess = 0
return
} else if (online == "online") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " System is already online!" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
Gui, -Disabled
InProcess = 0
return
}
} else if (Mode == "SetOffline") {
gosub, RefreshGUILicenseInformation
gosub, SystemChecks
if (online == "online") {
GuiControl, , StatusProgress, 20
GoSub, AdapterHandleSetDisabled
Gui, -Disabled
InProcess = 0
return
} else if (online == "offline") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " System is already offline!" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
Gui, -Disabled
InProcess = 0
return
}
}
Random, rand
dir = %A_Temp%\GatherOsState%rand%
FileCreateDir, %dir%
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " PATCH PROCESS PREREQUISITES" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
InProcess = 1
Gui, +Disabled
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Preparing..." . "`r`n", hOut)
GuiControl, , StatusProgress, 0
gosub, SystemChecks
gosub, RefreshGUILicenseInformation
if(UnsupportedSku) {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Not supported System detected!" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
GuiControl, Disable , StartActBtn
GuiControl, +Default, ExitBtn
MsgBox, 16, Error, Unsupported edition
Gui, -Disabled
InProcess = 0
return
}
FileAppend, System check:`n, HWID.log
FileAppend, Description: %ProductDescription%`n, HWID.log
FileAppend, BuildLabEx: %buildlabex%.%buildlabex2%`n, HWID.log
FileAppend, Architecture: %vera%`n, HWID.log
FileAppend, PartialKey: %ProductPartialKey%`n, HWID.log
FileAppend, Edition: %ProductFamily%`n, HWID.log
FileAppend, Status %ProductStatusMsg%`n`n, HWID.log
FileAppend, Starting activation at %A_DD% %A_MMM% %A_YYYY% %A_Hour%:%A_Min%:%A_Sec%...`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Installing key:" . " " . NewKey . " " . "`r`n", hOut)
FileAppend, Installing key %NewKey%...`n, HWID.log
try RunWait,C:\Windows\System32\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -ipk %NewKey% >>HWID.log", , Hide
catch {
gosub, ProcessFail
return
}
GuiControl, , StatusProgress, 10
if(Mode = "KMS38") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting KMS Host IP to avoid DNS queries..." . "`r`n", hOut)
FileAppend, Setting KMS Host IP to avoid DNS queries...`n, HWID.log
RunWait, %system32%\cmd.exe /c (cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -skms 192.0.2.69:1833>>HWID.log), , Hide
GuiControl, , StatusProgress, 15
gosub, RefreshGUILicenseInformation
}
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Generating ticket for: " . Mode . "" .  "`r`n", hOut)
FileAppend, Generating ticket for %Mode%`n`n, HWID.log
if(Mode = "HWID") {
if(ProductFamily = "EnterpriseS") {
if(A_OSVersion = "10.0.10240") {
FileInstall, gatherosstateLTSB15.exe, %dir%\gatherosstate.exe, 1
} else {
FileInstall, gatherosstate.exe, %dir%\gatherosstate.exe, 1
}
} else if(ProductFamily = "EnterpriseSN") {
if(A_OSVersion = "10.0.10240") {
FileInstall, gatherosstateLTSB15.exe, %dir%\gatherosstate.exe, 1
} else {
FileInstall, gatherosstate.exe, %dir%\gatherosstate.exe, 1
}
} else {
FileInstall, gatherosstate.exe, %dir%\gatherosstate.exe, 1
}
FileInstall, slshim32_aio.dll, %dir%\slc.dll, 1
FileAppend, -1 0`n, %dir%\TargetSKU.txt
} else if(Mode = "KMS38") {
FileInstall, gatherosstate.exe, %dir%\gatherosstate.exe, 1
FileInstall, slshim32_aio.dll, %dir%\slc.dll, 1
FileAppend, -1 1`n, %dir%\TargetSKU.txt
}
try RunWait, %dir%\gatherosstate.exe, %dir%, Hide
catch {
gosub, ProcessFail
return
}
GuiControl, , StatusProgress, 50
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Applying GenuineTicket.xml..." . "`r`n", hOut)
FileAppend, Applying GenuineTicket.xml...`n`n, HWID.log
fallback=0
try RunWait, %system32%\cmd.exe /c "clipup -v -o -altto `"%dir%`" >>%dir%\check.txt", , Hide
catch {
gosub, ProcessFail
return
}
gosub, ApplyCheck
GuiControl, , StatusProgress, 65
FileRemoveDir, %dir%, 1
FileAppend, `n, HWID.log
back1 :=
back2 :=
back3 :=
back4 :=
gosub, WUCheck
if (wuraw == 4) {
FileAppend, WU is disabled...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " WU is disabled..." . "`r`n", hOut)
FileAppend, Setting WU to auto...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting WU to auto..." . "`r`n", hOut)
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv, Start, 2>>HWID.log, , Hide
catch {
gosub, ProcessFail
return
}
FileAppend, Starting WU...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Starting WU..." . "`r`n", hOut)
svcname := "wuauserv"
gosub, ServiceStartTest
if (SStartedStatusMessage == "Functional [Start: 0]") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service Start successful: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, Service Start successful: %SStartedStatusMessage%`n`n, HWID.log
} else if (SStartedStatusMessage == "Running [Start: 10]") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service already: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, Service already: %SStartedStatusMessage%`n`n, HWID.log
} else {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ERROR: Service Start failed: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, ERROR: Service Start failed: %SStartedStatusMessage%`n`n, HWID.log
}
back1 = 1
} else {
FileAppend, WU is enabled: %wu% %S1StartedStatusMessage%`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " WU is enabled: " . wu . " " . S1StartedStatusMessage . "`r`n", hOut)
}
gosub, ClipSVCCheck
if (clipsvcraw == 4) {
FileAppend, ClipSVC is disabled...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ClipSVC is disabled..." . "`r`n", hOut)
FileAppend, Setting ClipSVC to auto...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting ClipSVC to auto..." . "`r`n", hOut)
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC, Start, 2>>HWID.log, , Hide
catch {
gosub, ProcessFail
return
}
FileAppend, Starting ClipSVC...`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Starting ClipSVC..." . "`r`n", hOut)
svcname := "clipsvc"
gosub, ServiceStartTest
if (SStartedStatusMessage == "Functional [Start: 0]") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service Start successful: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, Service Start successful: %SStartedStatusMessage%`n`n, HWID.log
} else if (SStartedStatusMessage == "Running [Start: 10]") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service already: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, Service already: %SStartedStatusMessage%`n`n, HWID.log
} else {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ERROR: Service Start failed: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, ERROR: Service Start failed: %SStartedStatusMessage%`n`n, HWID.log
}
back2 = 1
} else {
FileAppend, ClipSVC is enabled: %clipsvc% %S2StartedStatusMessage%`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ClipSVC is enabled: " . clipsvc . " " . S2StartedStatusMessage . "`r`n", hOut)
}
gosub, wlidsvcCheck
if (wlidsvcraw == 4) {
FileAppend, wlidsvc is disabled...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " wlidsvc is disabled..." . "`r`n", hOut)
FileAppend, Setting wlidsvc to auto...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting wlidsvc to auto..." . "`r`n", hOut)
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wlidsvc, Start, 2>>HWID.log, , Hide
catch {
gosub, ProcessFail
return
}
FileAppend, Starting wlidsvc...`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Starting wlidsvc..." . "`r`n", hOut)
svcname := "wlidsvc"
gosub, ServiceStartTest
if (SStartedStatusMessage == "Functional [Start: 0]") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service Start successful: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, Service Start successful: %SStartedStatusMessage%`n`n, HWID.log
} else if (SStartedStatusMessage == "Running [Start: 10]") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service already: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, Service already: %SStartedStatusMessage%`n`n, HWID.log
} else {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ERROR: Service Start failed: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, ERROR: Service Start failed: %SStartedStatusMessage%`n`n, HWID.log
}
back3 = 1
} else {
FileAppend, wlidsvc is enabled: %wlidsvc% %S3StartedStatusMessage%`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " wlidsvc is enabled: " . wlidsvc . " " . S3StartedStatusMessage . "`r`n", hOut)
}
gosub, sppsvcCheck
if (sppsvcraw == 4) {
FileAppend, sppsvc is disabled...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " sppsvc is disabled..." . "`r`n", hOut)
FileAppend, Setting sppsvc to auto...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting sppsvc to auto..." . "`r`n", hOut)
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\sppsvc, Start, 2>>HWID.log, , Hide
catch {
gosub, ProcessFail
return
}
FileAppend, Starting sppsvc...`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Starting sppsvc..." . "`r`n", hOut)
svcname := "sppsvc"
gosub, ServiceStartTest
if (SStartedStatusMessage == "Functional [Start: 0]") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service Start successful: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, Service Start successful: %SStartedStatusMessage%`n`n, HWID.log
} else if (SStartedStatusMessage == "Running [Start: 10]") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service already: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, Service already: %SStartedStatusMessage%`n`n, HWID.log
} else {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ERROR: Service Start failed: " . SStartedStatusMessage . "`r`n", hOut)
FileAppend, ERROR: Service Start failed: %SStartedStatusMessage%`n`n, HWID.log
}
back4 = 1
} else {
FileAppend, sppsvc is enabled: %sppsvc% %S4StartedStatusMessage%`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " sppsvc is enabled: " . sppsvc . " " . S4StartedStatusMessage . "`r`n", hOut)
}
if(Mode = "HWID") {
gosub, SystemChecks
off :=
if (online == "offline") {
GoSub, AdapterHandleSetEnabledAuto
off=1
} else if (online == "online") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " System is online!" . "`r`n", hOut)
}
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Activating..." . "`r`n", hOut)
FileAppend, Activating...`n, HWID.log
RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -ato>>HWID.log", , Hide
}
gosub, RefreshGUILicenseInformation
if (back1 == 1) {
FileAppend, Stopping WU...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Stopping WU..." . "`r`n", hOut)
svcname := "wuauserv"
gosub, ServiceStopMainProcess
FileAppend, Setting WU back to disabled...`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting WU back to disabled..." . "`r`n", hOut)
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv, Start, 4>>HWID.log, , Hide
catch {
gosub, ProcessFail
return
}
back :=
}
if (back2 == 1) {
FileAppend, Stopping ClipSVC...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Stopping ClipSVC..." . "`r`n", hOut)
svcname := "ClipSVC"
gosub, ServiceStopMainProcess
FileAppend, Setting ClipSVC back to disabled...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting ClipSVC back to disabled..." . "`r`n", hOut)
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC, Start, 4>>HWID.log, , Hide
catch {
gosub, ProcessFail
return
}
back2 :=
}
if (back3 == 1) {
FileAppend, Stopping wlidsvc...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Stopping wlidsvc..." . "`r`n", hOut)
svcname := "wlidsvc"
gosub, ServiceStopMainProcess
FileAppend, Setting wlidsvc back to disabled...`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting wlidsvc back to disabled..." . "`r`n", hOut)
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wlidsvc, Start, 4>>HWID.log, , Hide
catch {
gosub, ProcessFail
return
}
back3 :=
}
if (back4 == 1) {
FileAppend, Stopping sppsvc...`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Stopping sppsvc..." . "`r`n", hOut)
svcname := "sppsvc"
gosub, ServiceStopMainProcess
FileAppend, Setting sppsvc back to disabled...`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting sppsvc back to disabled..." . "`r`n", hOut)
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\sppsvc, Start, 4>>HWID.log, , Hide
catch {
gosub, ProcessFail
return
}
back4 :=
}
if (off == 1) {
FileAppend, Disabling Internet Connection.`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Disabling Internet Connection." . "`r`n", hOut)
GoSub, AdapterHandleSetDisabledAuto
off :=
}
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Done" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
GuiControl, , StatusProgress, 100
if(ProductStatusCode = 1) {
FileAppend, Successfully activated %ProductFamily%!`n, HWID.log
MsgBox, 64, Success, Successfully activated %ProductFamily%!
} else {
MsgBox, 16, Error, Failed to activate %ProductFamily%.`n`nPlease check HWID.log file for details.
FileAppend, Failed to activate %ProductFamily%. License status: %ProductStatusMsg%`n, HWID.log
}
FileAppend, `n`n, HWID.log
gosub, SystemInfo
Gui, -Disabled
InProcess = 0
return
ServiceStopMainProcess:
ServiceTest :=
ReturnValue :=
svcstop :=
ServiceTest = wmic service where name='%svcname%' call stopservice>%A_Temp%\check.txt
runwait, %COMSPEC% /C %ServiceTest%, ,Hide
fileread, svcstop, %A_Temp%\check.txt
filedelete, %A_Temp%\check.txt
Loop, Parse, svcstop, `n, `n`r
{
if !eachLine := Trim(A_LoopField)
continue
IfInstring, A_LoopField, ReturnValue =
{
stringsplit, InfoArray, A_LoopField, =
ReturnValue2 := InfoArray2
ReturnValue = %ReturnValue2%
if (ReturnValue == "0;") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service stopped successfully." . "`r`n", hOut)
FileAppend, Service stopped successfully.`n`n, HWID.log
} else if (ReturnValue <> "0;") {
if (ReturnValue == "5;") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Service stopped (or already not running)." . "`r`n", hOut)
FileAppend, Service stopped (or already not running).`n`n, HWID.log
} else {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ERROR: " . ReturnValue . "`r`n", hOut)
FileAppend, ERROR: %ReturnValue%.`n`n, HWID.log
}
}
}
}
return
ApplyCheck:
fileread, actcheck, %dir%\check.txt
filedelete, %dir%\check.txt
acount :=
a2count=0
Loop, Parse, actcheck, `n, `n`r
{
if !eachLine := Trim(A_LoopField)
continue
a2count++
IfInString, A_LoopField, no applicable
{
acount=1
}
IfInString, A_LoopField, Successfully converted
{
acount=2
}
}
if(acount = "1") {
FileAppend, %actcheck%`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ERROR: Ticket apply failed. No ticket found." . "`r`n", hOut)
FileAppend, ERROR: Ticket apply failed. No ticket found.`n, HWID.log
if (fallback == 1) {
return
}
gosub, TargetFallback
} else if(acount = "2") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Ticket apply successful." . "`r`n", hOut)
FileAppend, %actcheck%`n, HWID.log
FileAppend, Ticket apply successful.`n, HWID.log
} else if(a2count <= "2") {
FileAppend, %actcheck%`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ERROR: Ticket apply failed. Invalid ticket." . "`r`n", hOut)
FileAppend, ERROR: Ticket apply failed. Invalid ticket.`n, HWID.log
if (fallback == 1) {
return
}
gosub, TargetFallback
}
return
TargetFallback:
fallback=1
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Retrying with fallback method." . "`r`n", hOut)
FileAppend, Retrying with fallback method.`n, HWID.log
filedelete, %dir%\TargetSKU.txt
if(Mode = "HWID") {
FileAppend, %NewSku% 0`n, %dir%\TargetSKU.txt
} else if(Mode = "KMS38") {
FileAppend, %NewSku% 1`n, %dir%\TargetSKU.txt
}
try RunWait, %dir%\gatherosstate.exe, %dir%, Hide
catch {
gosub, ProcessFail
return
}
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Applying GenuineTicket.xml..." . "`r`n", hOut)
FileAppend, Applying GenuineTicket.xml...`n, HWID.log
try RunWait, %system32%\cmd.exe /c "clipup -v -o -altto `"%dir%`" >>%dir%\check.txt", , Hide
catch {
gosub, ProcessFail
return
}
gosub, ApplyCheck
if(acount = "1") {
gosub, ProcessFail
return
} else if(a2count <= "2") {
gosub, ProcessFail
return
}
return
KeyInstallOnly:
InProcess = 1
Gui, +Disabled
starttime := a_now
if (Mode == "HWID_Key"){
GoSub, RefreshGUILicenseInformation
} else if (Mode == "gVLK"){
GoSub, RefreshGUILicenseInformation
}
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " INSTALLING KEY:" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
IfNotInString, NewKey, %ProductPartialKey%
{
FileAppend, System check:`n, HWID.log
FileAppend, Description: %ProductDescription%`n, HWID.log
FileAppend, BuildLabEx: %buildlabex%.%buildlabex2%`n, HWID.log
FileAppend, Architecture: %vera%`n, HWID.log
FileAppend, PartialKey: %ProductPartialKey%`n, HWID.log
FileAppend, Edition: %ProductFamily%`n, HWID.log
FileAppend, Status %ProductStatusMsg%`n`n, HWID.log
FileAppend, Starting activation at %A_DD% %A_MMM% %A_YYYY% %A_Hour%:%A_Min%:%A_Sec%...`n`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Installing key:" . " " . NewKey . " " . "`r`n", hOut)
FileAppend, Installing key %NewKey%...`n, HWID.log
try RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -ipk %NewKey% >>HWID.log", , Hide
catch {
gosub, ProcessFail
return
}
GuiControl, , StatusProgress, 15
gosub, RefreshGUILicenseInformation
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Done" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
GuiControl, , StatusProgress, 100
FileAppend, `n`n, HWID.log
} else {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " KEY ALREADY INSTALLED!" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
}
gosub, SystemInfo
Gui, -Disabled
InProcess = 0
return
AdapterHandleSetDisabled:
output_Text(timestring . " SYSTEM FOUND BEING:" . " " . online . " " . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting Adapter to 'Disabled'" . "`r`n", hOut)
GuiControl, , StatusProgress, 40
MsgBox, 64, User Action needed!, Press 'OK' to set adapter to 'Disabled'.
try RunWait, %system32%\cmd.exe /c wmic path win32_networkadapter where index=%AIndex% call disable, , Hide
catch {
gosub, ProcessFail
return
}
GuiControl, , StatusProgress, 100
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
gosub, RefreshGUILicenseInformation
gosub, SystemChecks
gosub, GetOnlineAdapter
Sleep, 3000
gosub, SystemInfo
return
AdapterHandleSetDisabledAuto:
output_Text(timestring . " SYSTEM FOUND BEING:" . " " . online . " " . "`r`n", hOut)
FileAppend, SYSTEM FOUND BEING: %online%`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting Adapter to 'Disabled'" . "`r`n", hOut)
FileAppend, Setting Adapter to 'Disabled'`n`n, HWID.log
try RunWait, %system32%\cmd.exe /c wmic path win32_networkadapter where index=%AIndex% call disable, , Hide
catch {
gosub, ProcessFail
return
}
gosub, SystemChecks
gosub, GetOnlineAdapter
return
AdapterHandleSetEnabled:
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " SYSTEM FOUND BEING:" . " " . online . " " . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting Adapter to 'Enabled'" . "`r`n", hOut)
GuiControl, , StatusProgress, 40
MsgBox, 64, User Action needed!, Press 'OK' to set adapter to 'Enabled'.
try RunWait, %system32%\cmd.exe /c wmic path win32_networkadapter where index=%AIndex% call enable, , Hide
catch {
gosub, ProcessFail
return
}
GuiControl, , StatusProgress, 100
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
gosub, RefreshGUILicenseInformation
gosub, SystemChecks
gosub, GetOnlineAdapter
Sleep, 3000
gosub, SystemInfo
return
AdapterHandleSetEnabledAuto:
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " SYSTEM FOUND BEING:" . " " . online . " " . "`r`n", hOut)
FileAppend, SYSTEM FOUND BEING: %online%`n, HWID.log
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Setting Adapter to 'Enabled'" . "`r`n", hOut)
FileAppend, Setting Adapter to 'Enabled'`n`n, HWID.log
try RunWait, %system32%\cmd.exe /c wmic path win32_networkadapter where index=%AIndex% call enable, , Hide
catch {
gosub, ProcessFail
return
}
gosub, SystemChecks
gosub, GetOnlineAdapter
return
GetOnlineAdapter:
AName := "nul"
AStatus :=
AIndex :=
wmi := ComObjGet("winmgmts:")
for adapter in wmi.ExecQuery("Select * from Win32_NetworkAdapter WHERE NetEnabled=True and PhysicalAdapter=True and PNPDeviceID LIKE '%PCI%'")
AName := adapter.Name
AStatus := adapter.NetConnectionStatus
AIndex := adapter.Index
if (AName == "nul")
{
wmi := ComObjGet("winmgmts:")
for adapter in wmi.ExecQuery("Select * from Win32_NetworkAdapter WHERE NetEnabled=True and PhysicalAdapter=True and PNPDeviceID LIKE '%USB%'")
AName := adapter.Name
AStatus := adapter.NetConnectionStatus
AIndex := adapter.Index
}
return
GetOfflineAdapter:
AName := "nul"
AStatus :=
AIndex :=
wmi := ComObjGet("winmgmts:")
for adapter in wmi.ExecQuery("Select * from Win32_NetworkAdapter WHERE NetEnabled=False and PhysicalAdapter=True and PNPDeviceID LIKE '%PCI%'")
AName := adapter.Name
AStatus := adapter.NetConnectionStatus
AIndex := adapter.Index
if (AName == "nul")
{
wmi := ComObjGet("winmgmts:")
for adapter in wmi.ExecQuery("Select * from Win32_NetworkAdapter WHERE NetEnabled=False and PhysicalAdapter=True and PNPDeviceID LIKE '%USB%'")
AName := adapter.Name
AStatus := adapter.NetConnectionStatus
AIndex := adapter.Index
}
return
RefreshLicenseInformation:
WMI := ComObjGet("winmgmts:")
Query := WMI.ExecQuery("Select * FROM SoftwareLicensingProduct WHERE PartialProductKey IS NOT NULL")._NewEnum()
ProductLicenseID := ""
TempProductFamily := ""
TempProductName := ""
while(Query[Info]) {
TempProductFamily := Info.LicenseFamily
if(!TempProductFamily)
continue
TempProductName := Info.Name
if(!RegExMatch(TempProductName, "Windows.*"))
continue
ProductGrace := Info.GracePeriodRemaining
ProductDescription := Info.Description
ProductStatusCode := Info.LicenseStatus
ProductPartialKey := Info.PartialProductKey
ProductLicenseID := Info.ID
ProductFamily := TempProductFamily
ProductName := TempProductName
}
TempProductFamily := ""
TempProductName := ""
ProductGraceDaysRaw := (ProductGrace/60/24)
ProductGraceDays := Round(ProductGraceDaysRaw)
WMI := ComObjGet("winmgmts:")
Query := WMI.ExecQuery("Select * FROM Win32_OperatingSystem")._NewEnum()
while(Query[Info]) {
InstallDate := Info.InstallDate
OperatingSystemSKU := Info.OperatingSystemSKU
}
if(!ProductLicenseID) {
MsgBox, 16, %AppName%, Failed to determine licensing status. Please check if your system has any product key installed.
ExitApp
}
gosub, ConvertStatus
if (Mode == "HWID") {
GoSub, DetermineKeyAndSkuIDHWID
} else if (Mode == "KMS38") {
GoSub, DetermineKeyAndSkuIDKMS38
} else if (Mode == "HWID_Key") {
GoSub, DetermineKeyAndSkuIDHWID
} else if (Mode == "gVLK") {
GoSub, DetermineKeyAndSkuIDKMS38
} else if (Mode == "") {
GoSub, DetermineKeyAndSkuIDHWID
}
WMI := ""
Query := ""
Info := ""
return
ConvertStatus:
if(ProductStatusCode = 0) {
ProductStatusMsg = Unlicensed
} else if(ProductStatusCode = 1) {
ProductStatusMsg = Licensed
} else if(ProductStatusCode = 2) {
ProductStatusMsg = Initial grace period
} else if(ProductStatusCode = 3) {
ProductStatusMsg = Additional grace period
} else if(ProductStatusCode = 4) {
ProductStatusMsg = Non-genuine grace period
} else if(ProductStatusCode = 5) {
ProductStatusMsg = Notification
} else {
ProductStatusMsg = Unknown status: %ProductStatusCode%
}
return
DetermineKeyAndSkuIDHWID:
UnsupportedSku :=
if(ProductFamily = "Cloud") {
NewKey=V3WVW-N2PV2-CGWC3-34QGF-VMJ2C
NewSku=178
} else if(ProductFamily = "CloudN") {
NewKey=NH9J3-68WK7-6FB93-4K3DF-DJ4F6
NewSku=179
} else if(ProductFamily = "Core") {
NewKey=YTMG3-N6DKC-DKB77-7M9GH-8HVX7
NewSku=101
} else if(ProductFamily = "CoreCountrySpecific") {
NewKey=N2434-X9D7W-8PF6X-8DV9T-8TYMD
NewSku=99
} else if(ProductFamily = "CoreN") {
NewKey=4CPRK-NM3K3-X6XXQ-RXX86-WXCHW
NewSku=98
} else if(ProductFamily = "CoreSingleLanguage") {
NewKey=BT79Q-G7N6G-PGBYW-4YWX6-6F4BT
NewSku=100
} else if(ProductFamily = "Education") {
NewKey=YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY
NewSku=121
} else if(ProductFamily = "EducationN") {
NewKey=84NGF-MHBT6-FXBX8-QWJK7-DRR8H
NewSku=122
} else if(ProductFamily = "Enterprise") {
NewKey=XGVPP-NMH47-7TTHJ-W3FW7-8HV2C
NewSku=4
} else if(ProductFamily = "EnterpriseN") {
NewKey=3V6Q6-NQXCX-V8YXR-9QCYV-QPFCT
NewSku=27
} else if(ProductFamily = "EnterpriseS") {
if(A_OSVersion = "10.0.14393") {
NewKey=NK96Y-D9CD8-W44CQ-R8YTK-DYJWX
NewSku=125
} else if(A_OSVersion = "10.0.10240") {
NewKey=FWN7H-PF93Q-4GGP8-M8RF3-MDWWW
NewSku=125
} else {
UnsupportedSku=1
}
} else if(ProductFamily = "EnterpriseSN") {
if(A_OSVersion = "10.0.14393") {
NewKey=2DBW3-N2PJG-MVHW3-G7TDK-9HKR4
NewSku=126
} else if(A_OSVersion = "10.0.10240") {
NewKey=8V8WN-3GXBH-2TCMG-XHRX3-9766K
NewSku=126
} else {
UnsupportedSku=1
}
} else if(ProductFamily = "Professional") {
NewKey=VK7JG-NPHTM-C97JM-9MPGT-3V66T
NewSku=48
} else if(ProductFamily = "ProfessionalEducation") {
NewKey=8PTT6-RNW4C-6V7J2-C2D3X-MHBPB
NewSku=164
} else if(ProductFamily = "ProfessionalEducationN") {
NewKey=GJTYN-HDMQY-FRR76-HVGC7-QPF8P
NewSku=165
} else if(ProductFamily = "ProfessionalN") {
NewKey=2B87N-8KFHP-DKV6R-Y2C8J-PKCKT
NewSku=49
} else if(ProductFamily = "ProfessionalWorkstation") {
NewKey=DXG7C-N36C4-C4HTG-X4T3X-2YV77
NewSku=161
} else if(ProductFamily = "ProfessionalWorkstationN") {
NewKey=WYPNQ-8C467-V2W6J-TX4WX-WT2RQ
NewSku=162
} else if(ProductFamily = "ServerRdsh") {
NewKey=NJCF7-PW8QT-3324D-688JX-2YV66
NewSku=52
} else if(ProductFamily = "ServerRdshCore") {
NewKey=NJCF7-PW8QT-3324D-688JX-2YV66
NewSku=52
} else {
UnsupportedSku=1
}
return
DetermineKeyAndSkuIDKMS38:
UnsupportedSku :=
if(ProductFamily = "Core") {
NewKey=TX9XD-98N7V-6WMQ6-BX7FG-H8Q99
NewSku=101
} else if(ProductFamily = "CoreCountrySpecific") {
NewKey=PVMJN-6DFY6-9CCP6-7BKTT-D3WVR
NewSku=99
} else if(ProductFamily = "CoreN") {
NewKey=3KHY7-WNT83-DGQKR-F7HPR-844BM
NewSku=98
} else if(ProductFamily = "CoreSingleLanguage") {
NewKey=7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH
NewSku=100
} else if(ProductFamily = "Education") {
NewKey=NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
NewSku=121
} else if(ProductFamily = "EducationN") {
NewKey=2WH4N-8QGBV-H22JP-CT43Q-MDWWJ
NewSku=122
} else if(ProductFamily = "Enterprise") {
NewKey=NPPR9-FWDCX-D2C8J-H872K-2YT43
NewSku=4
} else if(ProductFamily = "EnterpriseN") {
NewKey=DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4
NewSku=27
} else if(ProductFamily = "EnterpriseS") {
if(A_OSVersion = "10.0.17763") {
NewKey=M7XTQ-FN8P6-TTKYV-9D4CC-J462D
NewSku=125
} else if(A_OSVersion = "10.0.14393") {
NewKey=DCPHK-NFMTC-H88MJ-PFHPY-QJ4BJ
NewSku=125
} else {
UnsupportedSku=1
}
} else if(ProductFamily = "EnterpriseSN") {
if(A_OSVersion = "10.0.17763") {
NewKey=92NFX-8DJQP-P6BBQ-THF9C-7CG2H
NewSku=126
} else if(A_OSVersion = "10.0.14393") {
NewKey=QFFDN-GRT3P-VKWWX-X7T3R-8B639
NewSku=126
} else {
UnsupportedSku=1
}
} else if(ProductFamily = "Professional") {
NewKey=W269N-WFGWX-YVC9B-4J6C9-T83GX
NewSku=48
} else if(ProductFamily = "ProfessionalEducation") {
NewKey=6TP4R-GNPTD-KYYHQ-7B7DP-J447Y
NewSku=164
} else if(ProductFamily = "ProfessionalEducationN") {
NewKey=YVWGF-BXNMC-HTQYQ-CPQ99-66QFC
NewSku=165
} else if(ProductFamily = "ProfessionalN") {
NewKey=MH37W-N47XK-V7XM9-C7227-GCQG9
NewSku=49
} else if(ProductFamily = "ProfessionalWorkstation") {
NewKey=NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J
NewSku=161
} else if(ProductFamily = "ProfessionalWorkstationN") {
NewKey=9FNHH-K3HBT-3W4TD-6383H-6XYWF
NewSku=162
} else if(ProductFamily = "ServerStandard") {
if(A_OSVersion = "10.0.14393") {
NewKey=WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY
NewSku=7
} else if(A_OSVersion = "10.0.17763") {
NewKey=N69G4-B89J2-4G8F4-WWYCC-J464C
NewSku=7
}
} else if(ProductFamily = "ServerStandardCore") {
if(A_OSVersion = "10.0.14393") {
NewKey=WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY
NewSku=7
} else if(A_OSVersion = "10.0.17763") {
NewKey=N69G4-B89J2-4G8F4-WWYCC-J464C
NewSku=7
}
} else if(ProductFamily = "ServerDatacenter") {
if(A_OSVersion = "10.0.14393") {
NewKey=CB7KF-BWN84-R7R2Y-793K2-8XDDG
NewSku=8
} else if(A_OSVersion = "10.0.17763") {
NewKey=WMDGN-G9PQG-XVVXX-R3X43-63DFG
NewSku=8
}
} else if(ProductFamily = "ServerDatacenterCore") {
if(A_OSVersion = "10.0.14393") {
NewKey=CB7KF-BWN84-R7R2Y-793K2-8XDDG
NewSku=8
} else if(A_OSVersion = "10.0.17763") {
NewKey=WMDGN-G9PQG-XVVXX-R3X43-63DFG
NewSku=8
}
} else if(ProductFamily = "ServerSolution") {
if(A_OSVersion = "10.0.14393") {
NewKey=JCKRF-N37P4-C2D82-9YXRT-4M63B
NewSku=52
} else if(A_OSVersion = "10.0.17763") {
NewKey=WVDHN-86M7X-466P6-VHXV7-YY726
NewSku=52
}
} else if(ProductFamily = "ServerSolutionCore") {
if(A_OSVersion = "10.0.14393") {
NewKey=JCKRF-N37P4-C2D82-9YXRT-4M63B
NewSku=52
} else if(A_OSVersion = "10.0.17763") {
NewKey=WVDHN-86M7X-466P6-VHXV7-YY726
NewSku=52
}
} else if(ProductFamily = "ServerCloudStorage") {
if(A_OSVersion = "10.0.14393") {
NewKey=QN4C6-GBJD2-FB422-GHWJK-GJG2R
NewSku=52
}
} else if(ProductFamily = "ServerRdsh") {
if(A_OSVersion = "10.0.14393") {
NewKey=7NBT4-WGBQX-MP4H7-QXFF8-YP3KX
NewSku=175
} else if(A_OSVersion = "10.0.17763") {
NewKey=CPWHC-NT2C7-VYW78-DHDB2-PG3GK
NewSku=175
}
} else if(ProductFamily = "ServerRdshCore") {
if(A_OSVersion = "10.0.14393") {
NewKey=7NBT4-WGBQX-MP4H7-QXFF8-YP3KX
NewSku=175
} else if(A_OSVersion = "10.0.17763") {
NewKey=CPWHC-NT2C7-VYW78-DHDB2-PG3GK
NewSku=175
}
} else {
UnsupportedSku=1
}
return
RefreshGUILicenseInformation:
gosub, RefreshLicenseInformation
GuiControl, , EditionInfo, %ProductFamily%
GuiControl, , StatusCodeInfo, %ProductStatusMsg%
GuiControl, , PartialKeyInfo, %ProductPartialKey%
return
ProcessFail:
MsgBox, 16, Error, Process failed.
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . "Failed" . "`r`n", hOut)
Gui, -Disabled
InProcess = 0
return
WUCheck:
RegRead, wuraw, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv, Start
if (wuraw == 1) {
wu=AUTO DELAYED
}
if (wuraw == 2) {
wu=AUTO
}
if (wuraw == 3) {
wu=MANUAL
}
if (wuraw == 4) {
wu=DISABLED
}
return
ClipSVCCheck:
RegRead, clipsvcraw, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC, Start
if (clipsvcraw == 1) {
clipsvc=AUTO DELAYED
}
if (clipsvcraw == 2) {
clipsvc=AUTO
}
if (clipsvcraw == 3) {
clipsvc=MANUAL
}
if (clipsvcraw == 4) {
clipsvc=DISABLED
}
return
wlidsvcCheck:
RegRead, wlidsvcraw, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wlidsvc, Start
if (wlidsvcraw == 1) {
wlidsvc=AUTO DELAYED
}
if (wlidsvcraw == 2) {
wlidsvc=AUTO
}
if (wlidsvcraw == 3) {
wlidsvc=MANUAL
}
if (wlidsvcraw == 4) {
wlidsvc=DISABLED
}
return
sppsvcCheck:
RegRead, sppsvcraw, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\sppsvc, Start
if (sppsvcraw == 1) {
sppsvc=AUTO DELAYED
}
if (sppsvcraw == 2) {
sppsvc=AUTO
}
if (sppsvcraw == 3) {
sppsvc=MANUAL
}
if (sppsvcraw == 4) {
sppsvc=DISABLED
}
return
CleanTokens:
starttime := a_now
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " CLEANING SPPSVC TOKENS:" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Stopping SPPSVC." . "`r`n", hOut)
RunWait, %system32%\cmd.exe /c "sc stop sppsvc", , Hide
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Deleting Tokens.." . "`r`n", hOut)
FileDelete %system32%\spp\store\2.0\tokens.dat
FileDelete %system32%\spp\store\2.0\data.dat
FileDelete %system32%\spp\store\2.0\cache\cache.dat
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Forcing Rebuild.." . "`r`n", hOut)
GoSub, DetermineKeyAndSkuIDKMS38
RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -ipk %NewKey%", , Hide
RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -dlv", , Hide
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
gosub, SystemInfo
return
Clean_ClipSVC:
starttime := a_now
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " CLEANING CLIPSVC TOKENS:" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Stopping CLIPSVC." . "`r`n", hOut)
RunWait, %system32%\cmd.exe /c "sc stop clipsvc", , Hide
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Deleting Tokens.." . "`r`n", hOut)
FileDelete %A_AppDataCommon%\Microsoft\Windows\ClipSVC\tokens.dat
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Forcing Rebuild.." . "`r`n", hOut)
RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -dlv", , Hide
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
gosub, SystemInfo
return
RearmSystem:
starttime := a_now
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " REARM SYSTEM:" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Rearming.." . "`r`n", hOut)
RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -rearm", , Hide
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Rebooting [Mandatory!].." . "`r`n", hOut)
MsgBox, 64, Rebooting now...!, This is mandatory!
RunWait, %system32%\cmd.exe /c "shutdown.exe /r /t 3 ", , Hide
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
return
SystemInfo:
gosub, RefreshLicenseInformation
gosub, SystemChecks
if (online == "online") {
gosub, GetOnlineAdapter
} else if (online == "offline") {
gosub, GetOfflineAdapter
}
starttime := a_now
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " SYSTEM INFO:" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Product:" . " " . ProductFamily . " [" . buildlabex . "." . buildlabex2 . "] " . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Description:" . " " . channel . " " . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Architecture:" . " " . vera . " " . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " LicenseID:" . " " . ProductLicenseID . " " . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Key:" . " " . SysKey . " " . "`r`n", hOut)
IfNotInString, NewKey, %SysKey%
{
if(UnsupportedSku) {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " No key in found in database!" . "`r`n", hOut)
} else {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " DefaultKey:" . " " . NewKey . " " . "`r`n", hOut)
}
}
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Status:" . " " . ProductStatusMsg . " " . "`r`n", hOut)
if (ProductGrace) {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Grace (Days):" . " " . ProductGraceDays . " "  . "`r`n", hOut)
}
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " WUauserv Status:" . " " . wu . " "  . S1StartedStatus . " " . S1StartedState . " " . S1StartedStatusMessage . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ClipSVC Status:" . " " . clipsvc . " "  . S2StartedStatus . " " . S2StartedState . " " . S2StartedStatusMessage . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " wlidsvc Status:" . " " . wlidsvc . " " . S3StartedStatus . " " . S3StartedState . " " . S3StartedStatusMessage . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " sppsvc Status:" . " " . sppsvc . " " . S4StartedStatus . " " . S4StartedState . " " . S4StartedStatusMessage . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " System is:" . " " . online . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Adapter:" . " " . AName . " Index: [" . AIndex . "]" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
if (ProductStatusCode == 1) {
if not (channel == "VOLUME_KMSCLIENT") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Detected: permanently licensed" . " " . channel . " " . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " NO PATCHING NEEDED!" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
} else if (channel == "VOLUME_KMSCLIENT") {
ifGreater, ProductGraceDays, 200
{
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Detected: KMS38 activated" . " " . channel . " " . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " NO PATCHING NEEDED!" . "`r`n", hOut)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut)
}
}
}
return
SystemInfo2:
gosub, RefreshLicenseInformation
gosub, SystemChecks
if (online == "online") {
gosub, GetOnlineAdapter
} else if (online == "offline") {
gosub, GetOfflineAdapter
}
starttime := a_now
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " SYSTEM INFO:" . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Product:" . " " . ProductFamily . " [" . buildlabex . "." . buildlabex2 . "] " . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Description:" . " " . channel . " " . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Architecture:" . " " . vera . " | SKUID: " . OperatingSystemSKU . "" . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " LicenseID:" . " " . ProductLicenseID . " " . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " System Key:" . " " . SysKey . " " . "`r`n", hOut2)
IfNotInString, NewKey, %SysKey%
{
if(UnsupportedSku) {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " No key in found in database!" . "`r`n", hOut2)
} else {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " DefaultKey:" . " " . NewKey . " " . "`r`n", hOut2)
}
}
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Status:" . " " . ProductStatusMsg . " " . "`r`n", hOut2)
if (ProductGrace) {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Grace (Days):" . " " . ProductGraceDays . " "  . "`r`n", hOut2)
}
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " WUauserv Status:" . " " . wu . " "  . S1StartedStatus . " " . S1StartedState . " " . S1StartedStatusMessage . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " ClipSVC Status:" . " " . clipsvc . " "  . S2StartedStatus . " " . S2StartedState . " " . S2StartedStatusMessage . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " wlidsvc Status:" . " " . wlidsvc . " " . S3StartedStatus . " " . S3StartedState . " " . S3StartedStatusMessage . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " sppsvc Status:" . " " . sppsvc . " " . S4StartedStatus . " " . S4StartedState . " " . S4StartedStatusMessage . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " System is:" . " " . online . " "  . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Adapter:" . " " . AName . " Index: [" . AIndex . "]" . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut2)
if (ProductStatusCode == 1) {
if not (channel == "VOLUME_KMSCLIENT") {
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Detected: permanently licensed" . " " . channel . " " . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " NO PATCHING NEEDED!" . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut2)
} else if (channel == "VOLUME_KMSCLIENT") {
ifGreater, ProductGraceDays, 200
{
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " Detected: KMS38 activated" . " " . channel . " " . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " NO PATCHING NEEDED!" . "`r`n", hOut2)
FormatTime, TimeString,,HH:mm:ss
output_Text(timestring . " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" . "`r`n", hOut2)
}
}
}
return
LaunchAIOWares:
Run http://aiowares.com/showthread.php?tid=246
return
LaunchNsane:
Run http://www.nsaneforums.com/topic/312871-windows-10-digital-license-hwid-generation-without-kms-or-predecessor-installupgrade
return
SystemChecks:
stringsplit, InfoArray, ProductDescription, %A_Space%
channel := InfoArray4
InProcess = 0
strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")
colPings := objWMIService.ExecQuery("Select * From Win32_PingStatus where Address = 'www.google.com'")._NewEnum
While colPings[objStatus]
{
If (objStatus.StatusCode="" or objStatus.StatusCode<>0)
online = offline
Else
online = online
}
colPings := ""
strComputer := ""
abortcount=0
svcname := "wuauserv"
gosub, ServiceCheck
S1StartedStatus := SStartedStatus
S1StartedState := SStartedState
if (S1StartedStatus = "TRUE") {
S1StartedStatusMessage := "Functional"
} else if (S1StartedStatus = "FALSE") {
if (wuraw == 4) {
gosub, ServiceTempEnable
Sleep, 2000
}
gosub, ServiceStartTest
S1StartedStatusMessage := SStartedStatusMessage
if (wuraw == 4) {
gosub, ServiceTempDisable
}
}
svcname := "ClipSVC"
gosub, ServiceCheck
S2StartedStatus := SStartedStatus
S2StartedState := SStartedState
if (S2StartedStatus = "TRUE") {
S2StartedStatusMessage := "Functional"
} else if (S2StartedStatus = "FALSE") {
if (clipsvcraw == 4) {
gosub, ServiceTempEnable
Sleep, 2000
}
gosub, ServiceStartTest
S2StartedStatusMessage := SStartedStatusMessage
if (clipsvcraw == 4) {
gosub, ServiceTempDisable
}
}
svcname := "wlidsvc"
gosub, ServiceCheck
S3StartedStatus := SStartedStatus
S3StartedState := SStartedState
if (S3StartedStatus = "TRUE") {
S3StartedStatusMessage := "Functional"
} else if (S3StartedStatus = "FALSE") {
if (wlidsvcraw == 4) {
gosub, ServiceTempEnable
Sleep, 2000
}
gosub, ServiceStartTest
S3StartedStatusMessage := SStartedStatusMessage
if (wlidsvcraw == 4) {
gosub, ServiceTempDisable
}
}
svcname := "sppsvc"
gosub, ServiceCheck
S4StartedStatus := SStartedStatus
S4StartedState := SStartedState
if (S4StartedStatus = "TRUE") {
S4StartedStatusMessage := "Functional"
} else if (S4StartedStatus = "FALSE") {
if (sppsvcraw == 4) {
gosub, ServiceTempEnable
Sleep, 2000
}
gosub, ServiceStartTest
S4StartedStatusMessage := SStartedStatusMessage
if (sppsvcraw == 4) {
gosub, ServiceTempDisable
}
}
RegRead, rawbuildlabex, HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion, BuildLabEx
stringsplit, InfoArray, rawbuildlabex, .
buildlabex := InfoArray1
RegRead, ubr, HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion, UBR
SetFormat Integer, D
buildlabex2 := ubr
buildlabex2 = %buildlabex2%
FileInstall, PID8.vbs, %A_Temp%\PID8.vbs, 1
RunWait, %system32%\cmd.exe /c (cscript.exe /nologo %A_Temp%\PID8.vbs)>>%A_Temp%\kms.log, , Hide
fileread, syskey, %A_Temp%\kms.log
Loop, Parse, syskey, `n, `n`r
{
if !eachLine := Trim(A_LoopField)
continue
SysKey := A_LoopField
}
filedelete, %A_Temp%\kms.log
filedelete, %A_Temp%\PID8.vbs
return
ServiceTempEnable:
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%svcname%, Start, 2 >>HWID.log", , Hide
catch {
gosub, ProcessFail
return
}
return
ServiceTempDisable:
try RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%svcname%, Start, 4 >>HWID.log", , Hide
catch {
gosub, ProcessFail
return
}
return
ServiceStartTest:
SStartedStatusReturn :=
ServiceTest = wmic service where name='%svcname%' call startservice>%A_Temp%\svctest.txt
runwait, %COMSPEC% /C %ServiceTest%, ,Hide
fileread, svctest, %A_Temp%\svctest.txt
filedelete, %A_Temp%\svctest.txt
Loop, Parse, svctest, `n, `n`r
{
if !eachLine := Trim(A_LoopField)
continue
IfInstring, A_LoopField, ReturnValue =
{
stringsplit, InfoArray, A_LoopField, =
ReturnValue2 := InfoArray2
ReturnValue = %ReturnValue2%
if (ReturnValue == "0;") {
SStartedStatusMessage := "Functional [Start: 0]"
} else if (ReturnValue = "1;") {
SStartedStatusMessage := "Infunctional [Start: 1]"
abortcount++
} else if (ReturnValue = "2;") {
SStartedStatusMessage := "Access Denied [Start: 2]"
abortcount++
} else if (ReturnValue = "4;") {
SStartedStatusMessage := "Invalid [Start: 4]"
abortcount++
} else if (ReturnValue = "5;") {
SStartedStatusMessage := "Invalid [Start: 5]"
abortcount++
} else if (ReturnValue = "6;") {
SStartedStatusMessage := "Invalid [Start: 6]"
abortcount++
} else if (ReturnValue = "7;") {
SStartedStatusMessage := "TimeOut [Start: 7]"
abortcount++
} else if (ReturnValue = "8;") {
SStartedStatusMessage := "Unknown [Start: 8]"
abortcount++
} else if (ReturnValue = "9;") {
SStartedStatusMessage := "Path Missing [Start: 9]"
abortcount++
} else if (ReturnValue = "10;") {
SStartedStatusMessage := "Running [Start: 10]"
abortcount++
} else if (ReturnValue = "12;") {
SStartedStatusMessage := "Dependency Missing [Start: 12]"
abortcount++
} else if (ReturnValue = "13;") {
SStartedStatusMessage := "Service Missing [Start: 13]"
abortcount++
} else if (ReturnValue = "14;") {
SStartedStatusMessage := "Service Disabled [Start: 14]"
abortcount++
} else if (ReturnValue = "15;") {
SStartedStatusMessage := "Auth Missing [Start: 15]"
abortcount++
} else if (ReturnValue = "16;") {
SStartedStatusMessage := "Service Removed [Start: 16]"
abortcount++
} else if (ReturnValue = "17;") {
SStartedStatusMessage := "ExThread Missing [Start: 17]"
abortcount++
} else if (ReturnValue = "22;") {
SStartedStatusMessage := "Account Restriction [Start: 22]"
abortcount++
} else {
SStartedStatusMessage := ReturnValue
abortcount++
}
}
}
ServiceTest :=
ServiceTest = wmic service where name='%svcname%' call stopservice
runwait, %COMSPEC% /C %ServiceTest%, ,Hide
if (svcname == "wuauserv") {
ServiceTest :=
ServiceTest = wmic service where name='%svcname%' call stopservice
runwait, %COMSPEC% /C %ServiceTest%, ,Hide
}
return
ServiceCheck:
SStartedStatus :=
SStartedState :=
ServiceChk = wmic service where name='%svcname%' get started,state /value>"%A_Temp%\svccheck.txt
runwait, %COMSPEC% /C %ServiceChk%, ,Hide
fileread, svccheck, %A_Temp%\svccheck.txt
filedelete, %A_Temp%\svccheck.txt
Loop, Parse, svccheck, `n, `n`r
{
if !eachLine := Trim(A_LoopField)
continue
IfInstring, A_LoopField, Started
{
stringsplit, InfoArray, A_LoopField, =
SStartedStatus := InfoArray2
}
IfInstring, A_LoopField, State
{
stringsplit, InfoArray, A_LoopField, =
SStartedState := InfoArray2
}
}
return
InfoSplash:
Gui, InfoSplashScreen: Color, 0067B3
Gui, InfoSplashScreen: Font, CFFFFFF, Segoe UI
Gui, InfoSplashScreen: Margin, 32, 32
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, x+8 ym-8 w450, USE THE MODE DROP-DOWN-MENU TOP-RIGHT.
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, HWID:
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, Supports all editions BUT NOT LTSC 2019 and Server.
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, KMS38:
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, Supports all editions WITH LTSC 2019 and Server.
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, HWID_Key:
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, Installs Generic Default Key for supported HWID editions.
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, gVLK:
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, Installs the Generic Volume Key used by KMS38 and real KMS.
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, Clean:
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, Only use this to break the '180 Days Lock' on KMS activated systems.
Gui, InfoSplashScreen: Add, Text, y+0 wp, DO NOT USE IF OFFICE IS INSTALLED!!! See 'Rearm' in that case. This will rebuild the license files. In case of errors, Reboot!
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, Clean_ClipSVC:
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, Only use to clean HWID/Store tokens when using System Images on a different machine (cannot activate two systems with same tokens).
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, Rearm:
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, Only use this to break the '180 Days Lock' on KMS activated systems.
Gui, InfoSplashScreen: Add, Text, y+0 wp, ONLY USE IF OFFICE IS INSTALLED. This requires a Reboot (Mandatory!).
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, SetOnline and SetOffline:
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, Will change the net adapter status to enabled/disabled.
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, LicenseSwitch:
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, IN-PLACE-UPGRADE: Core(N) [Home (N)] to Professional(N). This requires a Reboot (Mandatory!).
Gui, InfoSplashScreen: Add, Text, y+0 wp, NOTE: IRREVERSIBLE!. Going back needs a re-install.
Gui, InfoSplashScreen: Font, S4
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S10
Gui, InfoSplashScreen: Add, Text, y+0 wp, LICENSE-SWITCH: From version 1803 on all other editions are virtual*. This requires a Reboot (Mandatory!).
Gui, InfoSplashScreen: Font, S9
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Add, Text, y+0 wp, (*Setup installs basically Enterprise with Product Policies enabled for the respective edition. So a License switch just changes the Product Policy and after a Reboot all edition specific features are activated).
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Add, Text, y+0 wp,
Gui, InfoSplashScreen: Font, S14
Gui, InfoSplashScreen: Add, Text, y+0 wp, PRESS 'ESC' TO EXIT.
Gui, InfoSplashScreen: -Caption
Gui, InfoSplashScreen: +AlwaysOnTop
Gui, InfoSplashScreen: -SysMenu
Gui, InfoSplashScreen: -MinimizeBox
Gui, InfoSplashScreen: Show, , HWID KMS38 Gen Info Screen
Esc::
Gui, InfoSplashScreen: Destroy,
return
SilentRun:
InProcess = 1
if(A_Is64bitOS) {
system32 = %A_WinDir%\sysnative
vera = x64
} else {
system32 = %A_WinDir%\system32
vera = x86
}
Random, rand
dir = %A_WinDir%\temp\GatherOsState%rand%
FileCreateDir, %dir%
RunWait, %system32%\cmd.exe /c (Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx" /v Title /t REG_SZ /d BootTask /f), , Hide
RunWait, %system32%\cmd.exe /c (Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx" /v Flags /t REG_DWORD /d 2 /f), , Hide
if(go == "h") {
FileInstall, warnh.exe, %A_WinDir%\temp\warnh.exe, 1
RunWait, %system32%\cmd.exe /c (Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx\0001" /v MyScript /t REG_SZ /d %A_WinDir%\temp\warnh.exe /f), , Hide
} else if(go == "k") {
FileInstall, warnk.exe, %A_WinDir%\temp\warnk.exe, 1
RunWait, %system32%\cmd.exe /c (Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx\0001" /v MyScript /t REG_SZ /d %A_WinDir%\temp\warnk.exe /f), , Hide
}
if(go == "h") {
gosub, RefreshLicenseInformation
gosub, SystemChecks
} else if(go == "k") {
gosub, RefreshLicenseInformation
gosub, SystemChecks
}
FileAppend, System check:`n, HWID.log
FileAppend, Description: %ProductDescription%`n, HWID.log
FileAppend, Architecture: %vera%`n, HWID.log
FileAppend, PartialKey: %ProductPartialKey%`n, HWID.log
FileAppend, Edition: %ProductFamily%`n, HWID.log
FileAppend, Status %ProductStatusMsg%`n`n, HWID.log
FileAppend, Starting activation at %A_DD% %A_MMM% %A_YYYY% %A_Hour%:%A_Min%:%A_Sec%...`n`n, HWID.log
FileAppend, Installing key %NewKey%...`n, HWID.log
RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -ipk %NewKey% >>HWID.log", , Hide
if(go == "k") {
FileAppend, Setting KMS Host IP to avoid DNS queries...`n, HWID.log
RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -skms 192.0.2.69:1833 >> HWID.log", , Hide
gosub, RefreshLicenseInformation
}
if(go == "h") {
if(ProductFamily = "EnterpriseS") {
if(A_OSVersion = "10.0.10240") {
FileInstall, gatherosstateLTSB15.exe, %dir%\gatherosstate.exe, 1
} else {
FileInstall, gatherosstate.exe, %dir%\gatherosstate.exe, 1
}
} else if(ProductFamily = "EnterpriseSN") {
if(A_OSVersion = "10.0.10240") {
FileInstall, gatherosstateLTSB15.exe, %dir%\gatherosstate.exe, 1
} else {
FileInstall, gatherosstate.exe, %dir%\gatherosstate.exe, 1
}
} else {
FileInstall, gatherosstate.exe, %dir%\gatherosstate.exe, 1
}
FileInstall, slshim32_aio.dll, %dir%\slc.dll, 1
FileAppend, -1 0`n, %dir%\TargetSKU.txt
} else if(go == "k") {
FileInstall, gatherosstate.exe, %dir%\gatherosstate.exe, 1
FileInstall, slshim32_aio.dll, %dir%\slc.dll, 1
FileAppend, -1 1`n, %dir%\TargetSKU.txt
}
FileAppend, Creating ticket...`n`n, HWID.log
try RunWait, %dir%\gatherosstate.exe, %dir%, Hide
catch {
gosub, ProcessFail
return
}
FileAppend, Applying GenuineTicket.xml...`n`n, HWID.log
try RunWait, %system32%\cmd.exe /c "clipup -v -o -altto `"%dir%`" >>%dir%\check.txt", , Hide
catch {
gosub, ProcessFail
return
}
gosub, SilentApplyCheck
if(go == "h") {
FileAppend, Activating...`n, HWID.log
RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -ato >>HWID.log", , Hide
}
FileAppend, Done.`n, HWID.log
FileAppend, `n`n, HWID.log
FileRemoveDir, %dir%, 1
InProcess = 0
ExitApp
NonGenuineGuiClose:
return
SilentApplyCheck:
fileread, actcheck, %dir%\check.txt
filedelete, %dir%\check.txt
acount :=
a2count=0
Loop, Parse, actcheck, `n, `n`r
{
if !eachLine := Trim(A_LoopField)
continue
a2count++
IfInString, A_LoopField, no applicable
{
acount=1
}
IfInString, A_LoopField, Successfully converted
{
acount=2
}
}
if(acount = "1") {
FileAppend, %actcheck%`n, HWID.log
FileAppend, ERROR: Ticket apply failed. No ticket found.`n, HWID.log
gosub, SilentTargetFallback
} else if(acount = "2") {
FileAppend, %actcheck%`n, HWID.log
FileAppend, Ticket apply successful.`n, HWID.log
} else if(a2count <= "2") {
FileAppend, %actcheck%`n, HWID.log
FileAppend, ERROR: Ticket apply failed. Invalid ticket.`n, HWID.log
gosub, SilentTargetFallback
}
return
SilentTargetFallback:
FileAppend, Retrying with fallback method.`n, HWID.log
filedelete, %dir%\TargetSKU.txt
if(go = "h") {
FileAppend, %NewSku% 0`n, %dir%\TargetSKU.txt
} else if(go = "k") {
FileAppend, %NewSku% 1`n, %dir%\TargetSKU.txt
}
try RunWait, %dir%\gatherosstate.exe, %dir%, Hide
catch {
gosub, ProcessFail
return
}
FileAppend, Applying GenuineTicket.xml...`n, HWID.log
try RunWait, %system32%\cmd.exe /c "clipup -v -o -altto `"%dir%`" >>%dir%\check.txt", , Hide
catch {
gosub, ProcessFail
return
}
gosub, SilentApplyCheck
if(acount = "1") {
gosub, ProcessFail
return
} else if(a2count <= "2") {
gosub, ProcessFail
return
}
return
output_Text(Text, hWnd) {
static Start, Stop
SendMessage, 0xB0, &Start, &Stop,, ahk_id %hWnd%
SendMessage, 0xC2,       , &Text,, ahk_id %hWnd%
SendMessage, 0xB0, &Start, &Stop,, ahk_id %hWnd%
}
GuiEscape:
if(InProcess) {
return
} else {
ExitApp
}
GuiClose:
if(InProcess) {
return
} else {
ExitApp
}
