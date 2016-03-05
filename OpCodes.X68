*-----------------------------------------------------------
*   Register Assignments
*   D0
*   D1
*   D2
*   D3  Word operation read in from memory
*   D4  Masked op-code (original op-code with a mask applied)
*   D5  
*   D6
*   D7
*   A0  
*   A1  String to append to display buffer
*   A2
*   A3
*   A4  Last address
*   A5  Pointer to next byte after last byte in string
*   A6  Pointer to current word-op
*   A7  Stack
*   
*   Memory Assignments
*   7500 - 8000: Stack Pointer
*   7400: Start of String Pointer (display buffer)
*-----------------------------------------------------------
BEGIN               EQU    $7000
END                 EQU    $7020
DUKE_EA_FUNCTION    EQU    $3000

    ; Fake instructions that will be generated, and then disassembled
    ORG    BEGIN
    MOVE.B      D5,D0
    MOVE.B      (A7),D6
    MOVEA.W     D0,A6
    MOVE.W      A6,D0
    MOVE.B      D0,D1
    MOVEA.L     D1,A0
    LEA         $1052,A1
    CLR.L       D0
    CLR.B       D2
    MOVEA.W     D0,A6
    MOVEA.L     D1,A0
    NOP
    
    ; 

    ORG    $2000
START:                  ; first instruction of program
    
        MOVEA.L #$00004000,SP
        MOVEA.W #BEGIN,A6
        MOVEA.L #STRING_PTR,A5

; Begin examining op-code ID
LOOP    MOVE.W  (A6)+,D3    ; Load word-op to disassemble
        MOVE.W  D3,D4       ; Copy to another location so it's safe to modify
        ANDI.W  #$F000,D4   ; bitmask it for the last 4 bits (op-code ID)
        
        CLR     D5
        CMPI    #$0,D4
        BEQ     OP_ID_0
        
        CMPI    #$1000,D4
        BEQ     OP_ID_1
        
        CMPI    #$2000,D4
        BEQ     OP_ID_2
        
        CMPI    #$3000,D4
        BEQ     OP_ID_3
        
        CMPI    #$4000,D4
        BEQ     OP_ID_4
                
        CMPI    #$5000,D4
        BEQ     OP_ID_5
                
        CMPI    #$6000,D4
        BEQ     OP_ID_6
                
        CMPI    #$7000,D4
        BEQ     OP_ID_7
                
        CMPI    #$8000,D4
        BEQ     OP_ID_8
                
        CMPI    #$9000,D4
        BEQ     OP_ID_9
                
        CMPI    #$B000,D4
        BEQ     OP_ID_B
                
        CMPI    #$C000,D4
        BEQ     OP_ID_C
                
        CMPI    #$D000,D4
        BEQ     OP_ID_D
                
        CMPI    #$E000,D4
        BEQ     OP_ID_E
        
        BRA     BAD_INPUT
        
; End ID cases
        
OP_ID_0
        

OP_ID_1 
        BRA     OP_MOVEB

OP_ID_2
        ;MOVEL

OP_ID_3
        MOVE.W  D3,D4
        ANDI.W  #$01C0,D4
        CMPI.W  #$0040,D4
        BEQ     OP_MOVEAW
        BRA     OP_MOVEW

OP_ID_4
        BTST.L  #$08,D3     ; compare the 8th bit in the op-code to 0
        BNE     OP_LEA      ; if it's a 1, it's a LEA op-code
        
        BTST.L  #11,D3     ; compare the 11th bit to 0
        BEQ     OP_CLR       ; if it's a 0, it's a CLR op-code
        BRA     LOOP        ; TO-DO Add more op-code compares for ID=4

OP_ID_5
        BRA     OP_ADDQ

OP_ID_6 

OP_ID_7
        BRA     OP_MOVEQ

OP_ID_8
        BRA     OP_DIVSW

OP_ID_9 

OP_ID_B 

OP_ID_C 

OP_ID_D 

OP_ID_E BRA     BAD_INPUT

; Print out code.
LOOP_END
        MOVE.B  #0,(A5)
        MOVEA.L #STRING_PTR,A1
        MOVE.L  #13,D0
        TRAP    #15
        MOVEA.L #STRING_PTR,A5
        
        CMPA.L  #END,A6
        BEQ     Z_END
                
        BRA     LOOP

