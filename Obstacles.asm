Include AsciiBird.inc


.data
MIN_OBSTACLE_GAP    EQU 15h
MIN_BREAK_LEN       EQU 02h 
MIN_BREAK_OFFSET    BYTE 03h 
max_break_len       BYTE 05h
max_break_offset    BYTE ?

obs_one BYTE MAX_BG_H DUP(0)
obs_two BYTE MAX_BG_H DUP(0)

obs_one_start   Coords <TOP_LIMIT+1, LEFT_LIMIT+05h>
obs_two_start   Coords <>

obstacle_height BYTE ?

.code

;------------------Private Macros----------------------------------

; Creates a vertical line with variable sized gap.
mCreateObstacleStr MACRO str_address:REQ, break_offset:REQ, break_len:REQ, total_len:REQ
    LOCAL AppendLine, AppendBreak, Next, LINE_SYMBOL, BREAK_SYMBOL
.data
    LINE_SYMBOL EQU <"|">
    BREAK_SYMBOL EQU <" ">

.code

    push ecx
    push edx

    mov edx, 01h ; used in loop logic.

    ;; create first section of chars.
    movzx ecx, break_offset
    AppendLine:
        mov BYTE PTR [esi], LINE_SYMBOL
        inc esi
        loop AppendLine

    cmp edx, 00h    ;; break out of macro if edx cleared.
    je  Next

    movzx ecx, break_len
    AppendBreak:
        mov BYTE PTR [esi], BREAK_SYMBOL
        inc esi
        loop AppendBreak

    ;; calculate remaining lines to be added.
    movzx ecx, total_len
    movzx eax, break_offset
    sub ecx, eax
    movzx eax, break_len
    sub ecx, eax
    
    mov edx, 00h ; exit macro when complete.
    jmp AppendLine

    Next:
        pop edx
        pop ecx

ENDM

;------------------Private Procedures--------------------------------

CalculateBreakBounds PROC USES eax ebx
;
; Calculates the maximum bound break offsets in obstacles.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Shared variable `bg_size_` be instantiated.
;---------------------------------------------------------

    ; ensure maximum bound is only slightly larger  than 
    ; half the bg's height (~60%).
    movzx ax, bg_size_.rows
    mov bl, 03h
    mul bl

    mov bl, 05h
    div bl

    mov max_break_offset, al

    ret

CalculateBreakBounds ENDP

CalculateObstacleEndPoints PROC USES eax
;
; Calculates the start and end coordinates of starting obstacles.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Shared variable `bg_size_` instantiated.
;---------------------------------------------------------
.data
    LEFT_OFFSET     EQU LEFT_LIMIT + 10h
    TOP_OFFSET      EQU TOP_LIMIT + 01h
    right_max       BYTE ?
    next_left_offset BYTE ? 
.code
    
    ; set givens.
    mov obs_one_start.y, TOP_OFFSET
    mov obs_two_start.y, TOP_OFFSET

    t_x = LEFT_OFFSET + 01h  ; initial draw will subtract 1 from x value.
    mov obs_one_start.x, t_x

    ; calculate remaining 'x' coordinates.
    mov al, bottom_border_end.x ; calc right offset and save.
    sub al, 01h 
    mov right_max, al
    mov al, LEFT_OFFSET         ; find min left offset for obs two.
    add al, MIN_OBSTACLE_GAP
    mov next_left_offset, al
    mGenerateRandomInteger next_left_offset, right_max

    add dl, 01h             ; initial draw will subtract 1 from x value.
    mov obs_two_start.x, dl

    ; calculate y-delta and save.
    mov al, bottom_border_start.y
    sub al, 01h 
    sub al, TOP_OFFSET
    mov obstacle_height, al
    
    ret

CalculateObstacleEndpoints ENDP

GenerateRandomBreakOffset PROC

.data
    ; temp data; not valid across procedure runs
    t_break_offset  BYTE ?
