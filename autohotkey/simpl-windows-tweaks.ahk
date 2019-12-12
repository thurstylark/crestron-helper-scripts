; === SIMPL Windows Tweaks ===
;
; Some small additions to the keyboard functionality in SIMPL Windows.
;
;
; == Running ==
;
; In its uncompiled form, you will need to install AutoHotKey, and then run this script as an administrator.
;   This is because an unpriviliged process is not allowed to send input to priviliged windows, and SIMPL 
;   Windows insists on being run as an administrator.
;
; This script will now run minimized, and can be stopped through its tray icon.
;
; This script's usability is restricted to SIMPL Windows, and will not affect any other application 
;   while it's running.
;
; I have plans on making this a "wrapper" for SIMPL Windows, so that the script doesn't need to run any 
;   longer than it absolutely needs to, but that's a little ways down the line.
;
;
; == Functions ==
;
; | Key Combo 		| Function 			| Context 			| Masks existing?		|
; |---------------------|-------------------------------|-------------------------------|-------------------------------|
; | Ctrl + W  		| Close active symbol detail 	| SIMPL Windows 		| Yes: program mode switch	|
; | Ctrl + Shift + W 	| Close all symbol details 	| SIMPL Windows			| No 				|
; | Enter (or Return) 	| Open symbol detail view 	| Program View pane		| No (WIP, disabled)		|
; | Space 		| Open symbol detail view 	| Program View pane	 	| No (WIP, disabled)		|
; | Alt + Shift + R	| Add square brackets to signal	| SIMPL Windows			| No 				|
;


; Begin Boilerplate

;#include paris-functions.ahk				; A function helper script so I don't have to write them 
#NoEnv							; Recommended for performance and compatibility 
							;   with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
SendMode Input						; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% 				; Ensures a consistent starting directory.

#SingleInstance force					; Only let one copy of this script run at a time without 
							;   bugging the user with pop-up boxes.
CoordMode, Mouse, Client				; Use Client-relative positions for all mouse-related coordinates

; End Boilerplate



; Tweak these values to adjust the position of the auto click.
CloseAllButtonX := 705					; X position of the "Close All Symbol Details" button, relative to Client
CloseAllButtonY := 17					; Y position of the "Close All Symbol Details" button, relative to Client
; These values can be found using the Window Spy tool.



#IfWinActive ahk_exe smpwin.exe 			; Only let these configurations work when SIMPL Windows is in the foreground.


^w::							; Ctrl+W - Close Active Symbol Detail
	Send ^{F4}					; Send Ctrl+F4 (close symbol detail)
Return							; GTFO


^+w::							; Ctrl+Shift+W - Close All Symbol Details
	MouseGetPos, StartX, StartY			; Store the current mouse position
	MouseMove, CloseAllButtonX, CloseAllButtonY	; Move the mouse to the button
	Click						; Do the click
	Sleep, 10					; For some reason, just doing the click is too 
							;   fast for SIMPL Windows -_-
	MouseMove, StartX, StartY			; Move the mouse back where it was
Return							; GTFO

!+R::
	Send !R
	Send {Home}
	Send [
	Send {End}
	Send ]
	Send {Enter}
Return


;#If ControlGetFocus() = "SysTreeFiew322"
;Space::							; Space (when focussed on Program View pane) - Open symbol detail view
;Enter::							; Enter/Return (when focussed on Program View pane) - Open symbol detail view
;	Sleep, 100
;	ControlSend, SysTreeView322, ^d		; Send Ctrl+D (Open Detail View) to the target control (read: pane)
;	ControlGetFocus, CurrentFocus			; Put information about the currently-focussed pane in the variable CurrentFocus
;	if (CurrentFocus = "SysTreeView322")		; Check the variable for the right ClassNN (retrieved using Window Spy)
;	{
;		Sleep, 100
;		ControlSend, SysTreeView322, ^d		; Send Ctrl+D (Open Detail View) to the target control (read: pane)
;	}
Return							; GTFO
	
