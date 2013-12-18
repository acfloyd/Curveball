; assembly file containing the Curveball game code

; game defines
MACRO true #1
MACRO false #0
MACRO height_low #128
MACRO height_high #1    ; height = 384
MACRO halfHeight_high #0
MACRO halfHeight_low #192 ; 153 is where 
MACRO width_low #0
MACRO width_high #2     ; width = 512
MACRO halfWidth_low #0 ; half_width = 256
MACRO halfWidth_high #1
MACRO depth_high #3
MACRO depth_low #232

MACRO stallCnt_high #127
MACRO stallCnt_low #255 ; cnt = 32767, 0x7FFF

MACRO velz_start #1
MACRO ball_rad #35
MACRO curve_reduce #20
MACRO paddle_width #101
MACRO paddle_height #75
MACRO velz_inc #20

MACRO endScore #15

; curve defines
MACRO update #64
MACRO stat_vel_1 #2
MACRO stat_vel_2 #4
MACRO stat_vel_3 #8
MACRO stat_vel_4 #16
MACRO static1 #1
MACRO static2 #2
MACRO static3 #3
MACRO static4 #4

; mapped var bases
MACRO audioAddr_high #32
MACRO audioAddr_low #0
MACRO spartAddr_high #48
MACRO spartAddr_low #0              ; 12888
MACRO mouseAddr_low #0
MACRO mouseAddr_high #64            ; 16384
MACRO scoreAddr_low #7
MACRO scoreAddr_high #16            ; 4110
MACRO gameStateAddr_low #9
MACRO gameStateAddr_high #16        ; 4114
MACRO gameStartAddr_high #80
MACRO gameStartAddr_low #0          ; 0x5000 (20480)

; translated addresses
MACRO ballTran_high #16             
MACRO ballTran_low #4               ; 4100, 0x1004
MACRO paddle2Tran_high #16
MACRO paddle2Tran_low #2            ; 4098, 0x1002
MACRO paddle1Tran_high #16
MACRO paddle1Tran_low #0            ; 4096, 0x1000

; gen mem bases
MACRO ballVelAddr #0
MACRO pMouseAddr #6
MACRO pPaddle2Addr #8
MACRO difficultyAddr #10
MACRO firstAddr #11
MACRO paddle2Addr #12
MACRO paddle1Addr #14
MACRO ballAddr #16
MACRO pPad1Cnt #19
MACRO pPad2Cnt #20

; TODO: add gamestate functionality
; TODO: remove low/high instructions for gen memory

; offset from global var base
MACRO posX #0
MACRO posY #1
MACRO posZ #2
MACRO velX #0
MACRO velY #1
MACRO velZ #2
MACRO accX #3
MACRO accY #4
MACRO xStat #5
MACRO yStat #6
MACRO p1Score #0
MACRO p2Score #1
MACRO mStatus #0
MACRO mPosx #1
MACRO mPosy #2

; extra memory needed to hold mapped global variables
; addresses are for general purpose mem
; 0: ballvel x, y, z acc x, y stat x, y
; 6: pMouse x, y
; 8: pPaddle2 x and y
; 10: difficulty
; 11: first
; 12: paddle2 x, y
; 14: paddle1 x, y
; 16: ball x, y, z
; 19: pPaddle2 counter
; 20: pPaddle1 counter

;void main()
; start by setting up the initial object positions
MAIN:   LBI R0, scoreAddr_high
        SLBI R0, scoreAddr_low
        LBI R1, #0
        ST R1, R0, p1Score          ; playerScore = 0
        ST R1, R0, p2Score          ; oppScore = 0

	; set previous paddle 1 and 2 counters to prevent previous paddles
	; from updating for a certian num of calls to each update routine
	STI R1, pPad1Cnt
	STI R1, pPad2Cnt

        ; check who is starting with the ball
        LBI R3, gameStartAddr_high
        SLBI R3, gameStartAddr_low
        LD R4, R3, #0               ; load in the dip switch determining the start

	; NAA NAA
	LBI R3, scoreAddr_high
	SLBI R3, scoreAddr_low
	SLLI R4, R4, #8
	ST R4, R3, p2Score
	; END NAA NAA

        BNEZ R4, #2
        LBI R1, #3                  ; if starting posZ in non-zero, then it will check the spart
        SLBI R1, #232

        LBI R0, ballAddr
        ST R1, R0, posZ             ; ball->posZ = 0 or 1000

        LBI R0, ballVelAddr
        LBI R2, velz_start
	BNEZ R4, #1
	MULTI R2, R2, #-1
        ST R2, R0, velZ             ; ball->velZ = VELZ_START

SETUP:  
        ; end game checks done here
        LBI R0, scoreAddr_high
        SLBI R0, scoreAddr_low
        LD R3, R0, p1Score          ; r3 <-- playerScore
        SUBI R3, R3, endScore
        BNEZ R3, OPPWINCHK          ; if (playerScore == endScore)
        LBI R4, #1
        LBI R3, gameStateAddr_high
        SLBI R3, gameStateAddr_low
        ST R4, R3, #0               ; set gamestate reg to player 1 win
        LBI R3, #0
        ST R3, R0, p1Score          ; playerScore = 0
	; NAA 
        ;ST R3, R0, p2Score          ; oppScore = 0
	; end NAA
        J CONTINUE
OPPWINCHK: ; end if (playerScore == endScore)
        LD R3, R0, p2Score
        SUBI R3, R3, endScore
        BNEZ R3, CONTINUE           ; if (oppScore == endScore)

        ;/* NAA NAA */
        ;HALT
        ;/* NAA NAA END */

        LBI R0, #2
        LBI R3, gameStateAddr_high
        SLBI R3, gameStateAddr_low
        ST R0, R3, #0               ; set gamestate reg to player 2 win
        LBI R3, #0
        ST R3, R0, p1Score          ; playerScore = 0
	; NAA
        ;ST R3, R0, p2Score          ; oppScore = 0
	; end NAA
        J CONTINUE
