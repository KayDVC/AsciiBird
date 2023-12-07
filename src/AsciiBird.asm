Include AsciiBird.inc

.data
GAME_WIDTH EQU 50h
GAME_HEIGHT EQU 15h

bg_size_ Dimensions <GAME_WIDTH, GAME_HEIGHT>

.code
Main PROC PUBLIC
    
    call SetupGame

    call RunGameLoop

    INVOKE ExitProcess, 0
Main ENDP

END Main