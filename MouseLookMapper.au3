#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Jeff Gaydos

 Script Function:
	This script has the complex task of calibrating the look movement.
	Basically, we need a point in which we know we can start our click
	and move our mouse around without touching any of the other
	controls in the game. We calibrate this by using a busy wait that can
	detect the down state of the mouse
	
	Why calibrate? Well because I have a lot of different layouts that I
	could see myself using on different screens, and I don't want to have
	to go back in here and recalibrate everything. Plus, this makes it
	quite extensible to other games if you want to add mappings to
	different touch screen buttons (game dependent).
	
	To this end, we could use a config file to help users remember which
	actions they are calibrating to which inputs, but for now we hard-code
	it in.
	
	See https://www.autoitscript.com/forum/topic/8982-detect-mouse-click/ for button codes...

#ce ----------------------------------------------------------------------------
#Include <WinAPI.au3> ;for mouse settings changes...

; internal locals
Local $TitlePrefix = "Calibration Setup"
Local $BaseTime = 1000
Local $IterationTimeout = 15
Local $TimeoutMessage = "Calibration Timedout. Please Restart this application."
Local $I = 0
Local $Valid = False
Local $Step = 0
Local $StepMax = 12
Local $CurrentSensitivity = RegRead("HKCU\Control Panel\Mouse", "MouseSensitivity")

; game-related locals
;Points of importance
Local $P_Center
Local $P_PowerBeam
Local $P_Missiles
Local $P_Special
Local $P_SpecialSelection
Local $P_AltForm
Local $P_ScanVisor
Local $P_UR
Local $P_LL
Local $P_Left
Local $P_Ok
Local $P_Right

; NOT an event based system, requires busy wait
Func _IsPressed($HexKey)
   Local $AR
   $HexKey = '0x' & $HexKey
   $AR = DllCall("user32","int","GetAsyncKeyState","int",$HexKey)
   If NOT @Error And BitAND($AR[0],0x8000) = 0x8000 Then Return 1
   Return 0
EndFunc

Func _Title()
	Return $TitlePrefix & " (" & $Step & "/" & $StepMax & ")"
EndFunc

; Returns true if mouse input was found, false if we timedout
Func _WaitForMouseInput()
	$I = 0
	While (Not _IsPressed('01')) AND ($I < $IterationTimeout)
		Sleep($BaseTime)
		$I = $I + 1
	WEnd
	Return $I < $IterationTimeout
EndFunc

; STEP 1: Find the central point to "lock" the cursor to
$Step = $Step + 1

MsgBox(0, _Title(), "Please Move your cursor to the most central part of the touchpad, and click and hold for (tops) 1 second until you see a sucess prompt.")

If _WaitForMouseInput() Then
	$P_Center = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 2: Find the upper right point of the touchpad
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the upper right corner of the touch screen.")

If _WaitForMouseInput() Then
	$P_UR = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 3: Find the bottom left point of the touchpad
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the lower left corner of the touch screen.")

If _WaitForMouseInput() Then
	$P_LL = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 4 Map PowerBeam
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the position of the power beam.")

If _WaitForMouseInput() Then
	$P_PowerBeam = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 5 Map Missiles
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the position of the missles.")

If _WaitForMouseInput() Then
	$P_Missiles = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 6 Map Special Weapon
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the position of the special weapon slot.")

If _WaitForMouseInput() Then
	$P_Special = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 7 Map Special Selection
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the position of the special weapon selection button.")

If _WaitForMouseInput() Then
	$P_SpecialSelection = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 8 Map Scan Visor
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the position of the scan visor button.")

If _WaitForMouseInput() Then
	$P_ScanVisor = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 9 Map Alt Form
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the position of the alt form button (ball mode).")

If _WaitForMouseInput() Then
	$P_AltForm = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 10 Map Next Page
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the position of the 'next page' button during a scan")

If _WaitForMouseInput() Then
	$P_Right = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 11 Map Next Page
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the position of the 'previous page' button during a scan")

If _WaitForMouseInput() Then
	$P_Left = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

