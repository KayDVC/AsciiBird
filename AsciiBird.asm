Include AsciiBird.inc

.data
GAME_WIDTH EQU 50h
GAME_HEIGHT EQU 15h

bg_size_ Dimensions <GAME_WIDTH, GAME_HEIGHT>

.code
main PROC PUBLIC
    ; draw borders and title.
    call SetupBackground

    ; draw starting obstacles

    ; revert to default console colors and clear console.
    Quit:
        call ResetBackground
    INVOKE ExitProcess, 0
main ENDP

END main