CONTINUE:

        LBI R0, #0
        LBI R3, gameStateAddr_high
        SLBI R3, gameStateAddr_low
        ST R0, R3, #0               ; set gamestate reg to game playing
        LBI R0, #1                  
        STI R0, firstAddr           ; first = TRUE
        LBI R0, ballAddr            ; setup the ball
        LBI R1, halfWidth_high      
        SLBI R1, halfWidth_low
        ST R1, R0, posX             ; ball->posX = WIDTH / 2
        LBI R1, halfHeight_high    
        SLBI R1, halfHeight_low     
        ST R1, R0, posY             ; ball->posY = HEIGHT / 2
        LBI R1, #0
        LBI R0, ballVelAddr         
        ST R1, R0, velX             ; ball->velX = 0
        ST R1, R0, velY             ; ball->velY = 0
        ST R1, R0, accX             ; ball->accX = 0
        ST R1, R0, accY             ; ball->accY = 0
        ST R1, R0, xStat            ; ball->xStat = 0
        ST R1, R0, yStat            ; ball->xStat = 0

        ; set difficulty
        LBI R1, #1
        STI R1, difficultyAddr      ; difficulty = 1

        ; check for mouse click here
        ; TODO: cnt could be changed here to get curve off of serve
        ;LBI R6, #20                 ; r6 <-- cnt
WAITCLICK:

        JAL P2UPDATE
        JAL P1UPDATE
        JAL BTRANS

        ; check if the mouse click also was when the paddle was over the ball

        ; check ball->posZ to determine which paddle to check against
        LBI R1, ballAddr            ; r1 <-- ballAddr
        LD R3, R1, posZ             ; r3 <-- ball->posZ
        BEQZ R3, #2                 ; if (ball->posZ != 0) check against paddle2
        LBI R0, paddle2Addr
        J #1
        LBI R0, paddle1Addr

        LBI R2, ballVelAddr         ; r2 <-- ballVelAddr
        LBI R3, INTERSECT_HIGH
        SLBI R3, INTERSECT_LOW
        JALR R3, #0                 ; r0 <-- intersect(paddle2)
        ; r0 <-- sect at this point
		
	;/* NAA NAA */
        LBI R4, scoreAddr_high
        SLBI R4, scoreAddr_low
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
        ST R0, R4, p2Score
        ;/* NAA NAA END */

        ; check whether to look at the mouse or the spart
        LD R3, R1, posZ
        BEQZ R3, #3                 ; if (ball->posZ != 0) check spart
        LBI R3, spartAddr_high
        SLBI R3, spartAddr_low
        J #2
        LBI R3, mouseAddr_high
        SLBI R3, mouseAddr_low      ; r0 <-- load mouse status addr

        LD R1, R3, mStatus          ; r1 <-- get mouse status
        LBI R2, #1                  ; r2 <-- left click mask
        AND R5, R2, R1              ; r3 <-- masked mouse

	;/* NAA NAA */
        LBI R4, scoreAddr_high
        SLBI R4, scoreAddr_low
	LD R3, R4, p2Score
	LBI R1, #-1
	SLBI R1, #240
	AND R3, R3, R1
	OR R6, R3, R5 
        ST R6, R4, p2Score
        ;/* NAA NAA END */
		
        AND R3, R5, R0  
        BNEZ R3, GLOOP              ; if left clicked and paddle intersect, go to game loop
        J WAITCLICK

; loop runs forever updating the game state
GLOOP:  
	; start of a wait loop decrimenting from 20,000 to 0
	LBI R5, #127
	SLBI R5, #255
	LBI R4, #2
GSTALL0:
	BEQZ R5, #2
	SUBI R5, R5, #1
	J GSTALL0

	; start of a wait loop decrimenting from 20,000 to 0
	LBI R5, #127
	SLBI R5, #255
	LBI R4, #2
GSTALL1:
	BEQZ R5, #2
	SUBI R5, R5, #1
	J GSTALL1

        JAL P2UPDATE                ; opp_update()
        JAL P1UPDATE                ; paddle_update()
        JAL BUPDATE                 ; ball_update()

; save off the current location of the paddle #2
P2UPDATE: 

        ; load addrs
        LBI R0, paddle2Addr
        LBI R3, spartAddr_high
        SLBI R3, spartAddr_low
        LBI R4, pPaddle2Addr

	LDI R5, pPad2Cnt
	LBI R6, #20
	SUB R6, R6, R5
	BNEZ R6, NOP2UP
	LBI R5, #0

        LD R1, R0, posX
        LD R2, R0, posY
	NOP
	NOP
	NOP
	NOP
	NOP
        ST R1, R4, posX             ; pPaddle2 = opp->posX
        ST R2, R4, posY             ; pPaddle2 = opp->posY

NOP2UP:
	NOP
	NOP
	NOP
	NOP
	NOP
	ADDI R5, R5, #1
	STI R5, pPad2Cnt

        LD R1, R3, mPosx
        LD R2, R3, mPosy
	NOP
	NOP
	NOP
	NOP
	NOP
        ST R1, R0, posX             ; opponent->posX = spart->posX
        ST R2, R0, posY             ; opponent->posY = spart->posY

        ; translate the paddle2 pos to perspective
        LBI R6, paddle2Tran_high
        SLBI R6, paddle2Tran_low

        ;x value
	LBI R0, width_high
	SLBI R0, width_low
	SUB R1, R0, R1
	LBI R0, paddle_width
	SUB R1, R1, R0	
	;SRAI R1, R1, #2
	;LBI R0, #1
	;SLBI R0, #0
	LBI R0, #64
	ADD R1, R1, R0
        ST R1, R6, posX

        ;y value
	;SRAI R2, R2, #2
	;LBI R0, #0
	;SLBI R0, #192
	LBI R0, #48
	ADD R2, R2, R0
        ST R2, R6, posY             

        JR R7, #0                   ; return

; save off the current location of the paddle #2
P1UPDATE: 
        LBI R0, paddle1Addr

	LDI R6, pPad1Cnt
	LBI R5, #20
	SUB R5, R5, R6
	BNEZ R5, NOP1UP
	LBI R6, #0

        LD R1, R0, posX
        LD R2, R0, posY
        LBI R4, pMouseAddr
	NOP
	NOP
	NOP
	NOP
	NOP
        ST R1, R4, posX             ; pMouse->posX = paddle->posX
        ST R2, R4, posY             ; pMouse->posY = paddle->posY

NOP1UP:
	NOP
	NOP
	NOP
	NOP
	NOP
	ADD R6, R6, #1
	STI R6, pPad1Cnt

        LBI R3, mouseAddr_high
        SLBI R3, mouseAddr_low
        LD R1, R3, mPosx
        LD R2, R3, mPosy
	NOP
	NOP
	NOP
	NOP
	NOP
        ST R1, R0, posX             ; paddle->posX = mouse->posX
        ST R2, R0, posY             ; paddle->posY = mouse->posY

        ; translate the paddle1 to perspective mode
        LBI R0, paddle1Tran_high
        SLBI R0, paddle1Tran_low
        LBI R3, #64
        ADD R1, R1, R3
        ST R1, R0, posX             ; transPaddle1->posX is set
        LBI R3, #48
        ADD R2, R2, R3
        ST R2, R0, posY             ; transPaddle1->posY is set
        JR R7, #0                   ; return
        
