#Include <WinAPI.au3> ;for mouse settings changes...

Local $L_key = '4C'
Local $K_key = '4B'
Local $_InAltForm = False
Local $AltFormHolding = False
Local $SleepMin = 10
Local $MsgTitle = "l_alt_form.au3"

TCPStartup()
OnAutoItExitRegister("OnExit")

Local $IP = "127.0.0.1"
Local $Port = 65432 ;you may need to change this depending on what ports the rest of your computer is using
Local $Socket

Func _IsPressed($HexKey)
   Local $AR
   $HexKey = '0x' & $HexKey
   $AR = DllCall("user32","int","GetAsyncKeyState","int",$HexKey)
   If NOT @Error And BitAND($AR[0],0x8000) = 0x8000 Then Return 1
   Return 0
EndFunc

Func _TCPSendInAltForm($Value)
	$Socket = TCPConnect($IP, $Port)
		
	If @error Then
		Local $Error = @error
		MsgBox(0, $MsgTitle, "TCP: Client could not connect. Error: " & $Error & @CRLF & _WinAPI_GetErrorMessage($Error))
		Exit
	EndIf
	
	TCPSend($Socket, StringToBinary('InAltForm|' & $Value)) 
	Local $Response = TCPRecv($Socket, 100)
	If $Response = Binary('0x01') Then
		$_InAltForm = True
	Else
		$_InAltForm = False
	EndIf
	
	TCPCloseSocket($Socket)
EndFunc

Local $P_Center[2]
$P_Center[0] = _getConfig(FileRead("settings.ini", -1), "p_center_0")
$P_Center[1] = _getConfig(FileRead("settings.ini", -1), "p_center_1")
Local $P_AltForm[2]
$P_AltForm[0] = _getConfig(FileRead("settings.ini", -1), "p_alt_form_0")
$P_AltForm[1] = _getConfig(FileRead("settings.ini", -1), "p_alt_form_1")

While (Not _IsPressed($K_key))
	; ### Alt Form (Alt) ###
	If Not $AltFormHolding AND _IsPressed('12') Then
		$AltFormHolding = True
		Sleep(25)
		_MoveAndClickHold($P_AltForm)
		If $_InAltForm Then
			_TCPSendInAltForm(0)
		Else
			_TCPSendInAltForm(1)
		EndIf
			
		If Not $InAltForm Then
			Sleep(25)
			_MoveAndClickHold($P_Center)
		Else
			Sleep(25)
			MouseUp("primary")
		EndIf
	EndIf
	If $AltFormHolding AND Not _IsPressed('12') Then
		$AltFormHolding = False
	EndIf
	Sleep($SleepMin)
WEnd

Func OnExit()
	TCPShutdown()
	MsgBox(0, $MsgTitle, "exited successfully");
EndFunc