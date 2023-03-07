#Include <WinAPI.au3> ;for mouse settings changes...

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
		MsgBox(0, "Error", "Internal Error: key not found in settings.ini")
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

MsgBox(0, "l_recenter", "exited successfully");