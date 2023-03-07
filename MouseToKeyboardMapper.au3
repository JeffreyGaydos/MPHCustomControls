#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Jeff Gaydos

 Script Function:
	This script is primarily intended to map the primary mouse click to the
	fire key (whatever that may be in MelonDS). Hold the escape key to
	stop this process.
		See https://www.autoitscript.com/forum/topic/8982-detect-mouse-click/ if you want to change the cancel key...
	
	Since the left mouse button is required to look around, you will have
	to use Windows settings to first swap the action of your right/left
	mouse buttons
		Control Pannel >
			Hardware and Sound >
				(Devices and Printers) Mouse >
					(Buttons) [Button configuration] Switch primary and secondary buttons
		
	MelonDS will pick up on this and make the "tap" action the right click
	button, freeing up the left click button to be mapped to a fire key!
	
	NOTE: Key code '01' is the left mouse button, regardless of which
	button Windows thinks the primary button is.
	
	Current Fire Key: 't'

#ce ----------------------------------------------------------------------------
#Include <WinAPI.au3> ;for mouse settings changes...

Local $BaseTime = 100 ;Based on testing, this is an unnoticable delay, but could be decreased if it becomes noticable
Local $IterationTimeout = 150
Local $I = 0
Local $Valid = False
Local $Title = "MouseToKeyboardMapper.au3"

Func _IsPressed($HexKey)
   Local $AR
   $HexKey = '0x' & $HexKey
   $AR = DllCall("user32","int","GetAsyncKeyState","int",$HexKey)
   If NOT @Error And BitAND($AR[0],0x8000) = 0x8000 Then Return 1
   Return 0
EndFunc

MsgBox(0, $Title, "This script is primarily intended to map the primary mouse click to the fire key, but also changes some mouse settings related to firing so you don't have to. Don't worry, everything is reset upon exit. Hold the escape key to kill this process.")

; Sentitivity and Button changes...
Func _SetEmulationMouseSettings()
	_WinAPI_SystemParametersInfo(113, 0, $RequestedSensitivity, 2) ; 113 = SPI_SETMOUSESPEED = 0x0071	
	;DllCall("user32.dll", "int", "SwapMouseButton", "int", 0)
EndFunc

Func _UnsetEmulationMouseSettings()
	_WinAPI_SystemParametersInfo(113, 0, $CurrentSensitivity, 2) ; 113 = SPI_SETMOUSESPEED = 0x0071
	;DllCall("user32.dll", "int", "SwapMouseButton", "int", 1)
EndFunc

Local $RecommendedSensitivity = "4"
Local $CurrentSensitivity = RegRead("HKCU\Control Panel\Mouse", "MouseSensitivity")
$TitlePrefix = "Mouse Setup"
$Step = 1
MsgBox(0, $Title, "We recommend maxing the in-game sensitivity and lowering your system's, so as to minimize the number of times the system needs to recenter your mouse during gameplay. You can also increase the size of your emulator's bottom screen to help with this. We will revert these changes upon exit or during a temporary unlock (changes will be reapplied during re-lock).")
Local $RequestedSensitivity = InputBox($Title, "Your current cursor speed is set to " & $CurrentSensitivity & "... The recommended sensitivity is the value currently entered. Otherwise, enter a value from 1 to 20", $RecommendedSensitivity)
MsgBox(0, $Title, "Sensitivity will be changed to " & $RequestedSensitivity & " after setup. Settings will reset to upon exit hold the escape key.")
Run("control.exe main.cpl") ;open mouse settings
MsgBox(0, $Title, "This next part requires user intervention. I have openned the mouse settings, please swap the primary/secondary buttons. This way we can use the right click to simulate movement in the emulator, and left click is free to be used for firing. Click OK when you are done with that... Thanks!")
_SetEmulationMouseSettings()

While (Not _IsPressed('1B'));'1B' is the escape key's code. Hold esc to kill this process...
	If _IsPressed('01') Then
		Send("{T down}")
	Else
		Send("{T up}")
	EndIf
	Sleep($BaseTime)
WEnd
_UnsetEmulationMouseSettings()
MsgBox(0, "MouseToKeyboardMapper.au3", "Mouse > Keyboard mapper process was canceled by user. Mouse settings have been reset EXCEPT for the swapped buttons you set earlier in the control pannel.")