.code

    mGenerateRandomInteger MIN_BREAK_OFFSET, max_break_offset
    mov t_break_offset, 0Ch

    ret
GenerateRandomBreakOffset ENDP

GenerateRandomBreakLen PROC

.data
    ; temp data; not valid across procedure runs
    t_break_len     BYTE ?
.code

    mGenerateRandomInteger MIN_BREAK_LEN, max_break_len
    mov t_break_len, 03h

    ret
GenerateRandomBreakLen ENDP

;---------------------------------------------------------
CreateObstacle PROC USES ebx eax ecx
;
; Writes the top and bottom borders to the console.
;
; Receives: EDX - the offset of the obstacle's string.
; Returns: Nothing.
; Requires: Irvine Lib.
;---------------------------------------------------------
.data
    LINE_SYMBOL EQU <"|">
    BREAK_SYMBOL EQU <" ">

.code

    ; get randomized break offset and length.
    call GenerateRandomBreakOffset
    call GenerateRandomBreakLen

    ; create string for obstacle.
    mov al, bg_size_.rows
    sub al, 02h

    mov edx, 01h ; used in loop logic.

    ;; create first section of chars.
    movzx ecx, t_break_offset
    AppendLine:
        mov BYTE PTR [esi], LINE_SYMBOL
        inc esi
        loop AppendLine

    cmp edx, 00h    ;; break out of macro if edx cleared.
    je  Next

    movzx ecx, t_break_len
    AppendBreak:
        mov BYTE PTR [esi], BREAK_SYMBOL
        inc esi
        loop AppendBreak

    ;; calculate remaining lines to be added.
    movzx ecx, al
    movzx eax, t_break_offset
    sub ecx, eax
    movzx eax, t_break_len
    sub ecx, eax
    
    mov edx, 00h ; exit macro when complete.
    jmp AppendLine

    Next:
    ;mCreateObstacleStr esi, t_break_offset, t_break_len, al
        ret

CreateObstacle ENDP

;---------------------------------------------------------
DrawObstacle PROC USES edi eax ecx edx
;
; Redraws a specified border string at a new location.
;
; Receives: ESI - the offset to the obstacle's current coordinates.
; EDI - the offset of the obstacle's string. 
; Returns: Nothing.
; Requires: Nothing.
; Note: Draws obstacle at current_coord.x - 1
;---------------------------------------------------------
.data
    ; temp data; not valid across procedure runs
    t_coords Coords <>
.code
    

    mov t_coords.y, TOP_LIMIT
    ; print all chars on column - 1.
    mov al, (Coords PTR [esi]).x
    sub al, 01h
    mov t_coords.x, al

    ; only between the borders.
    movzx ecx, obstacle_height
    DrawChar:
        ; print char on next row.
        mov al, t_coords.y
        sub al, 01h
        mov t_coords.y, al
        
        ; print char
        mReplaceChar esi, OFFSET t_coords, [edi]

        ; grab next char in string
        inc edi
        loop DrawChar

    ret

DrawObstacle ENDP


;------------------Public Procedures---------------------------------

SetupObstacles PROC PUBLIC USES esi edi
;
; Creates a initial obstacles and prints to console.
;
; Receives: Nothing.
; Returns: EAX = 1 if setup successful, 0 otherwise.
; Requires: Irvine Lib. Shared variable `bg_size_` be
;           instantiated and within min/max bounds
;           as defined.
;---------------------------------------------------------

.code 

    ; calculate necessary data.
    call CalculateBreakBounds
    call CalculateObstacleEndpoints
    

    ; create the string representation of starting obstacles.
    mov esi, OFFSET obs_one
    call CreateObstacle
    mov esi, OFFSET obs_two
    call CreateObstacle

    ; draw obstacles to screen.
    mov esi, OFFSET obs_one_start
    mov edi, OFFSET obs_one
    call DrawObstacle

    mov esi, OFFSET obs_two_start
    mov edi, OFFSET obs_two
    call DrawObstacle

    ret
SetupObstacles ENDP
 


END