;----------------------------------------------------------------------
; Op-Code Processing Labels (Alphabetical Order)
;----------------------------------------------------------------------
OP_ADD
        BRA     LOOP_END
        
OP_ADDA
        BRA     LOOP_END
        
OP_ADDQ
        BRA     LOOP_END
        
OP_AND
        BRA     LOOP_END
        
OP_ASD
        BRA     LOOP_END
        
OP_BCC
        BRA     LOOP_END
        
OP_BCHG
        BRA     LOOP_END

OP_CLR   
        ; Verify it's a CLR instruction
        MOVE.W  D3,D4
        ANDI.W  #$FF00,D4
        CMPI.W  #$4200,D4
        BNE     BAD_INPUT
        
        ; CLR cannot have bits 6 and 7 set to 11
        MOVE.W  D3,D4
        ANDI.W  #$00C0,D4
        CMPI.W  #$00C0,D4
        BEQ     BAD_INPUT
        
        ; Print instructions
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_CLR,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        
        MOVE.W  D3,D4
        ANDI.W  #$003F,D4
        JSR     DUKE_EA
        
        BRA     LOOP_END
        
OP_CMP
        BRA     LOOP_END
        
OP_CMPA
        BRA     LOOP_END
        
OP_CMPI
        BRA     LOOP_END
        
OP_DIVSW
        BRA     LOOP_END
        
OP_EOR
        BRA     LOOP_END
        
OP_EORI
        BRA     LOOP_END
        
OP_JSR
        BRA     LOOP_END

OP_LEA
        ; Veriy it's LEA
        MOVE.W  D3,D4
        ANDI.W  #$F1C0,D4
        CMPI.W  #$41C0,D4
        BNE     BAD_INPUT
        
        ; Print
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_LEA,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D4
        ANDI.W  #$003F,D4
        JSR     DUKE_EA
        
        BRA     LOOP_END
        
OP_LSD
        BRA     LOOP_END
        
OP_MOVEAB
        BRA     LOOP_END
        
OP_MOVEAL
        BRA     LOOP_END

OP_MOVEAW
        BRA     LOOP_END

OP_MOVEB
        ; Verify
        MOVE.W  D3,D4
        ANDI.W  #$F000,D4
        CMPI.W  #$1000,D4
        BNE     BAD_INPUT
        
        ; Print
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEB,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.B  #1,D6
        MOVE.B  #0,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #$2C,(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$0FC0,D5
        LSR.W   #6,D5
        MOVE.B  #0,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_MOVEL
        BRA     LOOP_END
        
OP_MOVEW
        BRA     LOOP_END
        
OP_MOVEMB
        BRA     LOOP_END
        
OP_MOVEML
        BRA     LOOP_END
        
OP_MOVEMW
        BRA     LOOP_END
        
OP_MOVEQ
        BRA     LOOP_END
        
OP_MULSW
        BRA     LOOP_END
        
OP_NOP
        BRA     LOOP_END
        
OP_ROD
        BRA     LOOP_END
        
OP_RTS
        BRA     LOOP_END
        
OP_SUB
        BRA     LOOP_END
        
OP_SUBA
        BRA     LOOP_END
        
OP_SUBI
        BRA     LOOP_END

;----------------------------------------------------------------------
; Printing Functions
;----------------------------------------------------------------------
BAD_INPUT
        ; XXXXXXXX DATA YYYY
        JSR     PRINT_ADDRESS
        LEA     TXT_DATA,A1
        JSR     APPEND_STRING
        
        ; Print op-code data as hex
        ROL.W   #4,D3
        MOVE.L  D3,D1
        MOVE.L  #4,D2 ; Loop counter. Run 4 times.
        
PRINT_OP_HEX_LOOP
        ANDI.W  #$000F,D1
        CMPI.B  #$0A,D1
        BLT     PRINT_OP_HEX_DECIMAL
        ADDI.B  #$7,D1
        