BTRANS: 

        ; translate the paddle2 pos to perspective
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
	NOP
	NOP
	
	;LBI R0, width_high
	;SLBI R0, width_low
	;SUB R1, R0, R1
	LBI R0, #64
	ADD R1, R1, R0
	ST R1, R6, posX             ; posX offset by 64
	LBI R0, #48
	ADD R2, R2, R0
	ST R2, R6, posY             ; posY offset by 48
	ST R3, R6, posZ             ; posZ stays the same, stored here

	; NAA NAA
	LBI R0, scoreAddr_high
	SLBI R0, scoreAddr_low
	;ST R3, R0, p1Score
	JR R7, #0
	;end NAA NAA

        ;x value
        LBI R0, #1
        SLBI R0, #0                 ; r0 <-- 256
        SUB R1, R1, R0              ; r1 <-- gameX - 256
        LBI R3, #1
        SLBI R3, #84                ; r3 <-- 340
        LBI R5, #3
        SLBI R5, #232               ; r5 <-- gameZ (1000)
        ADD R5, R5, R3              ; r5 <-- 340 + gameZ

        MULT R4, R3, R1             ; r4 <-- 340 * (gameX - 256)
        BNEZ R4, #3                 ; if overflow is detected, shift and repeat mult
        SRAI R1, R1, #1
        SRAI R5, R5, #1
        MULT R4, R3, R1

        DIV R4, R4, R5              ; r4 <-- (340 * (gameX - 256)) / (340 + gameZ)
        LBI R0, #1
        SLBI R0, #64                ; r0 <-- 320
        ADD R4, R4, R0              ; r4 <-- (340 * (gameX - 256)) / (340 + gameZ) + 320
        ST R4, R6, posX

        ;y value
        LBI R0, #0
        SLBI R0, #192               ; r0 <-- 192
        SUB R2, R2, R0              ; r2 <-- gameY - 192
        LBI R3, #1
        SLBI R3, #84                ; r3 <-- 340
        LBI R5, #3
        SLBI R5, #232               ; r5 <-- gameZ (1000)
        ADD R5, R5, R3              ; r5 <-- 340 + gameZ

        MULT R4, R3, R2             ; r4 <-- 340 * (gameX - 192)
        BNEZ R4, #3                 ; if overflow is detected, shift and repeat mult
        SRAI R2, R2, #1
        SRAI R5, R5, #1
        MULT R4, R3, R2

        DIV R4, R4, R5              ; r4 <-- (340 * (gameX - 192)) / (340 + gameZ)
        LBI R0, #0
        SLBI R0, #240
        ADD R4, R4, R0              ; r4 <-- (340 * (gameX - 192)) / (340 + gameZ) + 240
        ST R4, R6, posY             
        JR R7, #0


; update the ball location and calc the curve for the ball
BUPDATE:   
        JAL BTRANS

        LBI R1, ballAddr            ; r1 <-- ballAddr
        LBI R2, ballVelAddr         ; r2 <-- ballVelAddr
        LBI R3, ENDPBN_HIGH
        SLBI R3, ENDPBN_LOW
        LDI R0, firstAddr           
        BEQZ R0, #1                 ; if (!first) or if (pBall != NULL) in code
        JR R3, #0                   ; go to ENDPBN address 

        LD R4, R1, posZ             ; r4 <-- ball->posZ
        LD R5, R2, velZ             ; r5 <-- ball->velZ
        ADD R4, R4, R5              
        ST R4, R1, posZ             ; ball->posZ += ball->velZ
        
        LBI R5, update
        SUBI R5, R5, #1
        AND R5, R4, R5              ; r5 <-- ball->posZ % UPDATE
        BNEZ R5, ENDMODUP           ; if (ball->posZ % UPDATE == 0)
        LD R0, R2, velX             ; r0 <-- ball->velX
        LD R3, R2, accX             ; r3 <-- ball->accX
        ADD R0, R0, R3              ; r0 <-- ball->velX + ball->accX
        ST R0, R2, velX             ; ball->velX = ball->velX + ball->accX
        BNEZ R0, VELXZ              ; if (ball->velX == 0)
        LBI R4, #0
        SUB R4, R4, R3              ; r4 <-- 0 - ball->accX
        BLEZ R4, VELXZ              ; if (ball->accX < 0)
        LBI R4, #-1
        ST R4, R2, velX             ; ball->velX = -1
VELXZ: ; end if (ball->velX == 0)

        LD R0, R2, velY             ; r0 <-- ball->velY
        LD R3, R2, accY             ; r3 <-- ball->accY
        ADD R0, R0, R3              ; r0 <-- ball->velY + ball->accY
        ST R0, R2, velY             ; ball->velY = ball->velY + ball->accY
        BNEZ R0, ENDMODUP           ; if (ball->velY == 0)
        LBI R4, #0
        SUB R4, R4, R3              ; r4 <-- 0 - ball->accY
        BLEZ R4, ENDMODUP           ; if (ball->accX < 0)
        LBI R4, #-1
        ST R4, R2, velY             ; ball->velY = -1
ENDMODUP: ; end if (ball->posZ % UPDATE == 0)

        LBI R0, update              ; r0 <-- UPDATE
        LD R3, R2, xStat           ; r3 <-- ball->xStat
        SRL R0, R0, R3              ; r0 <-- UPDATE >> ball->xStat
        SUBI R0, R0, #1
        LD R5, R1, posZ             ; r5 <-- ball->posZ
        AND R4, R5, R0              ; r4 <-- ball->posZ % r0
        BNEZ R4, ENDMODSX           ; if (ball->posZ % r0)
        LD R0, R2, velX             ; r0 <-- ball->velX
        SRA R4, R0, R3              ; r4 <-- ball->velX >> ball->xStat
        LD R3, R1, posX             ; r3 <-- ball->posX
        ADD R3, R3, R4
        ;/* NAA NAA */
        ST R3, R1, posX             ; ball->posX = ball->posX + (ball->velX >> ball->xStat)
        ;/* NAA NAA END */

        ;/* NAA NAA */
        ;LBI R4, paddle2Addr
        ;ST R3, R4, posX
        ;LBI R4, pPaddle2Addr
        ;ST R3, R4, posX
        ;/* NAA NAA END */


