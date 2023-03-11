#Include <WinAPI.au3> ;for mouse settings changes...

Local $K_key = '4B'
Local $U_key = '55'
Local $SleepMin = 10

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
		MsgBox(0, "Error", "Internal Error: key not found in settings.ini")
	EndIf
EndFunc

Local $CurrentSensitivity = _getConfig(FileRead("settings.ini", -1), "sen_orig")

While (Not _IsPressed($K_key))
	; ### UNLOCK (U) ###
	If _IsPressed($U_Key) Then
		$Socket = TCPConnect($IP, $Port)

		If @error Then
			Local $Error = @error
			MsgBox(0, $MsgTitle, "TCP: Client could not connect. Error: " & $Error & @CRLF & _WinAPI_GetErrorMessage($Error))
			Exit
		EndIf
		
		TCPSend($Socket, StringToBinary('LockActive|0')) 
		TCPRecv($Socket, 100) ;even though we don't use it, we need to verify that the server made the updates
		
		TCPCloseSocket($Socket)

		MouseUp("primary")
		;MsgBox(0, $TitlePrefix, "Unlocked...")
		_WinAPI_SystemParametersInfo(113, 0, $CurrentSensitivity, 2) ; 113 = SPI_SETMOUSESPEED = 0x0071
	EndIf
	Sleep($SleepMin)
WEnd

Func OnExit()
	TCPShutdown()
	MsgBox(0, "l_unlock", "exited successfully");
EndFunc