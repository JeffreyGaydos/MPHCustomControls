#Include <WinAPI.au3> ;for mouse settings changes...

Local $L_key = '4C'
Local $K_key = '4B'
Local $SleepMin = 10
Local $MsgTitle = "l_lock.au3"

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

While (Not _IsPressed($K_key))
	; ### LOCK (L) ###	
	If _IsPressed($L_Key) Then
		$Socket = TCPConnect($IP, $Port)
		
		If @error Then
			Local $Error = @error
			MsgBox(0, $MsgTitle, "TCP: Client could not connect. Error: " & $Error & @CRLF & _WinAPI_GetErrorMessage($Error))
			Exit
		EndIf
		
		TCPSend($Socket, StringToBinary('LockActive|1')) 
		TCPRecv($Socket, 100) ;even though we don't use it, we need to verify that the server made the updates
		TCPSend($Socket, StringToBinary('InAltForm|0')) 
		TCPRecv($Socket, 100)
		
		TCPCloseSocket($Socket)
	EndIf
	Sleep($SleepMin)
WEnd

Func OnExit()
	TCPShutdown()
	MsgBox(0, "l_lock", "exited successfully");
EndFunc