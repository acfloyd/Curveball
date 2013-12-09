MACRO paddle1_x_Addr_low #0
MACRO paddle1_x_Addr_high #16          ; 4096
MACRO paddle1_y_Addr_low #1
MACRO paddle1_y_Addr_high #16
MACRO mouse_x_pos_low #1
MACRO mouse_x_pos_high #64
MACRO mouse_y_pos_low #2
MACRO mouse_y_pos_high #64
MACRO mouse_status_low #0
MACRO mouse_status_high #64
MACRO score_p1_low #7
MACRO score_p1_high #16
MACRO audio_low #0
MACRO audio_high #32
MACRO ball_z_pos_low #6
MACRO ball_z_pos_high #16
            
            
			LBI R7, #0					;initial RAM base offset
			LBI R3, paddle1_x_Addr_high
            SLBI R3, paddle1_x_Addr_low
            STI R3, #0
			LBI R3, paddle1_y_Addr_high
			SLBI R3, paddle1_y_Addr_low
			STI R3, #1
			LBI R3, mouse_x_pos_high
            SLBI R3, mouse_x_pos_low
            STI R3, #2
            LBI R3, mouse_y_pos_high
			SLBI R3, mouse_y_pos_low
			STI R3, #3
			LBI R3, mouse_status_high
			SLBI R3, mouse_status_low
			STI R3, #4
			LBI R3, audio_high
			SLBI R3, audio_low
			STI R3, #5
			LBI R3, score_p1_high
			SLBI R3, score_p1_low
			STI R3, #6
			LBI R3, ball_z_pos_high
			SLBI R3, ball_z_pos_low
			STI R3, #7
			LBI R3, #0
			STI R3, #8					;Click Reg
			LBI R3, #0
			STI R3, #9 					;Num Clicks
			LBI R3, #0					
			STI R3, #10					;IS CRICK PREASE

LOOP:		LDI R0, #2					;Load mouse x addr
			LDI R1, #3 					;Load mouse y addr
 	        LD R5, R0, #0				;get x mouse pos
 	        LBI R3, #64
 	        ADD R5, R5, R3
 	        LD R6, R1, #0				;get y mouse pos
 	        LBI R3, #48
 	        ADD R6, R6, R3
 	        LDI R0, #0					;Load paddle x addr
			LDI R1, #1 					;Load paddle y addr
 	        ST R5, R0, #0				;write x pos to graphics
 	        ST R6, R1, #0				;write y pos to graphics

 	        LDI R0, #9					;load num clicks
 	        BEQZ R0, RESET
 	        ADDI R0, R0, #0
			J CHECKCLICK
RESET:		LDI R1, #7					;Load ball z addr
			LBI R0, #0
			ST R0, R1, #0				;reset ball position

CHECKCLICK: LDI R2, #4 					;Load mouse status addr
 	        LD R5, R2, #0				;get mouse status
			LDI R0, #8					;Load click reg
 	        NOT R0, R0					;not click reg
 	        LBI R1, #1 					;load mask
 	        AND R1, R5, R1				;mask current mouse
 	        STI R1, #8					; update click reg
 	        AND R0, R0, R1				;current[0] AND ~clickreg[0]
 	        STI R0, #10					;update IS CRICK PREASE

 			LBI R6, #1
 	        AND R6, R5, R6				;check 0 bit pos
 	        BNEZ R6, SCORE				;if no left click, jump to SCORE
 	        LBI R6, #2
 	        AND R6, R5, R6				;check 1 bit pos
 	        BNEZ R6, RIGHTBEEP			;if no right click, branch back to LOOP
 	        J LOOP

SCORE:      LDI R2, #10				;Load IS CRICK PREASE
			BEQZ R2, LOOP			;if click didnt happen, just go back to loop
			LDI R2, #6    			;Load score_p1 addr
			ADDI R7, R7, #1
			ST R7, R2, #0			;if click, write R0 to score
			LDI R2, #5				;Load audio addr
			LBI R6, #128
			SLBI R6, #8
			ST R6, R2, #0			;play sound
			J BALL
RIGHTBEEP:  LDI R2, #5				;Load audio addr
			LBI R6, #128
			SLBI R6, #4
			ST R6, R2, #0
            J LOOP

BALL:		LDI R2, #9				;Load num clicks
			LBI R0, #1 				
			XOR R2, R2, R0			;R2 <- R2 XOR #1
			STI R2, #9				;update num clicks
			J LOOP