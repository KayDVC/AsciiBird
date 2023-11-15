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
    LEFT_OFFSET     EQU LEFT_LIMIT + 1Ah
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
    sub al, TOP_OFFSET
    mov obstacle_height, al
    
    ret

CalculateObstacleEndpoints ENDP

GenerateRandomBreakOffset PROC USES edx eax

.data
    ; temp data; not valid across procedure runs
    t_break_offset  BYTE ?
.code

    mGenerateRandomInteger MIN_BREAK_OFFSET, max_break_offset
    mov t_break_offset, dl

    ret
GenerateRandomBreakOffset ENDP

GenerateRandomBreakLen PROC USES edx eax

.data
    ; temp data; not valid across procedure runs
    t_break_len     BYTE ?
.code

    mGenerateRandomInteger MIN_BREAK_LEN, max_break_len
    mov t_break_len, dl

    ret
GenerateRandomBreakLen ENDP

;---------------------------------------------------------
CreateObstacle PROC USES ebx eax ecx
;
; Writes the top and bottom borders to the console.
;
; Receives: ESI - the offset of the obstacle's string.
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

    mov edx, 01h ; used in loop logic.

    ; create first section of chars.
    movzx ecx, t_break_offset
    AppendLine:
        mov BYTE PTR [esi], LINE_SYMBOL
        inc esi
        loop AppendLine

    cmp edx, 00h    ; break out of macro if edx cleared.
    je  Return

    movzx ecx, t_break_len
    AppendBreak:
        mov BYTE PTR [esi], BREAK_SYMBOL
        inc esi
        loop AppendBreak

    ; calculate remaining lines to be added.
    movzx ecx, obstacle_height
    movzx eax, t_break_offset
    sub ecx, eax
    movzx eax, t_break_len
    sub ecx, eax
    
    mov edx, 00h ; jmp to procedure exit when done
    jmp AppendLine

    Return:
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
    t_old_coords Coords <>
    t_new_coords Coords <>
.code
    
    ; copy current location
    mov al, TOP_LIMIT
    mov t_old_coords.y, al
    mov al, (Coords PTR [esi]).x
    mov t_old_coords.x, al
    

    mov t_new_coords.y, TOP_LIMIT
    ; print all chars on column - 1.
    mov al, (Coords PTR [esi]).x
    sub al, 01h

    ; generate new obstacle at rightmost column if current obstacle runs out of bounds.
    cmp al, LEFT_LIMIT
    jae Draw

    mov al, bottom_border_end.x
    sub al, 01h

    push esi
    mov esi, edi
    call CreateObstacle
    pop esi

    Draw:
        mov t_new_coords.x, al

        ; only between the borders.
        movzx ecx, obstacle_height
        DrawChar:
            ; grab next char for erasure.
            mov al, t_old_coords.y
            add al, 01h
            mov t_old_coords.y, al
            
            ; print char on next row.
            mov al, t_new_coords.y
            add al, 01h
            mov t_new_coords.y, al
        
            ; print char
            mReplaceChar OFFSET t_old_coords, OFFSET t_new_coords, [edi]

            ; grab next char in string
            inc edi
            loop DrawChar
    
    ; save obstacle at new x-coord.
    mov al, t_new_coords.x
    mov (Coords PTR [esi]).x, al 
    
    ret

DrawObstacle ENDP


;------------------Public Procedures---------------------------------

SetupObstacles PROC PUBLIC USES esi eax
;
; Creates a initial obstacles and prints to console.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Irvine Lib. Shared variable `bg_size_` be
;           instantiated.
;---------------------------------------------------------

.code 

    ; calculate necessary data.
    call CalculateBreakBounds
    call CalculateObstacleEndpoints
    

    ; create the string representation of starting obstacles.
    mov esi, OFFSET obs_one
    call CreateObstacle

    ; wait a .5 seconds to ensure RNG is somewhat random.
    mov eax, 01F4h
    call Delay

    mov esi, OFFSET obs_two
    call CreateObstacle

    call MoveObstacles

    ret
SetupObstacles ENDP

;---------------------------------------------------------
MoveObstacles PROC PUBLIC USES esi edi
;
; Shifts all obstacles left in the console. Creates new
; obstacles if obstacle goes past border.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Irvine Lib. Shared variable `bg_size_` be
;           instantiated.
;---------------------------------------------------------
    
    ; draw obstacles to screen.
    mov esi, OFFSET obs_one_start
    mov edi, OFFSET obs_one
    call DrawObstacle

    mov esi, OFFSET obs_two_start
    mov edi, OFFSET obs_two
    call DrawObstacle

    ret
MoveObstacles ENDP
 


END