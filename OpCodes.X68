*-----------------------------------------------------------
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
*   A1  String to append to display buffer
*   A2
*   A3
*   A4
*   A5  Pointer to next byte after last byte in string
*   A6  Pointer to current word-op
*   A7  Stack
*   
*   Memory Assignments
*   7500 - 8000: Stack Pointer
*   7400: Start of String Pointer (display buffer)
*-----------------------------------------------------------
STRING_PTR      EQU $7400
BEGIN           EQU $1000

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
    
        MOVEA.L #$00008000,SP
        MOVEA.W #BEGIN,A6
        MOVEA.L #STRING_PTR,A5

; Begin examining op-code ID
LOOP    MOVE.W  (A6)+,D3    ; Load word-op to disassemble
        MOVE.W  D3,D4       ; Copy to another location so it's safe to modify
        ANDI.W  #$F000,D4   ; bitmask it for the last 4 bits (op-code ID)
        
        CLR     D5
        CMP     D4,D5       ; if (IF == 0)
        BEQ     ZERO
        
        MOVE.W #$1000,D5    ; if (ID == 1)
        CMP     D4,D5
        BEQ     OP_MOVEB
        
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
        BNE     OP_LEA      ; if it's a 1, it's a LEA op-code
        
        BTST.L  #11,D3     ; compare the 11th bit to 0
        BEQ     OP_CLR       ; if it's a 0, it's a CLR op-code
        BRA     LOOP        ; TO-DO Add more op-code compares for ID=4

; Print out code.
LOOP_END
        MOVE.B  #0,(A5)
        MOVEA.L #STRING_PTR,A1
        MOVE.L  #13,D0
        TRAP    #15
        MOVEA.L #STRING_PTR,A5
        BRA     LOOP

; CLR Instruction
OP_CLR   
        ; Verify it's a CLR instruction
        MOVE.W  D3,D4
        ANDI.W  #$FF00,D4
        CMPI.W  #$4200,D4
        BNE     BAD_INPUT
        
        MOVE.W  D3,D4
        ANDI.W  #$00C0,D4
        CMPI.W  #$00C0,D4
        BEQ     BAD_INPUT ; CLR cannot have bits 6 and 7 set to 11
        
        ; Print instructions
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_CLR,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        
        MOVE.W  D3,D4
        ANDI.W  #$003F,D4
        JSR     DUKE_EA
        
        BRA     LOOP_END
        


; placeholder op-code disassembling
OP_MOVEB
        NOP
OP_LEA
        NOP
    

; Printing functions
BAD_INPUT
        NOP
        BRA     LOOP
        
; fUnction to print out the address of the op in hex
PRINT_ADDRESS
        MOVEM.L D0-D2,-(SP)
        
        MOVE.L  A6,D0 ; Move op-code address to D0
        SUBI.L  #2,D0
        ROL.L   #4,D0
        MOVE.L  D0,D1
        MOVE.B  #8,D2 ; Loop counter. Run 8 times.
        
PRINT_ADDRESS_LOOP
        ANDI.L  #$0000000F,D1
        CMPI.B  #$0A,D1
        BLT     PRINT_ADDRESS_DECIMAL
        ADDI.B  #$7,D1
        
PRINT_ADDRESS_DECIMAL
        ADDI.B  #$30,D1
        MOVE.B  D1,(A5)+ ; Write char to string
        ROL.L   #4,D0
        MOVE.L  D0,D1
        SUBI.B  #1,D2 ; check loop condition
        CMPI.L  #0,D2
        BNE     PRINT_ADDRESS_LOOP
        
        MOVE.B  #$20,(A5)+ ; Write ' ' to string
        
        MOVEM.L (SP)+,D0-D2
        RTS
    
; Temporary function to append a string held in A1 to the string pointer
APPEND_STRING
        MOVE.B  (A1)+,(A5)+
        CMP.B   #0,(A1)
        BNE     APPEND_STRING
        
        RTS
        
; Temp function to print 'B', 'W', or 'L' depending on the data in D4
PRINT_SIZE
        CMPI.W  #$0000,D4
        BEQ     PRINT_SIZE_B
        CMPI.W  #$0040,D4
        BEQ     PRINT_SIZE_W
        BRA     PRINT_SIZE_L

PRINT_SIZE_B
        MOVE.B  #$42,(A5)+
        BRA     PRINT_SIZE_END
        
PRINT_SIZE_W
        MOVE.B  #$57,(A5)+
        BRA     PRINT_SIZE_END

PRINT_SIZE_L
        MOVE.B  #$4C,(A5)+

PRINT_SIZE_END
        MOVE.B  #$20,(A5)+
        RTS
        
; Temp function to Print EA information
DUKE_EA
        LEA     TXT_DEFAULT_EA,A1
        JSR     APPEND_STRING
        RTS
        

* Put variables and constants here
TXT_OP_CLR      DC.B    'CLR.',0
TXT_DEFAULT_EA  DC.B    'XXXXXX',0
    END    START        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
