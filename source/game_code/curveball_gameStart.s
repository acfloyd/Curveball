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

;void main()
; start by setting up the initial object positions
MAIN:   LBI R0, scoreAddr_high
        SLBI R0, scoreAddr_low
        LBI R1, #0
        ST R1, R0, p1Score          ; playerScore = 0
        ST R1, R0, p2Score          ; oppScore = 0

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
        ST R3, R0, p2Score          ; oppScore = 0
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
        ST R3, R0, p2Score          ; oppScore = 0
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
	LD R3, R4, p2Score
	LBI R5, #-1
	SLBI R5, #0
	AND R3, R3, R5
	SLLI R6, R0, #4
	OR R6, R3, R6 
        ST R6, R4, p2Score
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

        LD R1, R0, posX
        LD R2, R0, posY
        ST R1, R4, posX             ; pPaddle2 = opp->posX
        ST R2, R4, posY             ; pPaddle2 = opp->posY

        LD R1, R3, mPosx
        LD R2, R3, mPosy
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
        SRAI R1, R1, #2
		LBI R0, #1
		SLBI R0, #0
		ADD R1, R1, R0
        ST R1, R6, posX

        ;y value
		SRAI R2, R2, #2
		LBI R0, #0
		SLBI R0, #192
		ADD R2, R2, R0
        ST R2, R6, posY             

        JR R7, #0                   ; return

; save off the current location of the paddle #2
P1UPDATE: 

        LBI R0, paddle1Addr
        LD R1, R0, posX
        LD R2, R0, posY
        LBI R4, pMouseAddr
        ST R1, R4, posX             ; pMouse->posX = paddle->posX
        ST R2, R4, posY             ; pMouse->posY = paddle->posY
        LBI R3, mouseAddr_high
        SLBI R3, mouseAddr_low
        LD R1, R3, mPosx
        LD R2, R3, mPosy
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
	; NAA NAA
	LBI R0, scoreAddr_high
	SLBI R0, scoreAddr_low
	ST R3, R0, p1Score
	;end NAA NAA
        ST R3, R6, posZ             ; posZ stays the same, stored here


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
		
	LBI R0, ballAddr
	LBI R1, ballVelAddr
	LD R2, R0, posZ
	LD R3, R1, velZ
	ADD R2, R2, R1
	ST R2, R0, posZ

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
