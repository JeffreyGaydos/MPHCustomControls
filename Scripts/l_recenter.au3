#Include <WinAPI.au3> ;for mouse settings changes...

Local $MsgTitle = "l_recenter.au3"
; ==============================================================
; TCP related code. Necessary to get data from 1 process to another quickly
; This code mostly copied form AutoIt's docs: https://www.autoitscript.com/autoit3/docs/functions/TCPConnect.htm
; ==============================================================
TCPStartup()
OnAutoItExitRegister("OnExit")

Local $IP = "127.0.0.1"
Local $Port = 65432 ;you may need to change this depending on what ports the rest of your computer is using
Local $Socket = TCPConnect($IP, $Port)
TCPCloseSocket($Socket)
Local $Socket = TCPConnect($IP, $Port)
If @error Then
	Local $Error = @error
	MsgBox(0, $MsgTitle, "TCP: Client could not connect. Error: " & $Error & @CRLF & _WinAPI_GetErrorMessage($Error))
	Exit
EndIf

TCPSend($Socket, StringToBinary('InAltForm'))
;TCPSend($Socket, StringToBinary('InAltForm|0')) 
;MsgBox(0, $MsgTitle, "Sent 'InAltForm' to server")
Local $Response = TCPRecv($Socket, 100)
MsgBox(0, $MsgTitle, "Server responded: " & StringToBinary($Response) & " or... " & $Response)
If $Response = Binary('0x01') Then
	MsgBox(0, $MsgTitle, "interpreted as true")
Else
	MsgBox(0, $MsgTitle, "interpreted as false")
EndIf
TCPCloseSocket($Socket)

Func OnExit()
	TCPShutdown()
EndFunc

Func _SendSRVRequest($RequestString)
	Local $Socket = TCPConnect($IP, $Port)

	If @error Then
		Local $Error = @error
		MsgBox(0, $MsgTitle, "TCP: Client could not connect. Error: " & $Error & @CRLF & _WinAPI_GetErrorMessage($Error))
		Exit
	EndIf
	
	TCPSend($Socket, StringToBinary($RequestString))
	Local $Response = TCPRecv($Socket, 100)
	TCPCloseSocket($Socket)
	
	If $Response = Binary('0x01') Then
		Return True
	Else
		Return False
	EndIf
EndFunc
; ==============================================================
Exit
;ServerData
Local $IsAltForm = False

Local $K_key = '4B'
Local $U_key = '55'
Local $SleepMin = 10
Local $MouseUpTime = 2 ;anything less than this could cause the cursor to not fully let go or not fully re-center before clicking down again (causing a jerk)

Func _IsPressed($HexKey)
   Local $AR
   $HexKey = '0x' & $HexKey
   $AR = DllCall("user32","int","GetAsyncKeyState","int",$HexKey)
   If NOT @Error And BitAND($AR[0],0x8000) = 0x8000 Then Return 1
   Return 0
EndFunc

Func _getConfig($rawFile, $itemString)
	If StringInStr($rawFile, $itemString) Then
		For $line In StringSplit($rawFile, @CRLF, 3)
			$key = StringSplit($line, " = ", 3)[0]
			$value = StringSplit($line, " = ", 3)[1]
			If StringCompare($key, $itemString) Then
				Return $value
			EndIf
		Next
	Else
		MsgBox(0, $MsgTitle, "Internal Error: key not found in settings.ini")
	EndIf
EndFunc

Local $InAltForm = _getConfig(FileRead("settings.ini", -1), "inaltform")
Local $P_LL[2]
$P_LL[0] = _getConfig(FileRead("settings.ini", -1), "p_ll_0")
$P_LL[1]= _getConfig(FileRead("settings.ini", -1), "p_ll_1")
Local $P_UR[2]
$P_UR[0] = _getConfig(FileRead("settings.ini", -1), "p_ur_0")
$P_UR[1] = _getConfig(FileRead("settings.ini", -1), "p_ur_1")
Local $P_Center[2]
$P_Center[0] = _getConfig(FileRead("settings.ini", -1), "p_center_0")
$P_Center[1] = _getConfig(FileRead("settings.ini", -1), "p_center_1")
Local $LockActive = _getConfig(FileRead("settings.ini", -1), "lockactive")

While (Not _IsPressed($K_key))
	; ### Re-center mechanics ###	
	If (Not $InAltForm AND $LockActive) Then
		Local $MP = MouseGetPos()
		; I'm thinking if you go off the left side of the screen, maybe put the cursor closer to the right side? or make an AI to minimize the stuttering haha
		If ($MP[0] < $P_LL[0]) OR ($MP[0] > $P_UR[0]) OR ($MP[1] > $P_LL[1]) OR ($MP[1] < $P_UR[1]) Then
			MouseUp("primary")
			Sleep($MouseUpTime)
			MouseMove($P_Center[0], $P_Center[1], 0) ;Move to position
			Sleep($MouseUpTime)
			MouseDown("primary")
		EndIf
	EndIf
	Sleep($SleepMin)
WEnd

MsgBox(0, $MsgTitle, "exited successfully");