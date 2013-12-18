; translated addresses
MACRO ballTran_high #16             
MACRO ballTran_low #4               ; 4100, 0x1004
MACRO ballAddr #0
MACRO posX #0
MACRO posY #1
MACRO posZ #2


        LBI R5, ballAddr
	LBI R1, #0
        ST R1, R5, posX
        ST R1, R5, posY
        ST R1, R5, posZ
	LBI R0, #3
	SLBI R0, #232

LOOP: 		
	LBI R3, #48	
	NOP
	NOP
	NOP
	NOP
	NOP
        LBI R5, ballAddr
        LD R1, R5, posX
        LD R2, R5, posY
        LD R3, R5, posZ
        LBI R6, ballTran_high
        SLBI R6, ballTran_low
	NOP
	NOP
	NOP
	NOP
	NOP
        ST R3, R6, posZ             ; posZ stays the same, stored here

	SUB R4, R0, R3
	BNEZ R4, #1
	LBI R3, #0
	ADDI R3, R3, #1
	LBI R5, ballAddr
	ST R3, R5, posZ

	LBI R5, #78
	SLBI R5, #32
WAIT:
	BEQZ R5, LOOP
	SUBI R5, R5, #1
	J WAIT
