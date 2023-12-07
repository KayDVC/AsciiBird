Include AsciiBird.inc

.data
    GAME_WIDTH EQU 50h
    GAME_HEIGHT EQU 15h
    bg_size_ Dimensions <GAME_WIDTH, GAME_HEIGHT>

.code

; Tests the Background Generation
TestBackground PROC

    ; draw borders and title.
    call SetupBackground

    ; revert to default console colors and clear console.
    Quit:
        call ResetBackground
        ret
TestBackground ENDP

; Tests the Random Number Generator Macro
TestGenerateRandomNumberMacro PROC USES eax edx
.data
    max_v BYTE ?
    output BYTE " Was the random number generated ",13, 10,0
.code
    
    ; Test various minimum values
    FOR min, <01h, 02h, 03h>
        mov max_v, 14h
        mGenerateRandomInteger min, max_v
        movzx eax, dl
        call WriteDec
        mov edx, OFFSET output
        call WriteString
    ENDM
    

    ; Test various maximum values
    FOR max, <14h, 1Eh, 28h, 0FFh, 30h, 4Ah>
        mov max_v, max
        mGenerateRandomInteger 05h, max_v
        movzx eax, dl
        call WriteDec
        mov edx, OFFSET output
        call WriteString
    ENDM

    ret
TestGenerateRandomNumberMacro ENDP

; Test Player Display and Player Movement procedures.
TestPlayerMovement PROC USES edx eax

    call SetupPlayer

    TestPlayerMovementLoop:
        
        call ReadKey    ; read input, non-blocking
        call MovePlayer

        mov eax, 064h ; wait .1 seconds
		call Delay

        jmp TestPlayerMovementLoop  ; run infinitely.

    ret

TestPlayerMovement ENDP


; Tests Player Movement with Background
TestPlayerInEnvironment PROC USES edx eax
    
    call SetupBackground
    call SetupPlayer

    mov ecx, 70h
    TestPlayerMovementLoop:
        
        call ReadKey    ; read input, non-blocking
        call MovePlayer

        mov eax, 064h ; wait .1 seconds between loops
		call Delay

        loop TestPlayerMovementLoop ; run certain amount before quiting.

    call ResetBackground
    ret

TestPlayerInEnvironment ENDP

; Tests the initial obstacle generation.
TestObstacleCreation PROC
    
    call SetupBackground    ; data initialized here is required for starting obstacles.
    call SetupObstacles

    call ResetBackground
    ret
TestObstacleCreation ENDP

; Tests the movement logic for obstacles.
TestObstacleMovement PROC
    call SetupBackground    ; data initialized here is required for starting obstacles.
    call SetupObstacles

    mov ecx, 03E8h
    TestObstacleMovementLoop:
        
        call MoveObstacles

        mov eax, 064h ; wait .1 seconds between loops
        call Delay

        loop TestObstacleMovementLoop

    call ResetBackground
    ret

TestObstacleMovement ENDP

; Tests the player movement with obstacle movement
TestPlayerWithObstacles PROC 
    call SetupBackground    ; data initialized here is required for starting obstacles.
    call SetupObstacles
    call SetupPlayer

       
    TestPlayerWithObstacleLoop:
        
        call MoveObstacles
        call ReadKey
        call MovePlayer

        mov eax, 064h ; wait .1 seconds between loops
        call Delay

        loop TestPlayerWithObstacleLoop

    ret
TestPlayerWithObstacles ENDP

TestMain PROC PUBLIC
    
    ;call TestBackground
    ;call TestGenerateRandomNumberMacro
    ;call TestPlayerMovement
    ;call TestPlayerInEnvironment
    ;call TestObstacleCreation
    ;call TestObstacleMovement
    ;call TestPlayerWithObstacles

    INVOKE ExitProcess, 0

TestMain ENDP

END TestMain