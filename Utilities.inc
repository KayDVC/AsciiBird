INCLUDE Irvine32.inc

;; all mov instructions assume value is not constant. This is in line with the 

.data
; Constants
TRUE EQU 1
FALSE EQU 0

.code
mCheckBounds MACRO min:REQ, max:REQ, val:REQ
;;---------------------------------------------------------
;;
;; Checks if integer between min and max bounds.
;;
;; Receives:  min - min bound, max - max bound, val - integer to check.
;; Returns: EAX - 1 if integer within bounds, 0 otherwise.
;; Requires: Nothing.
;;---------------------------------------------------------

    LOCAL Next, OutOfBounds, InBounds
    
    ;; check bounds.
    movzx eax, val

    cmp eax, DWORD PTR min
    jb  OutOfBounds

    cmp eax, DWORD PTR max
    ja OutOfBounds

    jmp InBounds

    OutOfBounds:
        mProcResult FALSE
        jmp Next
    InBounds:
        mProcResult TRUE
        jmp Next

    Next:

ENDM

mWriteErr MACRO err:REQ
;;---------------------------------------------------------
;;
;; Writes error message to console.
;;
;; Receives:  error - string to write. 
;; Returns: Nothing
;; Requires: Irvine32.inc
;;---------------------------------------------------------
    LOCAL string        ;; avoid matching id errors.
.data
    string BYTE err, 0  ;; ensure string 0-terminated.

.code
    push edx
    
    mov edx, OFFSET string
    call WriteString 

    pop edx

ENDM

mProcResult MACRO res:REQ
;;---------------------------------------------------------
;;
;; Writes procedure result to eax.
;;
;; Receives:  res - the result of a procedure. 
;; Returns: Nothing
;; Requires: Nothing
;;---------------------------------------------------------
    mov eax, res
ENDM

mGenerateRandomInteger MACRO min:REQ, max:REQ
;;---------------------------------------------------------
;;
;; Generates a random integer between min and max.
;;
;; Receives:  min - minimum bound, max - maximum bound.
;; Min >= 0, Max <= 255
;; Returns: DL - psuedo-random number, EAX - whether 
;; random result is valid (within specified bounds).
;; Requires: Nothing
;; Note: Generates psuedo-random number based on clock 
;; ticks. Not currently seedable (repeatable).
;;---------------------------------------------------------
    LOCAL Fail, Next

    ;; ensure max not less than min (& vice versa).
    ;;movzx edx, max
    ;;cmp edx, DWORD PTR min
    ;;jb Fail

    push ebx ;; register used during division.

    ;; use Windows API
    call GetTickCount

    ;; use (modulo) division to get random number. Result should always be 1 byte.
    mov dx, 00h ;; avoid division overflow
    movzx bx, max 
    sub bx, WORD PTR min ;; add back in later to ensure result will always be above min.
    div bx
    add dx, WORD PTR min

    ;; ensure psuedo-random number is within bounds.
    mCheckBounds min, max, dl
    jmp Next

    Fail: 
        mProcResult FALSE
    Next:
        pop ebx
ENDM

mFillString MACRO address:REQ, char:REQ, len:REQ
;;---------------------------------------------------------
;;
;; Dyanimcally fills in a string to the specifed length
;; using specified char.
;;
;; Receives: address - the offset of a string, char - the char
;; to fill the string with, len - the desired length of the string
;; Returns: Nothing
;; Requires: Nothing
;;---------------------------------------------------------
    LOCAL append_char

    push ecx
    push esi

    ; define loop reps and memory addr to insert.
    movzx ecx, len
    mov esi, address
    
    append_char:
        mov BYTE PTR [esi], char
        inc esi
        loop append_char

    pop esi
    pop ecx

ENDM

mReplaceChar MACRO prev_pos:REQ, new_pos:REQ, char:REQ
;;---------------------------------------------------------
;;
;; Clears character at specified old location and places
;; specified character at new location.
;;
;; Receives: prev_pos - the offset to a coordinate struct
;; specifying the old location to clear, new_pos - the offset
;; to a coordinate struct specifying the new location to place 
;; the char, char - the character to place.
;; Returns: Nothing
;; Requires: Irvine Lib.
;;---------------------------------------------------------
    LOCAL BLANK_SYMBOL
.data
    BLANK_SYMBOL EQU <" ">

.code
    
    push edx
    push eax
    push esi

    ; clear character at prev position
    mov esi, prev_pos
    mov dh, (Coords PTR [esi]).y
    mov dl, (Coords PTR [esi]).x
    call GoToXY
    mov al, BLANK_SYMBOL
    call WriteChar

    pop esi ; likely (not always) to be new_pos
    push esi
    
    ; write character at new position
    mov esi, new_pos
    mov dh, (Coords PTR [esi]).y
    mov dl, (Coords PTR [esi]).x
    call GoToXY
    mov al, char
    call WriteChar

    pop esi
    pop eax
    pop edx
    
ENDM