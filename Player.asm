Include AsciiBird.inc

.data
PLAYER EQU <"^">
prev_pos Coords <LEFT_LIMIT+1, TOP_LIMIT+1>	; matching to start
new_pos Coords <LEFT_LIMIT+1, TOP_LIMIT+1>

.code

;------------------Private Procedures--------------------------------

DrawPlayer PROC USES eax
;
; Redraws player avatar in new location.
;
; Receives: ESI - the offset to a coordinate struct specifying 
; the new location to place the player's avatar.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------

.data
    BLANK_SYMBOL EQU <" ">

.code

	; clear and redraw player.
	; mReplaceChar OFFSET prev_pos, esi, PLAYER

	; clear character at prev position
    mov esi, OFFSET prev_pos
    mov dh, (Coords PTR [esi]).y
    mov dl, (Coords PTR [esi]).x
    call GoToXY
    mov al, BLANK_SYMBOL
    call WriteChar

    ; write character at new position
    mov esi, OFFSET new_pos
    mov dh, (Coords PTR [esi]).y
    mov dl, (Coords PTR [esi]).x
    call GoToXY
    mov al, PLAYER
    call WriteChar


	; update player location tracker.
	mov al, (Coords PTR [esi]).y
	mov prev_pos.y, al

	mov al, (Coords PTR [esi]).x
	mov prev_pos.x, al

	ret

DrawPlayer ENDP

;---------------------------------------------------------
PlayerJump PROC USES eax esi ecx
;
; Applies "Jumping" effect to player avatar, moving
; it upward.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------
	
	; save x coord. This really doesn't change.
	mov al, prev_pos.x
	mov new_pos.x, al

	; implement "jump" over three consecutive frames
	; to give smooth effect and prevent the need to spam
	; jump.
	mov ecx, 03h
	JumpLoop:
		mov al, prev_pos.y
		sub al, 01h

		mov new_pos.y, al

		; update player on screen.
		mov esi, OFFSET new_pos
		call DrawPlayer
		loop JumpLoop
	ret

PlayerJump ENDP


;---------------------------------------------------------
PlayerFall PROC USES eax esi
;
; Applies "Gravity" effect to player avatar, moving
; it downward.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------
	
	; save x coord. This really doesn't change.
	mov al, prev_pos.x
	mov new_pos.x, al

	; calculate new height
	mov al, prev_pos.y
	add al, 01h

	mov new_pos.y, al

	; update player on screen.
	mov esi, OFFSET new_pos
	call DrawPlayer

	ret

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
		; TODO
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