; Get defined macros.
Include Utilities.inc

; All functions private unless otherwise specified.
OPTION PROC:PRIVATE

; Prototypes for external libraries.
ExitProcess     PROTO, exitCode:DWORD
GetTickCount    PROTO                   ; returns time since system started in EAX.
Clrscr          PROTO                   
GotoXY          PROTO                   ; DH: Y-coordinate(row), DL: X-coordinate(column)
SetTextColor    PROTO                   ; EAX: Background*16+Foreground
WriteChar       PROTO                   ; AL: character
WriteString     PROTO                   ; EDX: offset string
WriteDec        PROTO                   ; EAX: Decimal to write
WaitMsg         PROTO                   ; display wait message at current location, wait for Enter key
Delay           PROTO                   ; EAX: milliseconds to delay process for
ReadKey         PROTO                   ; Returns key in AH if available
Randomize       PROTO
RandomRange     PROTO                   ; EAX: maximum range


; Prototypes for public procedures.

; Background.asm
SetupBackground PROTO                   ; EAX = 1 if setup was a success, 0 otherwise
ResetBackground PROTO 

; Player.asm
SetupPlayer     PROTO
MovePlayer      PROTO

; Obstacles.asm
SetupObstacles  PROTO
MoveObstacles   PROTO


; Structs
Coords STRUCT
    x BYTE ?
    y BYTE ?
Coords ENDS

; masm won't let me use width/height :) ...
Dimensions STRUCT
    cols BYTE ?
    rows BYTE ?
Dimensions ENDS

; Constants
TRUE EQU 1
FALSE EQU 0
SUCCESS EQU 1
FAILURE EQU 0

TOP_LIMIT   EQU 5         ; all game content will be at row 5 or lower and at col 3 or more.
LEFT_LIMIT  EQU 3

; bg sizes
MIN_BG_W    EQU 28h
MIN_BG_H    EQU 10h
MAX_BG_W    EQU 80h
MAX_BG_H    EQU 20h

; Shared data
EXTERNDEF bg_size_:             Dimensions  ; defined in main procedure.
EXTERNDEF bottom_border_start:  Coords      ; defined in Background.asm
EXTERNDEF bottom_border_end:    Coords      ;           |
EXTERNDEF top_border_start:     Coords      ;           |
EXTERNDEF top_border_end:       Coords      ;          <->

