#Include <WinAPI.au3> ;for mouse settings changes...

;process specific locals
Local $MsgTitle = "l_recenter.au3"

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

Func _handleTCPUpdates($Socket, $ClientSocket)
	If @error Then
		Local $Error = @error
		MsgBox(0, "TCP", "Server could not accept the incoming connection. Error: " & $Error & @CRLF & _WinAPI_GetErrorMessage($Error))
		Exit
	EndIf
	TCPCloseSocket($Socket) ;done listenning for now

	; we assume that the client process knows what we are expecting...
	Local $Payload = TCPRecv($ClientSocket, 100)
	Local $Function = StringSplit(BinaryToString($Payload), '|', 3) ; Name, Argument (only 1)
	Local $Args[2]
	$Args[0] = "CallArgArray"
	$Args[1] = $Function[1]
	Call($Function[0], $Args)
	TCPSend($ClientSocket, $InAltForm)
	If @error = 0xDEAD And @extended Then
		MsgBox(0, $MsgTitle, "Could not update variable. Recieved " & $Payload & " or " & BinaryToString($Payload))
		Exit
	EndIf
	TCPCloseSocket($ClientSocket)	
EndFunc

;ServerData
Local $InAltForm = False
Local $LockActive = False

;Set ServerData
Func InAltForm($new)
	If $new = 'True' Or $new = '1' Then ; we can't use !!$new here because $new is a string, and all non-empty strings are true of course
		$InAltForm = True
	Else
		$InAltForm = False
	EndIf
	Return $InAltForm
EndFunc

Func LockActive($new)
	If $new = 'True' Or $new = '1' Then ; we can't use !!$new here because $new is a string, and all non-empty strings are true of course
		$LockActive = True
	Else
		$LockActive = False
	EndIf
	Return $LockActive
EndFunc

; game & calibration configs
Local $P_LL[2]
$P_LL[0] = _getConfig(FileRead("settings.ini", -1), "p_ll_0")
$P_LL[1]= _getConfig(FileRead("settings.ini", -1), "p_ll_1")
Local $P_UR[2]
$P_UR[0] = _getConfig(FileRead("settings.ini", -1), "p_ur_0")
$P_UR[1] = _getConfig(FileRead("settings.ini", -1), "p_ur_1")
Local $P_Center[2]
$P_Center[0] = _getConfig(FileRead("settings.ini", -1), "p_center_0")
$P_Center[1] = _getConfig(FileRead("settings.ini", -1), "p_center_1")
Local $K_key = '4B'
Local $U_key = '55'
Local $SleepMin = 10
Local $MouseUpTime = 2 ;anything less than this could cause the cursor to not fully let go or not fully re-center before clicking down again (causing a jerk)

;TCP Config
TCPStartup()
OnAutoItExitRegister("OnExit")

Local $IP = "127.0.0.1"
Local $Port = 65432 ;you may need to change this depending on what ports the rest of your computer is using
Local $MaxConn = 100

While (Not _IsPressed($K_key))
	;TCP Stuff
	Local $Socket = TCPListen($IP, $Port, $MaxConn)
	If @error Then
		Local $Error = @error
		MsgBox(0, $MsgTitle, "Server Failed to listen... The server may already be running. Error: " & $Error & @CRLF & _WinAPI_GetErrorMessage($Error))
		Exit
	EndIf	

	Local $ClientSocket = -1;
	Do
		If _IsPressed($K_key) Then
			Exit ;kill process with the rest of the loops...
		EndIf
		
		; ### Re-center mechanics ###	
		If (Not $InAltForm AND $LockActive) Then
			Local $MP = MouseGetPos()
			; if needed, make the assumption that the user will continue to move in the direction they were
			; set the cursor closer to the opposite side of the edge that caused a recenter...
			If ($MP[0] < $P_LL[0]) OR ($MP[0] > $P_UR[0]) OR ($MP[1] > $P_LL[1]) OR ($MP[1] < $P_UR[1]) Then
				MouseUp("primary")
				Sleep($MouseUpTime)
				MouseMove($P_Center[0], $P_Center[1], 0) ;Move to position
				Sleep($MouseUpTime)
				MouseDown("primary")
			EndIf
		EndIf
	
		; anyone asking for an update
		$ClientSocket = TCPAccept($Socket)	
		Sleep($SleepMin)
	Until $ClientSocket <> -1 And Not _IsPressed($K_key)
	
	_handleTCPUpdates($Socket, $ClientSocket)
WEnd

Func OnExit()
	TCPShutdown()
	MsgBox(0, $MsgTitle, "exited successfully");
EndFunc