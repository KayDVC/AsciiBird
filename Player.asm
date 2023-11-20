Include AsciiBird.inc

.data
PLAYER EQU <"^">
curr_pos Coords <LEFT_LIMIT+1, TOP_LIMIT+1>	; matching to start
new_pos Coords <LEFT_LIMIT+1, TOP_LIMIT+1>

.code

;------------------Private Procedures--------------------------------

DrawPlayer PROC USES eax 
;
; Redraws player avatar in new location.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Irvine Lib.
; Note: Checks obstacle intersection before drawing.
;---------------------------------------------------------

.data
    BLANK_SYMBOL EQU <" ">
.code
	
	; verify player not hitting obastacle.
	mov esi, OFFSET new_pos
	call CheckIntersection
	cmp eax, FALSE
	je Draw

	; player went successfully went "through" obstacle
	call UpdateScore


	Draw:
		; clear and redraw player.
		mReplaceChar OFFSET curr_pos, OFFSET new_pos, PLAYER

		; update player location tracker.
		mov al, new_pos.y
		mov curr_pos.y, al

	ret

DrawPlayer ENDP

;---------------------------------------------------------
PlayerJump PROC USES eax esi ecx edx
;
; Applies "Jumping" effect to player avatar, moving
; it upward.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------
	
	; save x coord. This really doesn't change.
	mov al, curr_pos.x
	mov new_pos.x, al

	; implement "jump" over three consecutive frames
	; to give smooth effect and prevent the need to spam
	; jump.
	mov ecx, 03h
	JumpLoop:
		
		; calculate new position after single frame of jump animation.
		mov al, curr_pos.y
		sub al, 01h

		; determine if player will hit top border (cancel "jump" if so).
		cmp al, top_border_start.y
		jbe Quit

		mov new_pos.y, al

		; update player on screen.
		call DrawPlayer
		loop JumpLoop

	Quit:
		ret

PlayerJump ENDP


;---------------------------------------------------------
PlayerFall PROC USES eax esi edx
;
; Applies "Gravity" effect to player avatar, moving
; it downward.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------
	
	; calculate new height
	mov al, curr_pos.y
	add al, 01h

	; determine if player will hit bottom border (end game if so).
	cmp al, bottom_border_start.y
	jae EndGame

	mov new_pos.y, al

	; update player on screen.
	call DrawPlayer
	ret

	EndGame:
		call GameOver 

PlayerFall ENDP

;------------------Public Procedures---------------------------------

MovePlayer PROC PUBLIC
;
; Moves the player avatar based on input.
;
; Receives: AL - the input from the console.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------
.data
	UP EQU " "
	EXIT EQU <"q">

.code
	
	; make player jump.
	cmp al, UP
	je Jump

	; quit game.
	cmp al, EXIT
	je QuitGame

	; make player fall.
	Fall:
		call PlayerFall
		ret

	Jump:
		call PlayerJump
		ret
	
	QuitGame:
		call GameOver
		ret
		
MovePlayer ENDP

;---------------------------------------------------------
SetupPlayer PROC PUBLIC USES edx eax
;
; Draws the player in initial position.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------
	
	; set cursor position.
	mov dh, new_pos.y
	mov dl, new_pos.x
	call GoToXY

	; draw avatar.
	mov al, PLAYER
	call WriteChar

	ret

SetupPlayer ENDP

END