ENDMODSX: ; end if (ball->posZ % r0)

        LBI R0, update              ; r0 <-- UPDATE
        LD R3, R2, yStat            ; r3 <-- ball->yStat
        SRL R0, R0, R3              ; r0 <-- UPDATE >> ball->yStat
        SUBI R0, R0, #1
        LD R5, R1, posZ             ; r5 <-- ball->posZ
        AND R4, R5, R0              ; r4 <-- ball->posZ % r0
        BNEZ R4, ENDMODSY           ; if (ball->posZ % r0)
        LD R0, R2, velY             ; r0 <-- ball->velY
        SRA R4, R0, R3              ; r4 <-- ball->velY >> ball->yStat
        LD R3, R1, posY             ; r3 <-- ball->posY
        ADD R3, R3, R4
        ;/* NAA NAA */
        ;ST R3, R1, posY             ; ball->posY = ball->posY + (ball->velY >> ball->yStat)
        ;/* NAA NAA END */

        ;/* NAA NAA */
        ;LBI R0, paddle2Addr
        ;ST R3, R0, posY
        ;LBI R0, pPaddle2Addr
        ;ST R3, R0, posY
        ;/* NAA NAA END */

ENDMODSY: ; end if (ball->posZ % r0)
        
ENDPBN: ; end if (pball != NULL)

        ; start of ball and sidewall collisions
        ; expected register contents at this point:
        ; r1 <-- ballAddr 
        ; r2 <-- ballVelAddr

        ; left wall
        LD R0, R1, posX             ; r0 <-- ball->posX
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        SUB R0, R0, R4              ; r0 <-- ball->posX - BALL_RAD
        LBI R3, #0
        SUB R0, R3, R0              ; r0 <-- 0 - (ball->posX - BALL_RAD)
        BLTZ R0, TSTRW              ; if (ball->posX - BALL_RAD <= 0)
        J INRLW

TSTRW:  ; right wall
        LD R0, R1, posX             ; r0 <-- ball->posX
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        ADD R0, R0, R4              ; r0 <-- ball->posX + BALL_RAD
        LBI R3, width_high
        SLBI R3, width_low          ; r3 <-- WIDTH
        SUB R0, R0, R3              ; r0 <-- (ball->posX + BALL_RAD) - WIDTH 
        BLTZ R0, ENDRLW             ; if (ball->posX + BALL_RAD >= WIDTH)

INRLW:
        ; contact with right or left wall, play a sound
        LBI R0, audioAddr_high
        SLBI R0, audioAddr_low      ; r0 <-- audioAddr
        LBI R3, #128
		SLBI R3, #0
        ST R3, R0, #0               ; play the wall hit sound

        ; right wall
        LD R0, R1, posX             ; r0 <-- ball->posX
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        ADD R0, R0, R4              ; r0 <-- ball->posX + BALL_RAD
        LBI R3, width_high
        SLBI R3, width_low          ; r3 <-- WIDTH
        SUB R0, R0, R3              ; r0 <-- (ball->posX + BALL_RAD) - WIDTH 
        BLTZ R0, ENDIFRW            ; if (ball->posX + BALL_RAD >= WIDTH)
        LBI R0, width_high
        SLBI R0, width_low          ; r0 <-- WIDTH
        LBI R3, ball_rad
        SUB R3, R0, R3              ; r3 <-- WIDTH - BALL_RAD
        SUBI R3, R3, #1
        ST R3, R1, posX             ; ball->posX = WIDTH - BALL_RAD - 1

        ;/* NAA NAA */
        ;LBI R0, paddle2Addr
        ;ST R3, R0, posX
        ;LBI R0, pPaddle2Addr
        ;ST R3, R0, posX
        ;/* NAA NAA END */

        J ENDIFLW
ENDIFRW: ; end if (ball->posX + BALL_RAD >= WIDTH)

        LBI R0, ball_rad
        ADDI R0, R0, #1
        ST R0, R1, posX             ; ball->posX = BALL_RAD + 1

        ;/* NAA NAA */
        ;LBI R3, paddle2Addr
        ;ST R0, R3, posX
        ;LBI R3, pPaddle2Addr
        ;ST R0, R3, posX
        ;/* NAA NAA END */

ENDIFLW:
        LD R0, R2, velX             ; r0 <-- ball->velX
	NOP
	NOP
	NOP
	NOP
	NOP
        MULTI R0, R0, #-1
        ST R0, R2, velX             ; ball->velX *= -1
ENDRLW: ; end if ((ball->posX + BALL_RAD >= WIDTH) || (ball->posX - BALL_RAD <= 0))

        ; top wall
        LD R0, R1, posY             ; r0 <-- ball->posY
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        SUB R0, R0, R4              ; r0 <-- ball->posY - BALL_RAD
        LBI R3, #0
        SUB R0, R3, R0              ; r0 <-- 0 - (ball->posY - BALL_RAD)
        BLTZ R0, TSTBW              ; if (ball->posX - BALL_RAD <= 0)
        J INTBW
TSTBW:
        ; bottom wall
        LD R0, R1, posY             ; r0 <-- ball->posY
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        ADD R0, R4, R0              ; r0 <-- ball->posY + BALL_RAD
        LBI R3, height_high
        SLBI R3, height_low         ; r3 <-- HEIGHT
        SUB R0, R0, R3              ; r0 <-- (ball->posX + BALL_RAD) - HEIGHT
        BLTZ R0, ENDTBW             ; if (ball->posX + BALL_RAD >= HEIGHT)

INTBW:
        ; contact with top or bottom wall, play a sound
        LBI R0, audioAddr_high
        SLBI R0, audioAddr_low      ; r0 <-- audioAddr
        LBI R3, #128
		SLBI R3, #4
		ST R3, R0, #4               ; play the wall hit sound

        ; top wall
        LD R0, R1, posY             ; r0 <-- ball->posY
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        SUB R0, R0, R4              ; r0 <-- ball->posY - BALL_RAD
        LBI R3, #0
        SUB R0, R3, R0              ; r0 <-- 0 - (ball->posY - BALL_RAD)
        BLTZ R0, ENDIFTW            ; if (ball->posX - BALL_RAD <= 0)
        LBI R0, ball_rad            ; r0 <-- BALL_RAD
        ADDI R0, R0, #1
        ST R0, R1, posY             ; ball->posY = BALL_RAD + 1

        ;/* NAA NAA */
        ;LBI R3, paddle2Addr
        ;ST R0, R3, posY
        ;LBI R3, pPaddle2Addr
        ;ST R0, R3, posY
        ;/* NAA NAA END */

        J ENDIFBW