; STEP 12 Map Next Page
$Step = $Step + 1

MsgBox(0, _Title(), "Do the same, but for the position of the 'ok' button during a scan")

If _WaitForMouseInput() Then
	$P_Ok = MouseGetPos()
Else
	MsgBox(0, _Title(), $TimeoutMessage)
	Exit
EndIf

MsgBox(0, $TitlePrefix, "Calibration Successful! Prepare for demo!!")

MouseMove($P_Center[0], $P_Center[1], 0)
Sleep(100)
MouseMove($P_PowerBeam[0], $P_PowerBeam[1], 0)
Sleep(100)
MouseMove($P_Missiles[0], $P_Missiles[1], 0)
Sleep(100)
MouseMove($P_Special[0], $P_Special[1], 0)
Sleep(100)
MouseMove($P_SpecialSelection[0], $P_SpecialSelection[1], 0)
Sleep(100)
MouseMove($P_AltForm[0], $P_AltForm[1], 0)
Sleep(100)
MouseMove($P_ScanVisor[0], $P_ScanVisor[1], 0)
Sleep(100)
MouseMove($P_Left[0], $P_Left[1], 0)
Sleep(100)
MouseMove($P_Ok[0], $P_Ok[1], 0)
Sleep(100)
MouseMove($P_Right[0], $P_Right[1], 0)
Sleep(100)

; Now it's time to get funky...
;
; Here are some other keyboard mappings:
; Alt ('12') - Activate Alt form
; C ('43') - Activate scan visor
; 1 ('31') - Power Beam
; 2 ('32') - Missiles
; 3 ('33') - Special Weapon
; Tab ('09') - Special Weapon Selection (Also a good way to trigger re-centers)
; L ('4C') - Re-lock
; K ('4B') - terminate this process
; U ('55') - Unlock
; CTRL ('11') Activate Visor

Func _MoveAndClickHold($Point)
	MouseUp("primary")
	Sleep(25)
	MouseMove($Point[0], $Point[1], 0) ;Move to position
	Sleep(2)
	MouseDown("primary")
	Return 27 ;The total sleep time in this function...
EndFunc

MsgBox(0, $TitlePrefix, "!!IMPORTANT!! Only press OK once you are ready to play game. Your cursor will be locked to the points you previously entered. Press 'K' to temporarily unlock, and 'L' to relock your cursor, and press 'U' to completely kill this process (Note: this will require you to recalibrate the system next time you open it).")

$I = 0; always code with a timeout in place, just in case :)
Local $LockActive = True
Local $RecenterTime = 10
Local $MouseUpTime = 2 ;anything less than this could cause the cursor to not fully let go or not fully re-center before clicking down again (causing a jerk)

Local $PowerBeamHolding = False
Local $MissilesHolding = False
Local $SpecialHolding = False
Local $AltFormHolding = False
Local $InAltForm = False
Local $SpecialSelectionHolding = False
Local $ScanVisorHolding = False
Local $InScanVisor = False
Local $ScanVisorTimeout = 1000 ;1 sceond
Local $LeftHolding = False
Local $RightHolding = False
Local $OkHolding = False

Local $TEMP_LockTimeout = 1000

MouseMove($P_Center[0], $P_Center[1], 0) ;Move to position
Sleep($MouseUpTime)
MouseDown("primary")
Sleep($RecenterTime)