PRINT_OP_HEX_DECIMAL
        ADDI.B  #$30,D1
        MOVE.B  D1,(A5)+
        ROL.W   #4,D3
        MOVE.W  D3,D1
        SUBI.B  #1,D2
        CMPI.L  #0,D2
        BNE     PRINT_OP_HEX_LOOP
        
        BRA     LOOP_END

;--------------------------------------------------
; Print the literal address currently in A6, 
; This should be the prevously read op-code, which
; is the op-code currently being decoded.
;--------------------------------------------------
PRINT_ADDRESS
        MOVEM.L D0-D2,-(SP)
        
        MOVE.L  A6,D0 ; Move op-code address to D0
        SUBI.L  #2,D0 ; Subtract 2 because pointer is to next op-code
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

;--------------------------------------------------
; Append the output buffer with the string starting
; at A1. The string at A1 must end with 0 (null).
;--------------------------------------------------
APPEND_STRING
        MOVE.B  (A1)+,(A5)+
        CMP.B   #0,(A1)
        BNE     APPEND_STRING
        
        RTS

;--------------------------------------------------
; Prints the character B, W, or L depending on the
; value in D4.
; $0000 = B     $0040 = W   anything else = L
;--------------------------------------------------
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
        
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; Appends the decoded EA to the output buffer.
; Needs to call Duke's code instead!!!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; Temp function to Print EA information
DUKE_EA
        

        
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; End the function. Return to Mark particularly!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Z_END
        NOP
        

;----------------------------------------------------------------------
; End of memory variables and constants
;----------------------------------------------------------------------
TXT_DATA        DC.B    'DATA ',0
TXT_OP_ADD      DC.B    'ADD.',0
TXT_OP_ADDA     DC.B    'ADDA.',0
TXT_OP_ADDQ     DC.B    'ADDQ.',0
TXT_OP_AND      DC.B    'AND.',0
TXT_OP_ANDI     DC.B    'ANDI.',0
TXT_OP_ASL      DC.B    'ASL.',0
TXT_OP_ASR      DC.B    'ASR.',0
TXT_OP_BCC      DC.B    'BCC ',0
TXT_OP_BGT      DC.B    'BGT ',0
TXT_OP_BLE      DC.B    'BLE ',0
TXT_OP_BVS      DC.B    'BVS ',0
TXT_OP_BCHG     DC.B    'BCHG ',0
TXT_OP_CLR      DC.B    'CLR.',0
TXT_OP_CMP      DC.B    'CMP.',0
TXT_OP_CMPAW    DC.B    'CMPA.W',0
TXT_OP_CMPAL    DC.B    'CMPA.L',0
TXT_OP_CMPI     DC.B    'CMPI.',0
TXT_OP_DIVSW    DC.B    'DVS.W ',0
TXT_OP_EOR      DC.B    'EOR.',0
TXT_OP_EORI     DC.B    'EORI.',0
TXT_OP_JSR      DC.B    'JSR ',0
TXT_OP_LEA      DC.B    'LEA ',0
TXT_OP_LSL      DC.B    'LSL.',0
TXT_OP_LSR      DC.B    'LSR.',0
TXT_OP_MOVEB    DC.B    'MOVE.B ',0
TXT_OP_MOVEL    DC.B    'MOVE.L ',0
TXT_OP_MOVEW    DC.B    'MOVE.W ',0
TXT_OP_MOVEAB   DC.B    'MOVEA.B ',0
TXT_OP_MOVEAL   DC.B    'MOVEA.L ',0
TXT_OP_MOVEAW   DC.B    'MOVEA.W ',0
TXT_OP_MOVEQ    DC.B    'MOVEQ.L ',0
TXT_OP_MULS     DC.B    'MULS.W ',0
TXT_OP_NOP      DC.B    'NOP ',0
TXT_OP_ROL      DC.B    'ROL.',0
TXT_OP_ROR      DC.B    'ROR.',0
TXT_OP_RTS      DC.B    'RTS ',0
TXT_OP_SUB      DC.B    'SUB.',0
TXT_OP_SUBA     DC.B    'SUBA.',0
TXT_OP_SUBI     DC.B    'SUBI.',0
TXT_DEFAULT_EA  DC.B    'XXXXXX',0
STRING_PTR      DC.B    0
    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