ENDIFTW:
        LBI R0, height_high
        SLBI R0, height_low         ; r0 <-- HEIGHT
        LBI R3, ball_rad
        SUB R3, R0, R3              ; r0 <-- HEIGHT - BALL_RAD
        SUBI R3, R3, #1
        ST R3, R1, posY             ; ball->posY = HEIGHT - BALL_RAD - 1

        ;/* NAA NAA */
        ;LBI R0, paddle2Addr
        ;ST R3, R0, posY
        ;LBI R0, pPaddle2Addr
        ;ST R3, R0, posY
        ;/* NAA NAA END */

ENDIFBW:
        LD R0, R2, velY            ; r0 <-- ball->velY
	NOP
	NOP
	NOP
	NOP
	NOP
        MULTI R0, R0, #-1
        ST R0, R2, velY             ; ball->velY *= -1
ENDTBW: ; end if ((ball->posX + BALL_RAD >= HEIGHT) || (ball->posX - BALL_RAD <= 0))

        ; start of ball and player/opp wall collisions
        ; expected register contents at this point:
        ; r1 <-- ballAddr 
        ; r2 <-- ballVelAddr

        ; ball and player wall collision
        LD R0, R1, posZ             ; r0 <-- ball->posZ
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        SUB R0, R0, R4              ; r0 <-- ball->posZ - BALL_RAD
        LBI R3, #0
        SUB R0, R3, R0              ; r0 <-- 0 - (ball->posZ - BALL_RAD)
        BLTZ R0, #1                 ; if (ball->posZ - BALL_RAD <= 0)
        J #3
        LBI R3, ENDPW_HIGH
        SLBI R3, ENDPW_LOW
        JR R3, #0                   ; jump to label ENDPW

        LBI R0, paddle1Addr         ; r0 <-- paddle1Addr
        LBI R3, INTERSECT_HIGH
        SLBI R3, INTERSECT_LOW
        JALR R3, #0                 ; r0 <-- intersect(paddle)
        ; r0 <-- sect at this point

        LDI R3, firstAddr           ; r3 <-- first
        OR R4, R3, R0               ; r4 <-- sect || first
        BEQZ R4, #1                 ; if (sect || first)
        J #3
        LBI R4, NOINTRP_HIGH
        SLBI R4, NOINTRP_LOW
        JR R4, #0

        ; contact with paddle, play a sound
        LBI R0, audioAddr_high
        SLBI R0, audioAddr_low      ; r0 <-- audioAddr
        LBI R4, #128
        SLBI R4, #0           		; r3 <-- r3 has a 1 in the most significant bit
        ST R4, R0, #0               ; play the wall hit sound

        LBI R4, ball_rad
        ADDI R4, R4, #1
        ST R4, R1, posZ             ; ball->posZ = BALL_RAD + 1

        ; start of setting velX, accX, and xStat based on the mouse movement
        LBI R4, mouseAddr_high
        SLBI R4, mouseAddr_low      ; r4 <-- mouseAddr
        LBI R5, pMouseAddr          ; r5 <-- pMouseAddr

        BEQZ R3, INTRPNFX           ; if (first)
        LBI R0, velz_start
        ST R0, R2, velZ             ; ball->velZ = VELZ_START
        LD R3, R4, mPosx            ; r3 <-- mouse->posX
        LD R6, R5, posX             ; r6 <-- pmouse->posX
        SUB R6, R3, R6              ; r6(mouseDiff) <-- mouse->posX - pmouse->posX
        J INTRPNX_ELSE
INTRPNFX: ; end if (first)

        ; else of if (first)
        LD R0, R2, velZ             ; r0 <-- ball->velZ
	NOP
	NOP
	NOP
	NOP
	NOP
        MULTI R0, R0, #-1           ; r0 <-- ball->velZ * -1
        ;LDI R3, difficultyAddr      ; r3 <-- difficulty
        ;ADD R0, R0, R3
        ST R0, R2, velZ             ; ball->velZ = (ball->velZ * -1) + difficulty

        LD R0, R5, posX             ; r0 <-- pmouse->posX
        LD R3, R4, mPosx            ; r3 <-- mouse->posX

	; NAA NAA
	LBI R7, scoreAddr_high
	SLBI R7, scoreAddr_low
	ST R0, R7, p2Score
	ST R3, R7, p1Score
	; end NAA NAA

        SUB R3, R3, R0              ; r3 <-- mouse->posX - pmouse->posX
        LD R0, R2, velX             ; r0 <-- ball->velX
        ADD R6, R0, R3              ; r6(mouseDiff) <-- (mouse->posX - pmouse->posX) + ball->velX 
INTRPNX_ELSE: ; end of else if (first)
        ; r6 has mouseDiff at this point
        
        LBI R0, #0
        SUB R0, R6, R0              ; r0 <-- mouseDiff - 0
        BLTZ R0, #2
        LBI R5, #1
        J #2
        MULTI R6, R6, #-1           ; mouseDiff *= -1
        LBI R5, #-1
        ; r6: mouseDiff, r5: mouseDir


        BEQZ R6, MTSTEX0            ; if (mouseDiff != 0)

        LBI R0, #30
        SUB R0, R0, R6              ; r0 <-- 30 - mouseDiff
        BLTZ R0, MTSTLX30           ; if (mouseDiff <= 30)
        MULTI R0, R5, stat_vel_1   ; r0 <-- VEL1 * mouseDir
        ST R0, R2, velX             ; ball->velX = VEL1 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accX             ; ball->accX = -1 * ball->velX
        LBI R0, static1
        ST R0, R2, xStat            ; ball->xStat = STATIC1
        J MTSTEX0
MTSTLX30: ; end if (mouseDiff <= 30)

        LBI R0, #60
        SUB R0, R0, R6              ; r0 <-- 60 - mouseDiff
        BLTZ R0, MTSTLX60           ; if (mouseDiff <= 60)
        MULTI R0, R5, stat_vel_2   ; r0 <-- VEL2 * mouseDir
        ST R0, R2, velX             ; ball->velX = VEL2 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accX             ; ball->accX = -1 * ball->velX
        LBI R0, static2
        ST R0, R2, xStat            ; ball->xStat = STATIC2
        J MTSTEX0
MTSTLX60: ; end if (mouseDiff <= 60)

        LBI R0, #90
        SUB R0, R0, R6              ; r0 <-- 90 - mouseDiff
        BLTZ R0, MTSTLX90           ; if (mouseDiff <= 90)
        MULTI R0, R5, stat_vel_3   ; r0 <-- VEL3 * mouseDir
        ST R0, R2, velX             ; ball->velX = VEL3 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accX             ; ball->accX = -1 * ball->velX
        LBI R0, static3
        ST R0, R2, xStat            ; ball->xStat = STATIC3
        J MTSTEX0
