*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*   Register Assignments
*   D0
*   D1
*   D2
*   D3  Word operation read in from memory
*   D4  Masked op-code (original op-code with a mask applied)
*   D5  Testing masked op-code against a set value
*   D6
*   D7
*   A0
*   A1
*   A2
*   A3
*   A4
*   A5
*   A6  Pointer to current word-op
*   A7  Stack
*-----------------------------------------------------------
BEGIN   EQU $1000

    ; Fake instructions that will be generated, and then disassembled
    ORG    BEGIN
    MOVEA.W     D0,A6
    MOVEA.L     D1,A0
    LEA         $1052,A1
    CLR.L       D0
    CLR.B       D2
    MOVEA.W     D0,A6
    MOVEA.L     D1,A0
    NOP
    
    ; 

    ORG    $4000
START:                  ; first instruction of program
    
        MOVEA.W $8000,SP
        MOVEA.W #BEGIN,A6

; Begin examining op-code ID
LOOP    MOVE.W  (A6)+,D3    ; Load word-op to disassemble
        MOVE.W  D3,D4       ; Copy to another location so it's safe to modify
        ANDI.W  #$F000,D4   ; bitmask it for the last 4 bits (op-code ID)
        
        CLR     D5
        CMP     D4,D5       ; if (IF == 0)
        BEQ     ZERO
        
        MOVE.W #$1000,D5    ; if (ID == 1)
        CMP     D4,D5
        BEQ     MOVEB
        
        MOVE.W #$2000,D5
        CMP     D4,D5
        BEQ     TWO
        
        MOVE.W #$3000,D5
        CMP     D4,D5
        BEQ     THREE
        
        MOVE.W #$4000,D5
        CMP     D4,D5
        BEQ     FOUR
        
; End ID cases
        
ZERO    BRA     LOOP

TWO     BRA     LOOP

THREE   BRA     LOOP

; op-code ID = 4
FOUR    BTST.L  #$08,D3     ; compare the 8th bit in the op-code to 0
        BNE     LOADEA      ; if it's a 1, it's a LEA op-code
        
        BTST.L  #11,D3     ; compare the 11th bit to 0
        BEQ     CLEAR       ; if it's a 0, it's a CLR op-code
        BRA     LOOP        ; TO-DO Add more op-code compares for ID=4


; CLR Instruction
CLEAR   
        ; Verify it's a CLR instruction
        MOVE.W  D3,D4
        ANDI.W  #$FF00,D4
        CMPI.W  #$4200,D4
        BNE     BAD_INPUT
        
        MOVE.W  D3,D4
        ANDI.W  #$00C0,D4
        CMPI.W  #$00C0,D4
        BEQ     BAD_INPUT ; CLR cannot have bits 6 and 7 set to 11
        
        ;  Placeholder to print hex address
        MOVE.B  #15,D0
        MOVE.W  A6,D1
        MOVE.B  #16,D2
        TRAP    #15
        
        ; Placehodler to print CLR
        MOVE.B  #6,D0
        MOVE.B  #$20,D1
        TRAP    #15
        MOVE.B  #$43,D1
        TRAP    #15
        MOVE.B  #$4C,D1
        TRAP    #15
        MOVE.B  #$52,D1
        TRAP    #15
        MOVE.B  #$2E,D1
        TRAP    #15
        
        ; Determine Size
        ; Placeholder code to print out size
        CMPI.W  #$0000,D4
        BEQ     PRINT_B
        CMPI.W  #$0040,D4
        BEQ     PRINT_W
        MOVE.B  #$4C,D1
        BRA     PRINT
        
PRINT_B MOVE.B  #$42,D1
        BRA     PRINT
        
PRINT_W MOVE.B  #$57,D1

PRINT   TRAP    #15
        MOVE.B  #$0D,D1
        TRAP    #15
        MOVE.B  #$0A,D1
        TRAP    #15
        BRA     LOOP

; placeholder op-code disassembling
MOVEB   NOP
LOADEA  NOP
    

BAD_INPUT
        NOP
        BRA     LOOP
    

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