While (Not _IsPressed('4B')); AND ($I < $TEMP_LockTimeout)
		; ### UNLOCK (K) ###
		If _IsPressed('55') Then
			$LockActive = False
			MouseUp("primary")
			;MsgBox(0, $TitlePrefix, "Unlocked...")
			_WinAPI_SystemParametersInfo(113, 0, $CurrentSensitivity, 2) ; 113 = SPI_SETMOUSESPEED = 0x0071
		EndIf
		; ### LOCK (L) ###	
		If _IsPressed('4C') Then
			ku
			$LockActive = True
			$InAltForm = False ;We override it here as a failsafe (if the user spams alt) or if uses actually want to use the touch screen to move in alt mode
			;MsgBox(0, $TitlePrefix, "Re-Locked...")
		EndIf
		Sleep($RecenterTime)
		; ### Re-center mechanics (R) ###	
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
		
		; ### Alt Form (Alt) ###
		If Not $AltFormHolding AND _IsPressed('12') Then
			$AltFormHolding = True
			Sleep(25)
			_MoveAndClickHold($P_AltForm)
			$InAltForm = Not $InAltForm
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
		
		If Not $InAltForm Then
			; ### Power Beam (1) ###
			If Not $PowerBeamHolding AND _IsPressed('31') Then
				$PowerBeamHolding = True
				_MoveAndClickHold($P_PowerBeam)
			EndIf
			If $PowerBeamHolding AND Not _IsPressed('31') Then
				$PowerBeamHolding = False
				;Sleep(25)
				;_MoveAndClickHold($P_Center)
			EndIf
			
			; ### Missiles (2) ###
			If Not $MissilesHolding AND _IsPressed('32') Then
				$MissilesHolding = True
				_MoveAndClickHold($P_Missiles)
			EndIf
			If $MissilesHolding AND Not _IsPressed('32') Then
				$MissilesHolding = False
				;Sleep(25)
				;_MoveAndClickHold($P_Center)
			EndIf
			
			; ### Special Weapon (3) ###
			If Not $SpecialHolding AND _IsPressed('33') Then
				$SpecialHolding = True
				_MoveAndClickHold($P_Special)
			EndIf
			If $SpecialHolding AND Not _IsPressed('33') Then
				$SpecialHolding = False
				;Sleep(25)
				;_MoveAndClickHold($P_Center)
			EndIf
			
			; ### Special Weapon Selection (Tab) ###
			If Not $SpecialSelectionHolding AND _IsPressed('09') Then
				$SpecialSelectionHolding = True
				_MoveAndClickHold($P_SpecialSelection)
			EndIf
			If $SpecialSelectionHolding AND Not _IsPressed('09') Then
				$SpecialSelectionHolding = False
				Sleep(25)
				_MoveAndClickHold($P_Center)
				_WinAPI_SystemParametersInfo(113, 0, $CurrentSensitivity, 2) ; 113 = SPI_SETMOUSESPEED = 0x0071
			EndIf
			
			; ### Activate Scan Visor (CTRL) ###
			If Not $ScanVisorHolding AND _IsPressed('11') Then
				$ScanVisorHolding = True
				_MoveAndClickHold($P_ScanVisor)
			EndIf
			If $ScanVisorHolding AND Not _IsPressed('11') Then
				$ScanVisorHolding = False
				;Sleep(251)
				;_MoveAndClickHold($P_Center)
			EndIf
			
			; ### Left on scan (Q) ###
			If Not $LeftHolding AND _IsPressed('51') Then
				$LeftHolding = True
				_MoveAndClickHold($P_Left)
			EndIf
			If $LeftHolding AND Not _IsPressed('51') Then
				$LeftHolding = False
				MouseUp("primary")
			EndIf
			
			; ### Right on scan (E) ###
			If Not $RightHolding AND _IsPressed('45') Then
				$RightHolding = True
				_MoveAndClickHold($P_Right)
			EndIf
			If $RightHolding AND Not _IsPressed('45') Then
				$RightHolding = False
				MouseUp("primary")
			EndIf
			
			; ### OK on scan (Q & E) ###
			If Not $OkHolding AND _IsPressed('51') AND _IsPressed('45') Then
				$OkHolding = True
				_MoveAndClickHold($P_Ok)
			EndIf
			If $OkHolding AND (Not _IsPressed('51') OR Not _IsPressed('45')) Then
				$OkHolding = False
				; We don't need to recent (we are already pretty close) but we do want to hold so we can go right back to looking around)
			EndIf
		EndIf
		
		;$I = $I + 1
WEnd
	
MouseUp("primary")

MsgBox(0, $TitlePrefix, "Exiting...")