MTSTLX90: ; end if (mouseDiff <= 90)

        MULTI R0, R5, stat_vel_4   ; r0 <-- VEL4 * mouseDir
        ST R0, R2, velX             ; ball->velX = VEL4 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accX             ; ball->accX = -1 * ball->velX
        LBI R0, static4
        ST R0, R2, xStat            ; ball->xStat = STATIC4

MTSTEX0: ; end if (mouseDiff != 0)

  
        ; start of setting velY, accY, and yStat based on the mouse movement
        LBI R4, mouseAddr_high
        SLBI R4, mouseAddr_low      ; r4 <-- mouseAddr
        LBI R5, pMouseAddr          ; r5 <-- pMouseAddr

        LDI R3, firstAddr
        BEQZ R3, INTRPNFY           ; if (first)
        LBI R3, #0
        STI R3, firstAddr           ; first = FALSE
        LD R3, R4, mPosy            ; r3 <-- mouse->posY
        LD R6, R5, posY             ; r6 <-- pmouse->posY
        SUB R6, R3, R6              ; r6(mouseDiff) <-- mouse->posY - pmouse->posY
        J INTRPNY_ELSE
INTRPNFY: ; end if (first)

        ; else of if (first)
        LD R0, R5, posY             ; r0 <-- pmouse->posY
        LD R3, R4, mPosy            ; r3 <-- mouse->posY
        SUB R3, R3, R0              ; r3 <-- mouse->posY - pmouse->posY
        LD R0, R2, velY             ; r0 <-- ball->velY
        ADD R6, R0, R3              ; r6(mouseDiff) <-- (mouse->posY - pmouse->posY) + ball->velY 
INTRPNY_ELSE: ; end of else if (first)
        ; r6 has mouseDiff at this point
        
        LBI R0, #0
        SUB R0, R6, R0              ; r0 <-- mouseDiff - 0
        BLTZ R0, #2
        LBI R5, #1
        J #2
        MULTI R6, R6, #-1           ; mouseDiff *= -1
        LBI R5, #-1
        ; r6: mouseDiff, r5: mouseDir

        BEQZ R6, MTSTEY0            ; if (mouseDiff != 0)

        LBI R0, #30
        SUB R0, R0, R6              ; r0 <-- 30 - mouseDiff
        BLTZ R0, MTSTLY30           ; if (mouseDiff <= 30)
        MULTI R0, R5, stat_vel_1    ; r0 <-- VEL1 * mouseDir
        ST R0, R2, velY             ; ball->velY = VEL1 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accY             ; ball->accY = -1 * ball->velY
        LBI R0, static1
        ST R0, R2, yStat            ; ball->yStat = STATIC1
        J MTSTEY0
MTSTLY30: ; end if (mouseDiff <= 30)

        LBI R0, #60
        SUB R0, R0, R6              ; r0 <-- 60 - mouseDiff
        BLTZ R0, MTSTLY60           ; if (mouseDiff <= 60)
        MULTI R0, R5, stat_vel_2    ; r0 <-- VEL2 * mouseDir
        ST R0, R2, velY             ; ball->velY = VEL2 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accY             ; ball->accY = -1 * ball->velY
        LBI R0, static2
        ST R0, R2, yStat            ; ball->yStat = STATIC2
        J MTSTEY0
MTSTLY60: ; end if (mouseDiff <= 60)

        LBI R0, #90
        SUB R0, R0, R6              ; r0 <-- 90 - mouseDiff
        BLTZ R0, MTSTLY90           ; if (mouseDiff <= 90)
        MULTI R0, R5, stat_vel_3    ; r0 <-- VEL3 * mouseDir
        ST R0, R2, velY             ; ball->velY = VEL3 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accY             ; ball->accY = -1 * ball->velY
        LBI R0, static3
        ST R0, R2, yStat            ; ball->yStat = STATIC3
        J MTSTEY0
MTSTLY90: ; end if (mouseDiff <= 90)

        MULTI R0, R5, stat_vel_4    ; r0 <-- VEL4 * mouseDir
        ST R0, R2, velY             ; ball->velY = VEL4 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accY             ; ball->accY = -1 * ball->velY
        LBI R0, static4
        ST R0, R2, yStat            ; ball->yStat = STATIC4

MTSTEY0: ; end if (mouseDiff != 0)
        J ENDOW
NOINTRP: ; end if (sect || first)

        ; contact with wall, play a sound
        LBI R0, audioAddr_high
        SLBI R0, audioAddr_low      ; r0 <-- audioAddr
        LBI R3, #128
        SLBI R3, #8            		; r3 <-- r3 has a 1 in the most significant bit
        ST R3, R0, #0              ; play the score sound
        
        LBI R0, scoreAddr_high
        SLBI R0, scoreAddr_low
        LD R3, R0, p2Score
        ADDI R3, R3, #1
        ;/* NAA NAA */
        ;ST R3, R0, p2Score          ; oppScore++
        ;/* NAA NAA END */
        LBI R0, #0
        ST R0, R1, posZ             ; ball->posZ = 0
        LBI R0, velz_start
        ST R0, R2, velZ             ; ball->velZ = VELZ_START

        ; now go to setup() to reset initial values and wait for a player click
        LBI R0, SETUP_HIGH
        SLBI R0, SETUP_LOW
        JR R0, #0                   ; jump to SETUP
