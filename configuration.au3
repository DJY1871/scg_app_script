#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>

$windowTitle = "ESCORT Console Pro 2.12.07"

;Run 預設路徑執行檔
If  Not WinExists($windowTitle) Then
	$Runerrro = Run("C:\Program Files (x86)\Escort DLS\Escort Console\Escort.exe")
	if $Runerrro = 0 Then
		ConsoleWrite("Can't activate ESCORT Console Pro app. Please check the path where your app executable file is saved." & @CRLF)
		Exit
    EndIf
EndIf
WinWait($windowTitle, "", 15)

;Creat a Warning GUI
$hGUI = GUICreate("Warning", 300, 100, -1, -1, $WS_POPUPWINDOW, $WS_EX_TOPMOST + $WS_EX_TOOLWINDOW)
GUISetState(@SW_SHOW)
GUICtrlCreateLabel("Automation Script is running now, please don't move!!!", 10, 40, 280, 20)

If WinExists("[CLASS:#32770; TITLE:ESCORT Console]") Then
    ControlClick("ESCORT Console", "", "[CLASS:Button; INSTANCE:2]")
EndIf

Sleep(2000)
GUIDelete()

if WinExists($windowTitle) Then
	ControlSend($windowTitle,"","","{F6}")
	Sleep(1000)
	$configWindowTitle = "Program and Configure"
	WinWait($configWindowTitle,"",10)
	if WinExists($configWindowTitle) Then
        ControlClick($configWindowTitle, "", "[CLASS:Button; INSTANCE:1]")
        ;call properties window
        Local $i = 1
        While $i <= 10
            Sleep(500)
            Local $hListView = ControlGetHandle($configWindowTitle, "", "[CLASS:SysListView32]")
			_GUICtrlListView_ClickItem($hListView, 0)
			_GUICtrlListView_ClickItem($hListView, 0)
            Sleep(500)
            If WinExists("ESCORT iLog/Qualaire Properties") Then
				WinSetState(WinExists("ESCORT iLog/Qualaire Properties"), "", @SW_HIDE)
                ExitLoop
            EndIf
            $i += 1
        WEnd
    Else
        ConsoleWrite("Can't find " & $configWindowTitle & " window"& @CRLF)
        CloseAppWindows($windowTitle)
        Exit
	EndIf

	$propertiesWindowTitle = "ESCORT iLog/Qualaire Properties"
    Sleep(500)
    $visibleText = WinGetText($propertiesWindowTitle)
	
	;print property of device
    If $visibleText <> "" Then
        ;Parse the property string
        $serialNumber = StringRegExpReplace($visibleText, "(?s).*Serial Number:\s*([^\r\n]*).*", "\1")
        $batteryStatus = StringRegExpReplace($visibleText, "(?s).*Battery Status:\s*([^\r\n]*).*", "\1")
        $description = StringRegExpReplace($visibleText, "(?s).*Description:\s*([^\r\n]*).*", "\1")
        $productcode = StringRegExpReplace($visibleText, "(?s).*Product Code:\s*([^\r\n]*).*", "\1")

        ;Write property in console
        ConsoleWrite("Serial Number: " & $serialNumber & @CRLF)
        ConsoleWrite("Battery Status: " & $batteryStatus & @CRLF)
        ConsoleWrite("Description: " & $description & @CRLF)
        ConsoleWrite("Product Code: " & $productcode & @CRLF)
        ; MsgBox(0, "Status", "Serial Number: " & $serialNumber & " Battery Status: " & $batteryStatus)
        ControlSend($propertiesWindowTitle, "", "", "{ENTER}")
    Else
        ConsoleWrite("Error: Unable to find the window or read text from it." & @CRLF)
        ConsoleWrite("Please check Battery,COM connect,Sensor connect." & @CRLF)
        CloseAppWindows($windowTitle)
		Exit
    EndIf

    ;set description
    IF WinExists($configWindowTitle) Then
        ;click next to details
        ControlClick($configWindowTitle,"","[CLASS:Button; INSTANCE:1]")
        Sleep(500)
        $description = $cmdline[1]
        if $description <> "def" Then
            ControlSend($configWindowTitle,"","[CLASS:Edit; INSTANCE:1]",$description)
        EndIf
        ;click next to sensor display
        ControlClick($configWindowTitle,"","[CLASS:Button; INSTANCE:1]")
        Sleep(500)
    Else
        ConsoleWrite("Can't find " & $configWindowTitle & "window"& @CRLF)
        CloseAppWindows($windowTitle)
        Exit
    EndIf
    
    ;set sensors display
    $buttonid = 1004
    $configsnesor = "Configure Sensor"
    If WinExists($configWindowTitle) Then
        ControlClick($configWindowTitle,"",5182)
        If WinExists($configsnesor) Then
            ControlClick($configsnesor,"",$buttonid)
            Sleep(500)
            ;set temperature
            $mintemper = $cmdline[2]
            $maxtemper = $cmdline[3]
            $increment = $cmdline[4]
            ControlSend($configsnesor,"","[CLASS:Edit; INSTANCE:2]",$mintemper)
            ControlSend($configsnesor,"","[CLASS:Edit; INSTANCE:3]",$maxtemper)
            ControlSend($configsnesor,"","[CLASS:Edit; INSTANCE:3]",$increment)
            ControlClick($configsnesor,"",$buttonid)
            ControlClick($configsnesor,"",$buttonid)
            Sleep(500)
            ;set alarm
            For $i = 5 To 11
                If $cmdline[$i] = "T" Then
                    ControlClick($configsnesor, "", "[CLASS:Button; INSTANCE:" & $i & "]")
                    Sleep(200)
                EndIf
            Next
            If $cmdline[7] = "T" Then
                ControlClick($configsnesor, "", "[CLASS:Button; INSTANCE:7]")
            EndIf
            ControlSend($configsnesor,"","[CLASS:Edit; INSTANCE:1]",$cmdline[12])
            ControlSend($configsnesor,"","[CLASS:Edit; INSTANCE:2]",$cmdline[13])
            ;exit coknfigsensor window
            ControlClick($configsnesor,"",$buttonid)
            ControlClick($configsnesor,"",$buttonid)
        Else
            ConsoleWrite("Can't find " & $configsnesor & "window"& @CRLF)
            CloseAppWindows($windowTitle)
        EndIf
    Else
        CloseAppWindows($windowTitle)
        Exit
    EndIf

    ;to sampling time setting window
    ControlClick($configWindowTitle,"",$buttonid)
    ControlClick($configWindowTitle,"",$buttonid)

    ;set sampling time
    If WinExists($configWindowTitle) Then
        ;Duration time
        ControlCommand($configWindowTitle,"",5244,"SelectString",$cmdline[14])
        Sleep(50)
        ;set reading interval days
        ControlSend($configWindowTitle,"","[CLASS:Edit; INSTANCE:1]",$cmdline[15])
        Sleep(50)
        ;set reading interval hr min sec
        ControlSend($configWindowTitle,"",5223,$cmdline[16])
        Sleep(50)
        ;start log time
        Switch  $cmdline[17]
            ;set wait hr min
            Case 1
                ControlSend($configWindowTitle,"",5227,$cmdline[18])
                Sleep(50)
            ;set in time day hr min
            Case 2
                ControlSend($configWindowTitle,"",5229,$cmdline[19])
                Sleep(50)
                ControlSend($configWindowTitle,"",5230,$cmdline[20])
                Sleep(50)
            ;set log at precise time
            Case 3
                $day = $cmdline[21]
                If StringInStr($day, "上") Then
                    ControlSend($configWindowTitle,"",5232,$day)
                    For $i = 1 To 2
                        ControlSend("Program and Configure","",5232,"{left}")
                        Sleep(50)
                    Next
                    ControlSend($configWindowTitle,"",5232,"上")
                Else
                    ControlSend($configWindowTitle,"",5232,$day)
                    For $i = 1 To 2
                        ControlSend("Program and Configure","",5232,"{left}")
                        Sleep(50)
                    Next
                    ControlSend($configWindowTitle,"",5232,"下")
                EndIf
            Case Else
                ConsoleWrite("Error")
        EndSwitch

        ;finish log time
        Switch  $cmdline[22]
            ;set after reading time
            Case 1
                ControlSend($configWindowTitle,"",5237,$cmdline[21])
                Sleep(50)
            ;set after day hr/min
            Case 2
                ControlSend($configWindowTitle,"",5239,$cmdline[22])
                Sleep(50)
                ControlSend($configWindowTitle,"",5241,$cmdline[23])
                Sleep(50)
            ;set log at precise time
            Case 3
                $day = $cmdline[24]
                If StringInStr($day, "上") Then
                    ControlSend($configWindowTitle,"",5242,$day)
                    For $i = 1 To 2
                        ControlSend("Program and Configure","",5232,"{left}")
                        Sleep(50)
                    Next
                    ControlSend($configWindowTitle,"",5242,"上")
                Else
                    ControlSend($configWindowTitle,"",5242,$day)
                    For $i = 1 To 2
                        ControlSend("Program and Configure","",5242,"{left}")
                        Sleep(50)
                    Next
                    ControlSend($configWindowTitle,"",5242,"下")
                EndIf
            Case 4
                ControlClick($configWindowTitle,"",5236)
            Case Else
                ConsoleWrite("Can't find " & $configWindowTitle & "window"& @CRLF)
        EndSwitch
    Else
        ConsoleWrite("Can't find " & $windowTitle & "window"& @CRLF)
        CloseAppWindows($windowTitle)
        Exit
    EndIf

    ;enable beeper in logger
    If $cmdline[25] = "F" Then ControlClick($configWindowTitle,"",5243)
    If $cmdline[26] = "T" Then ControlClick($configWindowTitle,"",5245)

    ;programing
    If WinExists($configWindowTitle) Then
        ControlClick($configWindowTitle,"",$buttonid)
        ControlClick($configWindowTitle,"",$buttonid)
    Else
        ConsoleWrite("Can't find " & $windowTitle & "window"& @CRLF)
        CloseAppWindows($windowTitle)
        Exit
    EndIf
