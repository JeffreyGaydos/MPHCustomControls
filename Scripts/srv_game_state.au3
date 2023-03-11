#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Jeff Gaydos

 Script Function:
	This script acts as the server for "live data" or data that needs to be
	updated in real time. The data gathered and distributed here is related
	to game state.

#ce ----------------------------------------------------------------------------
#Include <WinAPI.au3>

Global $InAltForm = False
Local $K_key = '4B'
Local $MsgTitle = 'srv.au3'

Func _IsPressed($HexKey)
   Local $AR
   $HexKey = '0x' & $HexKey
   $AR = DllCall("user32","int","GetAsyncKeyState","int",$HexKey)
   If NOT @Error And BitAND($AR[0],0x8000) = 0x8000 Then Return 1
   Return 0
EndFunc

Func InAltForm($new)
	If $new = 'True' Or $new = '1' Then ; we can't use !!$new here because $new is a string, and all non-empty strings are true of course
		$InAltForm = True
	Else
		$InAltForm = False
	EndIf
	Return $InAltForm
EndFunc

; TCP related code. Necessary to get data from 1 process to another quickly
; This code mostly copied form AutoIt's docs: https://www.autoitscript.com/autoit3/docs/functions/TCPListen.htm
TCPStartup()
OnAutoItExitRegister("OnExit")

Local $IP = "127.0.0.1"
Local $Port = 65432 ;you may need to change this depending on what ports the rest of your computer is using
Local $MaxConn = 100

While (Not _IsPressed($K_key))
	Local $Socket = TCPListen($IP, $Port, $MaxConn)
	If @error Then
		Local $Error = @error
		MsgBox(0, "TCP", "Server Failed to listen... The server may already be running. Error: " & $Error & @CRLF & _WinAPI_GetErrorMessage($Error))
		Exit
	EndIf	

	Local $ClientSocket = -1;
	Do
		If _IsPressed($K_key) Then
			Exit ;kill process with the rest of the loops...
		EndIf
		$ClientSocket = TCPAccept($Socket)
		If @error Then
			Local $Error = @error
			MsgBox(0, "TCP", "Server could not accept the incoming connection. Error: " & $Error & @CRLF & _WinAPI_GetErrorMessage($Error))
			Exit
		EndIf
	Until $ClientSocket <> -1;means a client has connected
	TCPCloseSocket($Socket) ;done listenning for now
	;MsgBox(0, "", "Srv found client")
	;return data to client
	Local $Payload = TCPRecv($ClientSocket, 100)
	If IsDeclared($Payload) Then
		TCPSend($ClientSocket, Eval($Payload))
	Else
		Local $Function = StringSplit(BinaryToString($Payload), '|', 3) ; Name, Argument (only 1)
		MsgBox(0, "", $PayLoad)
		Local $Args[2]
		$Args[0] = "CallArgArray"
		$Args[1] = $Function[1]
		Call($Function[0], $Args)
		TCPSend($ClientSocket, $InAltForm)
	EndIf
	If @error = 0xDEAD And @extended Then
		MsgBox(0, $MsgTitle, "Function or variable does not exist in server...")
		Exit
	EndIf
	TCPCloseSocket($ClientSocket)
WEnd

Func OnExit()
	TCPShutdown()
	MsgBox(0, $MsgTitle, "exited successfully");
EndFunc