ENDPW: ; end if (ball->posZ - BALL_RAD <= 0)

        LD R0, R1, posZ             ; r0 <-- ball->posZ
        LBI R3, ball_rad            ; r3 <-- BALL_RAD
        ADD R0, R0, R3              ; r0 <-- ball->posZ + ball_rad
        LBI R3, depth_high
        SLBI R3, depth_low          ; r3 <-- depth
        SUB R0, R0, R3
        BLTZ R0, #1                 ; if (ball->posZ + BALL_RAD >= DEPTH)
        J #3
        LBI R0, ENDOW_HIGH
        SLBI R0, ENDOW_LOW
        JR R0, #0

        LBI R0, paddle2Addr
        LBI R3, INTERSECT_HIGH
        SLBI R3, INTERSECT_LOW
        JALR R3, #0                 ; r0 <-- intersect(paddle2)
        ; r0 <-- sect at this point

        LDI R3, firstAddr           ; r3 <-- first
        OR R0, R0, R3
        BEQZ R0, #1                 ; if (intersect(opponent) || first)
        J #3
        LBI R0, ENDINTROW_HIGH
        SLBI R0, ENDINTROW_LOW
        JR R0, #0

        ; contact with wall, play a sound
        LBI R0, audioAddr_high
        SLBI R0, audioAddr_low      ; r0 <-- audioAddr
        LBI R3, #1
        SLLI R3, R3, #15            ; r3 <-- r3 has a 1 in the most significant bit
        ST R3, R0, #0               ; play the wall hit sound

        LBI R0, depth_high
        SLBI R0, depth_low          ; r0 <-- DEPTH
        LBI R3, ball_rad            ; r3 <-- BALL_RAD
        SUB R0, R0, R3              ; r0 <-- DEPTH - BALL_RAD
        SUBI R0, R0, #1
        ST R0, R1, posZ             ; ball->posZ = DEPTH - BALL_RAD - 1

        ; start of setting velX, accX, and xStat based on the mouse movement
        LBI R4, paddle2Addr         ; r4 <-- paddle2Addr (opponent)
        LBI R5, pPaddle2Addr        ; r5 <-- pPaddle2Addr (popponent)
        LDI R3, firstAddr

        BEQZ R3, INTRONFX           ; if (first)
        LBI R0, velz_start
        MULTI R0, R0, #-1
        ST R0, R2, velZ             ; ball->velZ = VELZ_START * -1
        LD R3, R4, posX             ; r3 <-- opponent->posX
        LD R6, R5, posX             ; r6 <-- popponent->posX
        SUB R6, R3, R6              ; r6(mouseDiff) <-- opponent->posX - popponent->posX
        J INTRONX_ELSE
INTRONFX: ; end if (first)

        ; else of if (first)
        LD R0, R2, velZ             ; r0 <-- ball->velZ
        ;LDI R3, difficultyAddr      ; r3 <-- difficulty
        ;ADD R0, R0, R3
        MULTI R0, R0, #-1           ; r0 <-- ball->velZ * -1
	NOP
	NOP
	NOP
	NOP
	NOP
        ST R0, R2, velZ             ; ball->velZ = (ball->velZ * -1) + difficulty

        LD R0, R5, posX             ; r0 <-- popponent->posX
        LD R3, R4, posX             ; r3 <-- opponent->posX
        SUB R3, R3, R0              ; r3 <-- opponent->posX - popponent->posX
        LD R0, R2, velX             ; r0 <-- ball->velX
        ADD R6, R0, R3              ; r6(mouseDiff) <-- (opponent->posX - popponent->posX) + ball->velX 
INTRONX_ELSE: ; end of else if (first)
        ; r6 has mouseDiff at this point
        
        LBI R0, #0
        SUB R0, R6, R0              ; r0 <-- mouseDiff - 0
        BLTZ R0, #2
        LBI R5, #1
        J #2
        MULTI R6, R6, #-1           ; mouseDiff *= -1
        LBI R5, #-1
        ; r6: mouseDiff, r5: mouseDir

        BEQZ R6, MOTSTEX0            ; if (mouseDiff != 0)

        LBI R0, #30
        SUB R0, R0, R6              ; r0 <-- 30 - mouseDiff
        BLTZ R0, MOTSTLX30           ; if (mouseDiff <= 30)
        MULTI R0, R5, stat_vel_1   ; r0 <-- VEL1 * mouseDir
        ST R0, R2, velX             ; ball->velX = VEL1 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accX             ; ball->accX = -1 * ball->velX
        LBI R0, static1
        ST R0, R2, xStat            ; ball->xStat = STATIC1
        J MOTSTEX0
MOTSTLX30: ; end if (mouseDiff <= 30)

        LBI R0, #60
        SUB R0, R0, R6              ; r0 <-- 60 - mouseDiff
        BLTZ R0, MOTSTLX60           ; if (mouseDiff <= 60)
        MULTI R0, R5, stat_vel_2   ; r0 <-- VEL2 * mouseDir
        ST R0, R2, velX             ; ball->velX = VEL2 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accX             ; ball->accX = -1 * ball->velX
        LBI R0, static2
        ST R0, R2, xStat            ; ball->xStat = STATIC2
        J MOTSTEX0
MOTSTLX60: ; end if (mouseDiff <= 60)

        LBI R0, #90
        SUB R0, R0, R6              ; r0 <-- 90 - mouseDiff
        BLTZ R0, MOTSTLX90           ; if (mouseDiff <= 90)
        MULTI R0, R5, stat_vel_3   ; r0 <-- VEL3 * mouseDir
        ST R0, R2, velX             ; ball->velX = VEL3 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accX             ; ball->accX = -1 * ball->velX
        LBI R0, static3
        ST R0, R2, xStat            ; ball->xStat = STATIC3
        J MOTSTEX0
MOTSTLX90: ; end if (mouseDiff <= 90)

        MULTI R0, R5, stat_vel_4   ; r0 <-- VEL4 * mouseDir
        ST R0, R2, velX             ; ball->velX = VEL4 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accX             ; ball->accX = -1 * ball->velX
        LBI R0, static4
        ST R0, R2, xStat            ; ball->xStat = STATIC4

MOTSTEX0: ; end if (mouseDiff != 0)

  
        ; start of setting velY, accY, and yStat based on the mouse movement
        LBI R4, paddle2Addr         ; r4 <-- paddle2Addr (opponent)
        LBI R5, pPaddle2Addr          ; r5 <-- pPaddle2Addr (popponent)

        BEQZ R3, INTRONFY           ; if (first)
        LBI R3, #0
        STI R3, firstAddr           ; first = FALSE
        LD R3, R4, posY             ; r3 <-- opponent->posY
        LD R6, R5, posY             ; r6 <-- popponent->posY
        SUB R6, R3, R6              ; r6(mouseDiff) <-- opponent->posY - popponent->posY
        J INTRONY_ELSE
INTRONFY: ; end if (first)

        ; else of if (first)
        LD R0, R5, posY             ; r0 <-- popponent->posY
        LD R3, R4, posY             ; r3 <-- opponent->posY
        SUB R3, R3, R0              ; r3 <-- opponent->posY - popponent->posY
        LD R0, R2, velY             ; r0 <-- ball->velY
        ADD R6, R0, R3              ; r6(mouseDiff) <-- (opponent->posY - popponent->posY) + ball->velY 
