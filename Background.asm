Include AsciiBird.inc

.data
    MIN_BG_W    EQU 28h
    MIN_BG_H    EQU 10h
    MAX_BG_W    EQU 80h
    MAX_BG_H    EQU 20h
    BG_ERR      EQU <"The size of the background is too small, too large, or empty">
    DEFAULT_CLR EQU lightGray+(black*16)

    bottom_border_start Coords <>
    bottom_border_end   Coords <>    
    top_border_start    Coords <>     
    top_border_end      Coords <>    
.code

;------------------Private Macros------------------------------------

; sets the foreground and background colors specified at row location.
mSetColor MACRO row:REQ, color:REQ
    LOCAL spacer, SPACE_SYMBOL, append_char
.data
    SPACE_SYMBOL EQU <" ">
    spacer BYTE MAX_BG_W DUP (0)  ; create border with specified width
.code

    ; fill in spacer string.
    mFillString OFFSET spacer, SPACE_SYMBOL, bg_size_.cols

    ; set cursor to specified row.
	mov  dh, row
    mov	 dl, LEFT_LIMIT
	call GotoXY			

    ; change row to use specified colors.
	mov  eax, color
	call SetTextColor
	mov edx, OFFSET spacer
	call WriteString
ENDM

;------------------Private Procedures--------------------------------


CalculateBorderEndPoints PROC USES eax
;
; Calculates the start and end coordinates of borders.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Shared variable `bg_size_` instantiated.
;---------------------------------------------------------
    
    ; set givens.
    mov top_border_start.y, TOP_LIMIT
    mov top_border_start.x, LEFT_LIMIT

    mov top_border_end.y, TOP_LIMIT

    mov bottom_border_start.x, LEFT_LIMIT

    ; calculate remaining 'x' coordinates.
    mov al, LEFT_LIMIT
    add al, bg_size_.cols
    
    mov top_border_end.x, al
    mov bottom_border_end.x, al

    ; calculate remaining 'y' coordinates.
    mov al, TOP_LIMIT
    add al, bg_size_.rows

    mov bottom_border_start.y, al
    mov bottom_border_end.y, al  
    
    ret

CalculateBorderEndpoints ENDP

;---------------------------------------------------------
WriteTitle PROC USES eax edx ebx
;
; Writes the title of the game to the top of the console.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Irvine Lib.
;---------------------------------------------------------
.data
    game_title BYTE "ASCII BIRD", 0
    title_area_color EQU black+(white*10h)

.code

    ; set first console line to title colors.
    mSetColor 0, title_area_color

    ; find the approx. center of the background.
    movzx ax, bg_size_.cols
    mov bl, 02h
    div bl

    ; shift center to account for offset.
    add al, LEFT_LIMIT

    ; write title
    mov dh, 0
    mov dl, al
    call GotoXY
    
    mov edx, OFFSET game_title
    call WriteString

    ret

WriteTitle ENDP


;---------------------------------------------------------
WriteBorder PROC USES eax edx ecx esi
;
; Writes the top and bottom borders to the console.
;
; Receives: Nothing.
; Returns: Nothing.
; Requires: Irvine Lib.
;---------------------------------------------------------

.data
    BORDER_SYMBOL EQU <"-">
    border BYTE MAX_BG_W DUP (0h)  ; create border with specified width
    sky_area_color EQU white+(lightBlue*10h)  
    land_area_color EQU brown+(green*10h)
    rows_to_color EQU 02h

    bottom_border BYTE ?
.code
    
    ; fill in border string.
    mFillString OFFSET border, BORDER_SYMBOL, bg_size_.cols
    
    ; set top border and line above to sky colors.
    mov dl, TOP_LIMIT
    sub dl, 02h
    REPEAT rows_to_color
        inc dl
        push edx
        mSetColor dl, sky_area_color
        pop edx
    ENDM

    ; draw top border.
    mov dh, top_border_start.y
    mov dl, top_border_start.x
    call GotoXY

    mov edx, OFFSET border
    call WriteString


    ; set bottom border and line below to land colors.
    mov dl, bottom_border_start.y
    sub dl, 01h
    REPEAT rows_to_color
        inc dl
        push edx
        mSetColor dl, land_area_color
        pop edx
    ENDM

    ; draw bottom border
    mov dh, bottom_border_start.y
    mov dl, bottom_border_start.x
    call GotoXY

    mov edx, OFFSET border
    call WriteString    

    ret

WriteBorder ENDP



;------------------Public Procedures---------------------------------

SetupBackground PROC PUBLIC
;
; Creates a background and sets borders for the game.
;
; Receives: Nothing.
; Returns: EAX = 1 if setup successful, 0 otherwise.
; Requires: Irvine Lib. Shared variable `bg_size_` be
;           instantiated and within min/max bounds
;           as defined.
;---------------------------------------------------------

.code 

    ; check width bounds.
    mCheckBounds MIN_BG_W, MAX_BG_W, bg_size_.cols 
    cmp eax, FALSE
    jz Fail

    ; check height bounds
    mCheckBounds MIN_BG_H, MAX_BG_H, bg_size_.rows
    cmp eax, FALSE
    jz Fail

    ; create colored background with title.
    call CalculateBorderEndpoints
    call WriteTitle
    call WriteBorder

    ; set remaining output to default colors.
    mov  eax, DEFAULT_CLR
	call SetTextColor

    jmp Pass

    Fail:
        mWriteErr BG_ERR
        mProcResult FAILURE
        ret

    Pass:
        mProcResult SUCCESS
        ret
SetupBackground ENDP
 

;---------------------------------------------------------
ResetBackground PROC PUBLIC USES eax
;
; Changes the color of the terminal back to default black and
; grey text.

; Receives: Nothing.
; Returns: Nothing.
; Requires: Irvine Lib.
;---------------------------------------------------------

    ; set colors.
    mov eax, DEFAULT_CLR
    call SetTextColor
    call Clrscr

    ret
ResetBackground ENDP






END