Else
	ConsoleWrite("Can't find " & $windowTitle & "window"& @CRLF)
    CloseAppWindows($windowTitle)
    Exit
EndIf

Func CloseAppWindows($appWindowTitle)
    ; 获取当前所有窗口的列表
    Local $aWinList = WinList()

    ; 遍历窗口列表，关闭属于目标应用程序的所有窗口
    For $i = 1 To $aWinList[0][0]
        If StringInStr(WinGetTitle($aWinList[$i][1]), $appWindowTitle) Then
            WinClose($aWinList[$i][1])
        EndIf
    Next
EndFunc

;how to use exe cmdline
#cs 
    configuration.exe
    description
    mintemper
    maxtemper
    increment
    AlChoose*7 EX~ T F T F T T T
    Aloutofspec1
    Aloutofspec2
    Duration
    readintervalday
    read interval hr min sec  EX~ 14h32m52s
    startlogchoose EX~ 1
    wait time hr min EX~ 2h23m
    in days
    in hr min EX~ 23h4m
    at time EX~ "2045/3/4 上 2h3m23s"
    finishlogchoose
    after ... reading
    after days
    after hr min EX~ 23h4m
    at time EX~ "2045/3/4 上 2h3m23s"
    continuous to log EX~ "T"
    enable beep EX~ "T
    new battery fitted EX~ "T
#ce