INTRONY_ELSE: ; end of else if (first)
        ; r6 has mouseDiff at this point
        
        LBI R0, #0
        SUB R0, R6, R0              ; r0 <-- mouseDiff - 0
        BLTZ R0, #2
        LBI R5, #1
        J #2
        MULTI R6, R6, #-1           ; mouseDiff *= -1
        LBI R5, #-1
        ; r6: mouseDiff, r5: mouseDir

        BEQZ R6, MOTSTEY0            ; if (mouseDiff != 0)

        LBI R0, #30
        SUB R0, R0, R6              ; r0 <-- 30 - mouseDiff
        BLTZ R0, MOTSTLY30           ; if (mouseDiff <= 30)
        MULTI R0, R5, stat_vel_1    ; r0 <-- VEL1 * mouseDir
        ST R0, R2, velY             ; ball->velY = VEL1 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accY             ; ball->accY = -1 * ball->velY
        LBI R0, static1
        ST R0, R2, yStat            ; ball->yStat = STATIC1
        J MOTSTEY0
MOTSTLY30: ; end if (mouseDiff <= 30)

        LBI R0, #60
        SUB R0, R0, R6              ; r0 <-- 60 - mouseDiff
        BLTZ R0, MOTSTLY60           ; if (mouseDiff <= 60)
        MULTI R0, R5, stat_vel_2    ; r0 <-- VEL2 * mouseDir
        ST R0, R2, velY             ; ball->velY = VEL2 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accY             ; ball->accY = -1 * ball->velY
        LBI R0, static2
        ST R0, R2, yStat            ; ball->yStat = STATIC2
        J MOTSTEY0
MOTSTLY60: ; end if (mouseDiff <= 60)

        LBI R0, #90
        SUB R0, R0, R6              ; r0 <-- 90 - mouseDiff
        BLTZ R0, MOTSTLY90           ; if (mouseDiff <= 90)
        MULTI R0, R5, stat_vel_3    ; r0 <-- VEL3 * mouseDir
        ST R0, R2, velY             ; ball->velY = VEL3 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accY             ; ball->accY = -1 * ball->velY
        LBI R0, static3
        ST R0, R2, yStat            ; ball->yStat = STATIC3
        J MOTSTEY0
MOTSTLY90: ; end if (mouseDiff <= 90)

        MULTI R0, R5, stat_vel_4    ; r0 <-- VEL4 * mouseDir
        ST R0, R2, velY             ; ball->velY = VEL4 * mouseDir
        MULTI R0, R0, #-1
        ST R0, R2, accY             ; ball->accY = -1 * ball->velY
        LBI R0, static4
        ST R0, R2, yStat            ; ball->yStat = STATIC4

MOTSTEY0: ; end if (mouseDiff != 0)

        J ENDOW
ENDINTROW: ; end if (intersect(opponent) || first)

        ; contact with wall, play a sound
        LBI R0, audioAddr_high
        SLBI R0, audioAddr_low      ; r0 <-- audioAddr
        LBI R3, #128
        SLBI R3, #8            ; r3 <-- r3 has a 1 in the most significant bit
        ST R3, R0, #0               ; play the wall hit sound

        LBI R0, scoreAddr_high
        SLBI R0, scoreAddr_low      ; r0 <-- scoreAddr
        LD R3, R0, #0
        ADDI R3, R3, #1
        ;;/* NAA NAA */
        ;ST R3, R0, p1Score          ; playerScore++
        ;/* NAA NAA END */
        LBI R0, depth_high
        SLBI R0, depth_low
        ST R0, R1, posZ             ; ball->posZ = DEPTH
        LBI R0, velz_start
        MULTI R0, R0, #-1
        ST R0, R2, velZ             ; ball->velZ = VELZ_START * -1

        ; now go to setup() to reset initial values and wait for a player click
        LBI R0, SETUP_HIGH
        SLBI R0, SETUP_LOW
        JR R0, #0                   ; jump to SETUP
        
ENDOW: ; end if (ball->posZ + BALL_RAD >= DEPTH)

        ; this is a spining loop used to stall the calculation of the game state
        ;LBI R0, stallCnt_high
        ;SLBI R0, stallCnt_low
        ;BEQZ R0, #1
        ;SUBI R0, R0, #1

        LBI R0, GLOOP_HIGH
        SLBI R0, GLOOP_LOW
        JR R0, #0

; intersect(PAD_t * p) 
; p is passed through R0, and true/false is returned through R0
; R1 and R2 are not modified by this function and are assumed as follows
; r1 <-- ballAddr
; r2 <-- ballVelAddr
; TODO: could use set less than instructions here? maybe more efficent
INTERSECT: 

        LD R3, R1, posX             ; r3 <-- ball->posX
        LBI R4, ball_rad
        ADD R4, R3, R4              ; r4 <-- ball->posX + BALL_RAD
        LD R5, R0, posX             ; r5 <-- p->posX
        SUB R6, R4, R5              ; r6 <-- ball->posX + BALL_RAD - p->posX
        BLTZ R6, RETINTRF           ; if (ball->posX + BALL_RAD >= p->posX)

        LBI R4, ball_rad
        SUB R4, R3, R4              ; r4 <-- ball->posX - BALL_RAD
        LBI R6, paddle_width
        ADD R6, R5, R6              ; r6 <-- p->posX + PAD_WIDTH
        SUB R6, R6, R4              ; r6 <-- (p->posX + PAD_WIDTH) - (ball->posX - BALL_RAD)
        BLTZ R6, RETINTRF           ; if (ball->posX - BALL_RAD <= p->posX + PAD_WIDTH)

        LD R3, R1, posY             ; r3 <-- ball->posY
        LBI R4, ball_rad
        ADD R4, R3, R4              ; r4 <-- ball->posY + BALL_RAD
        LD R5, R0, posY             ; r5 <-- p->posY
        SUB R6, R4, R5              ; r6 <-- ball->posY + BALL_RAD - p->posY
        BLTZ R6, RETINTRF           ; if (ball->posY + BALL_RAD >= p->posY)

        LBI R4, ball_rad
        SUB R4, R3, R4              ; r4 <-- ball->posY - BALL_RAD
        LBI R6, paddle_height
        ADD R6, R5, R6              ; r6 <-- p->posY + PAD_HEIGHT
        SUB R6, R6, R4              ; r6 <-- (p->posY + PAD_HEIGHT) - (ball->posY - BALL_RAD)
        BLTZ R6, RETINTRF           ; if (ball->posY - BALL_RAD <= p->posY + PAD_HEIGHT)

        LBI R0, #1                  ; return TRUE
        JR R7, #0
RETINTRF:        
        LBI R0, #0
        JR R7, #0
