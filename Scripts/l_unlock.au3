#Include <WinAPI.au3> ;for mouse settings changes...

Local $K_key = '4B'
Local $U_key = '55'
Local $SleepMin = 10

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
		$LockActive = False
		MouseUp("primary")
		;MsgBox(0, $TitlePrefix, "Unlocked...")
		_WinAPI_SystemParametersInfo(113, 0, $CurrentSensitivity, 2) ; 113 = SPI_SETMOUSESPEED = 0x0071
	EndIf
	Sleep($SleepMin)
WEnd

MsgBox(0, "l_unlock", "exited successfully");