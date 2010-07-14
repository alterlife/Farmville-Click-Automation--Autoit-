;
; Farmville Click automation:
;      A simple tool to reduce the overhead of farm maintenance.
;
; (c) 2010, Jeevan John (jeevan@alterlife.org)
; 
; This code is Open source under the GNU GPL Version 2
;

#include <ImageSearch.au3>
#Include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#Include <ScreenCapture.au3>

HotKeySet("{ESC}", "Terminate")
TraySetIcon("tray.ico")

$message = "Please wait..."

Func Terminate()
	if FileExists("capture.bmp") Then
		$message = "The action has been interrupted."
	Else
		If MsgBox(4, "Exit Clickbot?", "Would you like to exit ClickBot?") = 6 Then
			Exit
		EndIf
	EndIf
	FileDelete("capture.bmp")
EndFunc


Func Main()

	; Init
	$status = "Starting up!"
	$x1=0
	$y1=0
	$oldx1=0
	$oldy1=0
	$repeat = 0
	
	; cleanup just incase.
	FileDelete("capture.bmp")
	
	; main event loop.
	While True
		ToolTip($message, 200, 0, "Farmville Click automation is " & $status)
		
		if not StringInStr ( WinGetTitle(""), "FarmVille") and not StringInStr ( WinGetTitle(""), "Adobe Flash Player") Then
			$status ="Inactive." & WinGetTitle("")
			$message = "Please switch to a farmville window."
			Sleep(300)
			ContinueLoop
		EndIf

		if FileExists("capture.bmp") Then
			$status = "Working!"
		Else
			$status ="Idle."
		EndIf
		
		
		$pos = MouseGetPos()
	
		; If middle button was clicked. Capture the tile under the mouse.
		If _IsPressed(04) Then
			$message = "Taking orders!"
			$pos = MouseGetPos()
			MouseMove(0,0)
		
			FileDelete("capture.bmp")
			_ScreenCapture_Capture("capture.bmp", $pos[0] - 4, $pos[1] - 4, $pos[0] + 4, $pos[1] + 4, false)
			MouseMove($pos[0],$pos[1],1)
		EndIf
	
		; If a captured tile exists, trigger a image search.
		If FileExists("capture.bmp") and _ImageSearch("capture.bmp",1,$x1,$y1,30) Then
			$message = "Working hard!"
			MouseMove($x1,$y1, 1)
			MouseClick("left")
			sleep(100)
		
			; If a click didn't do anything to the tile
			If $oldx1 == $x1 and $oldy1 == $y1 Then	
				
				$repeat = $repeat + 1
				sleep(300)
				
				if $repeat == 2 Then	; if no match on second try, move the mouse out of the way.
				MouseMove(0,0)
			EndIf
		
			if $repeat == 3 Then	; retry 3 times before failing.
				$repeat = 0
				FileDelete("capture.bmp")
				MsgBox(0, "Clickbot", "I tried thrice, but clicking there does nothing.")
				EndIf
				else
				$repeat = 0
			EndIf
		
			$oldx1 = $x1
			$oldy1 = $y1
			
			if not _ImageSearch("capture.bmp",1,$x1,$y1,30) Then ; If I can't find another tile to click on,
				MouseMove($x1 - 300,$y1 - 300)	; Move the mouse out of the way incase it's interfering with pixelsearch.
			EndIf
		Else
			sleep(300)
			FileDelete("capture.bmp")
			$message = "Waiting for orders! Middle click on a tile needing harvest / ploughing. Hit escape to exit."
		EndIf
	
		sleep(20)
	WEnd
	
	; cleanup
	FileDelete("capture.bmp")
EndFunc

Main()
