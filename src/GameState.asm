Include AsciiBird.inc

.data
    SCORE_MSG       BYTE "Score:", 0 
    SCORE_COORDS    Coords <LEFT_LIMIT+ 07h, TOP_LIMIT-03h>
    game_score      BYTE 0
    loop_delay      BYTE 096H   ; 150 ms to start
    msg_coords      Coords <>
    
.code

; Writes score to specified area.
mWriteScore MACRO score:REQ

    mov dh, SCORE_COORDS.y
    mov dl, SCORE_COORDS.x
    call GoToXY

    movzx eax, score
    call WriteDec

ENDM

;------------------Public Procedures---------------------------------

SetupGame PROC PUBLIC USES eax edx
;
; Creates game background, obstacles, and player avatar.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------
.data
    wait_msg    BYTE "Press the spacebar to start", 0
.code
    call SetupBackground 
    call SetupObstacles
    call SetupPlayer

    ; setup score info
    mov dh, SCORE_COORDS.y
    mov dl, LEFT_LIMIT
    call GoToXY
    mov edx, OFFSET SCORE_MSG
    call WriteString
    mWriteScore game_score
    
    ; calculate area below the game to display messages.
    movzx ax, bg_size_.cols ; find the approx. center column.
    mov bl, 02h
    div bl
    add al, LEFT_LIMIT ; shift center to account for offset.
    mov msg_coords.x, al
 
    mov al, bg_size_.rows ; find a row below the game background.
    add al, TOP_LIMIT
    add al, 03h 
    mov msg_coords.y, al

    mov dh, msg_coords.y
    mov dl, msg_coords.x
    call GoToXY
    
    ; display instruction message.
    mov edx, OFFSET wait_msg
    call WriteString
    
    ; wait for space bar to be pressed.
    WaitLoop:
        call ReadChar

        cmp al, " "
        je ExitLoop
        jmp WaitLoop
    
    ExitLoop:
        ret
SetupGame ENDP

;---------------------------------------------------------
UpdateScore PROC PUBLIC USES eax
;
; Increments and displays new game score.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------
    
    mov al, game_score
    inc al
    mov game_score, al

    mWriteScore game_score

    dec loop_delay ; progressive diffuculty increase.

    ret

UpdateScore ENDP

;---------------------------------------------------------
RunGameLoop PROC PUBLIC USES eax
;
; Increments and displays new game score.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Nothing.
;---------------------------------------------------------
    GameLoop:
                            
        call MoveObstacles  ; prevent overwriting the avatar.
        call ReadKey        ; non-blocking read.
        call MovePlayer     ; move avatar down (fall) or up (jump).

        movzx eax, loop_delay
        call Delay          ; gives player time to react between iterations.

        jmp GameLoop

     ret    ; will never actually reach this.

RunGameLoop ENDP

;---------------------------------------------------------
GameOver PROC PUBLIC USES edx ebx eax
;
; Stops game loop and displays game over message + final score.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Shared variable `bg_size_` instantiated.
;---------------------------------------------------------
.data
	game_over_msg   BYTE "Game Over! Your Score is: ", 0
    newline         BYTE ".", 13, 10, 0
    exit_msg        BYTE "Press any key to exit.", 0
.code
	
	; write game over message and score.
    mov dh, msg_coords.y
    mov dl, msg_coords.x
    call GotoXY
    mov edx, OFFSET game_over_msg
    call WriteString

    movzx eax, game_score
    call WriteDec

    ; newline
    mov edx, OFFSET newline
    call WriteString

    ; display message and wait until any key pressed before exiting.
    mov edx, OFFSET exit_msg
    call WriteString
    call ReadChar

    call ResetBackground

	INVOKE ExitProcess, 0

    ret

GameOver ENDP

END