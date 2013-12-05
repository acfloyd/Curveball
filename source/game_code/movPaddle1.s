MACRO paddle1Addr_low #0
MACRO paddle1Addr_high #16          ; 4096
            
            LBI R0, #100
            LBI R1, #400
LOOP:       SUB R2, R0, R1
            BNEZ R2, ENDLOOP
            ADDI R0, R0, #1
            J #1

ENDLOOP:    LBI R0, #100

            ; wait for 255 * 255
            LBI R3, #255
            LBI R4, #255
WAIT1:      SUB R4, R4, #1
            BEQZ R4, STORE
WAIT2:      BEQZ R3, ENDWAIT2
            SUB R3, R3, #1
            J WAIT2
ENDWAIT2:   LBI R3, #255
            J WAIT1
STORE:      LBI R3, paddle1Addr_high
            SLBI R3, paddle1Addr_low
            ST R1, R3, #0
