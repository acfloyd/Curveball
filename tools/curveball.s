; assembly file containing the Curveball game code

; game defines
MACRO true #1
MACRO false #0
MACRO height_low #128
MACRO height_high #1    ; height = 384
MACRO halfHeight_high #0
MACRO halfHeight_low #192
MACRO width_low #0
MACRO width_high #2     ; width = 512
MACRO halfWidth_low #0 ; half_width = 256
MACRO halfWidth_high #1
MACRO depth_high #3
MACRO depth_low #232

MACRO stallCnt_high #127
MACRO stallCnt_low #255 ; cnt = 32767, 0x7FFF

MACRO ball_rad #35
MACRO curve_reduce #20
MACRO paddle_width #101
MACRO paddle_height #75
MACRO velz_inc #20

; global var bases
MACRO pBallAddr #0
MACRO ballAddr_low #8
MACRO ballAddr_high #16             ; 4104
MACRO ballVelAddr #3
MACRO paddle2Addr_low #4
MACRO paddle2Addr_high #16          ; 4100
MACRO paddle1Addr_low #0
MACRO paddle1Addr_high #16          ; 4096
MACRO mouseAddr_low #0
MACRO mouseAddr_high #64            ; 16384
MACRO pMouseAddr #8
MACRO pPaddle2Addr #10
MACRO scoreAddr_low #14
MACRO scoreAddr_high #16            ; 4110
MACRO gameStateAddr_low #18
MACRO gameStateAddr_high #16        ; 4114
MACRO difficultyAddr #12
MACRO firstAddr #13

; offset from global var base
MACRO posX #0
MACRO posY #1
MACRO posZ #2
MACRO velX #0
MACRO velY #1
MACRO velZ #2
MACRO dirX #3
MACRO dirY #4
MACRO p1Score #0
MACRO p2Score #1

; extra memory needed to hold mapped global variables
; addresses are for general purpose mem
; 0: pBall x, y, z
; 3: ball vel x, y, z and dir x, y
; 8: pMouse x, y
; 10: pPaddle2 x and y
; 12: difficulty
; 13: first

; TODO: maybe use a register as a stack pointer?

;void main()
; start by setting up the initial object positions
MAIN:   
        LBI R0, #1                  ; first = TRUE
        STI R0, firstAddr
        LBI R0, ballAddr_high       ; setup the ball
        SLBI R0, ballAddr_low
        LBI R1, halfWidth_high     ; ball->posX = WIDTH / 2
        SLBI R1, halfWidth_low
        ST R1, R0, posX
        LBI R1, halfHeight_high    
        SLBI R1, halfHeight_low    ; ball->posY = HEIGHT / 2
        ST R1, R0, posY
        LBI R1, #0                  ; ball->posZ = 0
        ST R1, R0, posZ
        LBI R0, ballVelAddr         ; ball->velX = 0
        ST R1, R0, velX
        ST R1, R0, velY             ; ball->velY = 0
        LBI R1, #1                  ; ball->velZ = 1
        ST R1, R0, velZ
        ST R1, R0, dirX             ; ball->dirX = 1
        ST R1, R0, dirY             ; ball->dirY = 1
        
        ; setup paddle 2
        ; TODO: update paddle through communication between boards
        LBI R0, paddle2Addr_high
        SLBI R0, paddle2Addr_low
        LBI R1, halfWidth_high     ; opponent->posX = WIDTH / 2
        SLBI R1, halfWidth_low
        ST R1, R0, posX
        LBI R1, halfHeight_high    
        SLBI R1, halfHeight_low    ; opponent->posY = HEIGHT / 2
        ST R1, R0, posY

        ; setup paddle 1
        LBI R0, paddle1Addr_high
        SLBI R0, paddle1Addr_low    
        ST R1, R0, posY             ; paddle->posY = HEIGHT / 2
        LBI R1, halfWidth_high     ; paddle->posX = WIDTH / 2
        SLBI R1, halfWidth_low
        ST R1, R0, posX

        ; save off the current mouse location in memory to be compared later
        LBI R0, mouseAddr_high
        SLBI R0, mouseAddr_low
        LD R1, R0, posX
        LD R2, R0, posY
        LBI R0, pMouseAddr
        ST R1, R0, posX             ; pmouse->posX = mouse->posX
        ST R2, R0, posY             ; pmouse->posY = mouse->posY

        ; set starting scores
        LBI R0, scoreAddr_high
        SLBI R0, scoreAddr_low
        LBI R1, #0
        ST R1, R0, p1Score          ; playerScore = 0
        ST R1, R0, p2Score          ; oppScore = 0
        LBI R0, difficultyAddr      ; difficulty = 1
        LBI R1, #1
        ST R1, R0, #0

; loop runs forever updating the game state
GLOOP:  
        JAL P2UPDATE                ; opp_update()
        JAL P1UPDATE                ; paddle_update()
        JAL BUPDATE                 ; ball_update()

; save off the current location of the paddle #2
P2UPDATE: 
        LBI R0, paddle2Addr_high
        SLBI R0, paddle2Addr_low
        LD R1, R0, posX
        LD R2, R0, posY
        LBI R0, pPaddle2Addr
        ST R1, R0, posX             ; pPaddle2 = opp->posX
        ST R2, R0, posY             ; pPaddle2 = opp->posY
        JR R7, #0                   ; return

; save off the current location of the paddle #2
P1UPDATE: 
        LBI R0, paddle1Addr_high
        SLBI R0, paddle1Addr_low
        LD R1, R0, posX
        LD R2, R0, posY
        LBI R4, pMouseAddr
        ST R1, R4, posX             ; pMouse->posX = paddle->posX
        ST R2, R4, posY             ; pMouse->posY = paddle->posY
        LBI R3, mouseAddr_high
        SLBI R3, mouseAddr_low
        LD R1, R3, posX             
        LD R2, R3, posY
        ST R1, R0, posX             ; paddle->posX = mouse->posX
        ST R2, R0, posY             ; paddle->posY = mouse->posY
        JR R7, #0                   ; return

; update the ball location and calc the curve for the ball
BUPDATE:    
        LBI R1, ballAddr_high       
        SLBI R1, ballAddr_low       ; r1 <-- ballAddr
        LBI R2, ballVelAddr         ; r2 <-- ballVelAddr
        LBI R3, ENDPBN_HIGH
        SLBI R3, ENDPBN_LOW
        LDI R0, firstAddr           
        BEQZ R0, #1                 ; if (!first) or if (pBall != NULL) in code
        JR R3, #0                   ; go to ENDPBN address 

        LBI R3, pBallAddr           ; r3 <-- pBallAddr
        LD R4, R1, posZ             ; r4 <-- ball->posZ
        LD R5, R2, velZ             ; r5 <-- ball->velZ
        ADD R4, R4, R5              
        ST R4, R1, posZ             ; ball->posZ += ball->velZ

        LD R5, R3, posZ             ; r5 <-- pBall->posZ
        BLTZ R5, #2                 ; if (ball->velZ >= 0)
        SUB R6, R5, R4              ; zdiff(r6) = ball->posZ - pball->posZ
        J #1
        SUB R6, R4, R5              ; zdiff(r6) = pball->posZ - ball->posZ
TST0:
        ; zdiff is now set here in r6
        
        LD R4, R2, velX             ; r4 <-- ball->velX
        BEQZ R4, ENDVX0             ; if (ball->velX != 0) TODO: this could be a problem if the IMM gets too large, check in assembler
        LD R5, R1, posX             ; r5 <-- ball->posX
        LBI R0, #30
        SUB R0, R4, R0              ; r0 <-- 30 - ball->velX
        BLEZ R0, ENDVX30            ; if (ball->velX <= 30)

        ; start of calc EQ_2ND(zdiff, ball->dirX)
        ; EQ_2ND(Z, D) (D * ((54 * T_2ND(Z)) - (5 * T_2ND(Z) * T_2ND(Z))))
        ; T_2ND(Z) ((Z * 11) / 1200)
        LBI R3, #11
        MULT R0, R6, R3             ; r0 <-- zdiff * 11
        LBI R3, #4
        SLBI R3, #176               ; r3 <-- #1200
        DIV R0, R0, R3              ; r0 <-- T_2ND(zdiff)
        MULT R5, R0, R0             ; r5 <-- T_2ND(zdiff) * T_2ND(zdiff)
TST1:
        LBI R3, #5
        MULT R5, R0, R3             ; r5 <-- T_2ND(zdiff) * T_2ND(zdiff) * 5
TST2:
        LBI R3, #54
        MULT R3, R3, R0             ; r3 <-- 54 * T_2ND(zdiff)
TST3:
        SUB R3, R5, R3              ; r3 <-- (54 * T_2ND(Z)) - (5 * T_2ND(Z) * T_2ND(Z))
TST4:
        LD R0, R2, dirX             ; r0 <-- ball->dirX
        MULT R3, R3, R0             ; r3 <-- EQ_2ND(zdiff, ball->dirX)
TST5:
        LBI R0, pBallAddr
        LD R0, R0, posX              ; r0 <-- pBall-> posX
TST6:
        ADD R0, R0, R3
TST7:
        ST R0, R1, posX             ; ball->posX = pBall->posX + EQ_2ND(zdiff, ball->dirX)
        J ENDVX0
ENDVX30: ; end if (ball->velX <= 30)

        LBI R0, #60
        SUB R0, R4, R0             ; r0 <-- 60 - ball->velX
        BLEZ R0, ENDVX60            ; if (ball->velX <= 60)

        ; start of calc EQ_3RD(zdiff, ball->dirX)
        ; EQ_3RD(Z, D) (D *((54 * T_3RD(Z)) - (5 * T_3RD(Z) * T_3RD(Z))))
        ; T_3RD(Z) ((Z * 11) / 800)
        LBI R3, #11
        MULT R0, R6, R3             ; r0 <-- zdiff * 11
        LBI R3, #3
        SLBI R3, #32                ; r3 <-- #800
        DIV R0, R0, R3              ; r0 <-- T_3RD(zdiff)
        MULT R5, R0, R0             ; r5 <-- T_3RD(zdiff) * T_3RD(zdiff)
        LBI R3, #5
        MULT R5, R0, R3             ; r5 <-- T_3RD(zdiff) * T_3RD(zdiff) * 5
        LBI R3, #54
        MULT R3, R3, R0             ; r3 <-- 54 * T_3RD(zdiff)
        SUB R3, R5, R3              ; r3 <-- (54 * T_3RD(Z)) - (5 * T_3RD(Z) * T_3RD(Z))
        LD R0, R2, dirX             ; r0 <-- ball->dirX
        MULT R3, R3, R0             ; r3 <-- EQ_2ND(zdiff, ball->dirX)
        LBI R0, pBallAddr
        LD R0, R0, posX              ; r0 <-- pBall-> posX
        ADD R0, R0, R3
        ST R0, R1, posX             ; ball->posX = pBall->posX + EQ_3RD(zdiff, ball->dirX)
        J ENDVX0
ENDVX60: ; end if (ball->vel <= 60)

        LBI R0, #90
        SUB R0, R4, R0             ; r0 <-- 90 - ball->velX
        BLEZ R0, ENDVX90            ; if (ball->velX <= 90)

        ; start of calc EQ_4TH(zdiff, ball->dirX)
        ; EQ_4TH(Z, D) (D *((63 * T_4TH(Z)) - (5 * T_4TH(Z) * T_4TH(Z))))
        ; T_4TH(Z) ((Z * 13) / 600)
        LBI R3, #13
        MULT R0, R6, R3             ; r0 <-- zdiff * 11
        LBI R3, #2
        SLBI R3, #88                ; r3 <-- #600
        DIV R0, R0, R3              ; r0 <-- T_4TH(zdiff)
        MULT R5, R0, R0             ; r5 <-- T_4TH(zdiff) * T_4TH(zdiff)
        LBI R3, #5
        MULT R5, R0, R3             ; r5 <-- T_4TH(zdiff) * T_4TH(zdiff) * 5
        LBI R3, #63
        MULT R3, R3, R0             ; r3 <-- 63 * T_4TH(zdiff)
        SUB R3, R5, R3              ; r3 <-- (63 * T_4TH(Z)) - (5 * T_4TH(Z) * T_4TH(Z))
        LD R0, R2, dirX             ; r0 <-- ball->dirX
        MULT R3, R3, R0             ; r3 <-- EQ_4TH(zdiff, ball->dirX)
        LBI R0, pBallAddr
        LD R0, R0, posX              ; r0 <-- pBall-> posX
        ADD R0, R0, R3
        ST R0, R1, posX             ; ball->posX = pBall->posX + EQ_4TH(zdiff, ball->dirX)
        J ENDVX0
ENDVX90: ; end if (ball->velX <= 90)

        ; start of calc EQ_5TH(zdiff, ball->dirX)
        ; EQ_5TH(Z, D) (D * ((77 * T_5TH(Z)) - (5 * T_5TH(Z) * T_5TH(Z))))
        ; T_5TH(Z) ((Z * 16) / 400)
        LBI R3, #16
        MULT R0, R6, R3             ; r0 <-- zdiff * 11
        LBI R3, #1
        SLBI R3, #144               ; r3 <-- #400
        DIV R0, R0, R3              ; r0 <-- T_5TH(zdiff)
        MULT R5, R0, R0             ; r5 <-- T_5TH(zdiff) * T_5TH(zdiff)
        LBI R3, #5
        MULT R5, R0, R3             ; r5 <-- T_5TH(zdiff) * T_5TH(zdiff) * 5
        LBI R3, #77
        MULT R3, R3, R0             ; r3 <-- 77 * T_5TH(zdiff)
        SUB R3, R5, R3              ; r3 <-- (77 * T_5TH(Z)) - (5 * T_5TH(Z) * T_5TH(Z))
        LD R0, R2, dirX             ; r0 <-- ball->dirX
        MULT R3, R3, R0             ; r3 <-- EQ_5TH(zdiff, ball->dirX)
        LBI R0, pBallAddr
        LD R0, R0, posX              ; r0 <-- pBall-> posX
        ADD R0, R0, R3
        ST R0, R1, posX             ; ball->posX = pBall->posX + EQ_5TH(zdiff, ball->dirX)
ENDVX0:

        LD R4, R2, velY             ; r4 <-- ball->velY
        BEQZ R4, ENDVY0             ; if (ball->velY != 0) TODO: this could be a problem if the IMM gets too large, check in assembler
        LD R5, R1, posY             ; r5 <-- ball->posY
        LBI R0, #30
        SUB R0, R4, R0              ; r0 <-- 30 - ball->velY
        BLEZ R0, ENDVY30            ; if (ball->velY <= 30)

        ; start of calc EQ_2ND(zdiff, ball->dirY)
        ; EQ_2ND(Z, D) (D * ((54 * T_2ND(Z)) - (5 * T_2ND(Z) * T_2ND(Z))))
        ; T_2ND(Z) ((Z * 11) / 1200)
        LBI R3, #11
        MULT R0, R6, R3             ; r0 <-- zdiff * 11
        LBI R3, #4
        SLBI R3, #176               ; r3 <-- #1200
        DIV R0, R0, R3              ; r0 <-- T_2ND(zdiff)
        MULT R5, R0, R0             ; r5 <-- T_2ND(zdiff) * T_2ND(zdiff)
        LBI R3, #5
        MULT R5, R0, R3             ; r5 <-- T_2ND(zdiff) * T_2ND(zdiff) * 5
        LBI R3, #54
        MULT R3, R3, R0             ; r3 <-- 54 * T_2ND(zdiff)
        SUB R3, R5, R3              ; r3 <-- (54 * T_2ND(Z)) - (5 * T_2ND(Z) * T_2ND(Z))
        LD R0, R2, dirY             ; r0 <-- ball->dirY
        MULT R3, R3, R0             ; r3 <-- EQ_2ND(zdiff, ball->dirY)
        LBI R0, pBallAddr
        LD R0, R0, posY              ; r0 <-- pBall-> posY
        ADD R0, R0, R3
        ST R0, R1, posY             ; ball->posY = pBall->posY + EQ_2ND(zdiff, ball->dirY)
        J ENDVY0
ENDVY30: ; end if (ball->velY <= 30)

        LBI R0, #60
        SUB R0, R4, R0             ; r0 <-- 60 - ball->velY
        BLEZ R0, ENDVY60            ; if (ball->velY <= 60)

        ; start of calc EQ_3RD(zdiff, ball->dirY)
        ; EQ_3RD(Z, D) (D *((54 * T_3RD(Z)) - (5 * T_3RD(Z) * T_3RD(Z))))
        ; T_3RD(Z) ((Z * 11) / 800)
        LBI R3, #11
        MULT R0, R6, R3             ; r0 <-- zdiff * 11
        LBI R3, #3
        SLBI R3, #32                ; r3 <-- #800
        DIV R0, R0, R3              ; r0 <-- T_3RD(zdiff)
        MULT R5, R0, R0             ; r5 <-- T_3RD(zdiff) * T_3RD(zdiff)
        LBI R3, #5
        MULT R5, R0, R3             ; r5 <-- T_3RD(zdiff) * T_3RD(zdiff) * 5
        LBI R3, #54
        MULT R3, R3, R0             ; r3 <-- 54 * T_3RD(zdiff)
        SUB R3, R5, R3              ; r3 <-- (54 * T_3RD(Z)) - (5 * T_3RD(Z) * T_3RD(Z))
        LD R0, R2, dirY             ; r0 <-- ball->dirY
        MULT R3, R3, R0             ; r3 <-- EQ_2ND(zdiff, ball->dirY)
        LBI R0, pBallAddr
        LD R0, R0, posY              ; r0 <-- pBall-> posY
        ADD R0, R0, R3
        ST R0, R1, posY             ; ball->posY = pBall->posY + EQ_3RD(zdiff, ball->dirY)
        J ENDVY0
ENDVY60: ; end if (ball->vel <= 60)

        LBI R0, #90
        SUB R0, R4, R0             ; r0 <-- 90 - ball->velY
        BLEZ R0, ENDVY90            ; if (ball->velY <= 90)

        ; start of calc EQ_4TH(zdiff, ball->dirY)
        ; EQ_4TH(Z, D) (D *((63 * T_4TH(Z)) - (5 * T_4TH(Z) * T_4TH(Z))))
        ; T_4TH(Z) ((Z * 13) / 600)
        LBI R3, #13
        MULT R0, R6, R3             ; r0 <-- zdiff * 11
        LBI R3, #2
        SLBI R3, #88                ; r3 <-- #600
        DIV R0, R0, R3              ; r0 <-- T_4TH(zdiff)
        MULT R5, R0, R0             ; r5 <-- T_4TH(zdiff) * T_4TH(zdiff)
        LBI R3, #5
        MULT R5, R0, R3             ; r5 <-- T_4TH(zdiff) * T_4TH(zdiff) * 5
        LBI R3, #63
        MULT R3, R3, R0             ; r3 <-- 63 * T_4TH(zdiff)
        SUB R3, R5, R3              ; r3 <-- (63 * T_4TH(Z)) - (5 * T_4TH(Z) * T_4TH(Z))
        LD R0, R2, dirY             ; r0 <-- ball->dirY
        MULT R3, R3, R0             ; r3 <-- EQ_4TH(zdiff, ball->dirY)
        LBI R0, pBallAddr
        LD R0, R0, posY              ; r0 <-- pBall-> posY
        ADD R0, R0, R3
        ST R0, R1, posY             ; ball->posY = pBall->posY + EQ_4TH(zdiff, ball->dirY)
        J ENDVY0
ENDVY90: ; end if (ball->velY <= 90)

        ; start of calc EQ_5TH(zdiff, ball->dirY)
        ; EQ_5TH(Z, D) (D * ((77 * T_5TH(Z)) - (5 * T_5TH(Z) * T_5TH(Z))))
        ; T_5TH(Z) ((Z * 16) / 400)
        LBI R3, #16
        MULT R0, R6, R3             ; r0 <-- zdiff * 11
        LBI R3, #1
        SLBI R3, #144               ; r3 <-- #400
        DIV R0, R0, R3              ; r0 <-- T_5TH(zdiff)
        MULT R5, R0, R0             ; r5 <-- T_5TH(zdiff) * T_5TH(zdiff)
        LBI R3, #5
        MULT R5, R0, R3             ; r5 <-- T_5TH(zdiff) * T_5TH(zdiff) * 5
        LBI R3, #77
        MULT R3, R3, R0             ; r3 <-- 77 * T_5TH(zdiff)
        SUB R3, R5, R3              ; r3 <-- (77 * T_5TH(Z)) - (5 * T_5TH(Z) * T_5TH(Z))
        LD R0, R2, dirY             ; r0 <-- ball->dirY
        MULT R3, R3, R0             ; r3 <-- EQ_5TH(zdiff, ball->dirY)
        LBI R0, pBallAddr
        LD R0, R0, posY              ; r0 <-- pBall-> posY
        ADD R0, R0, R3
        ST R0, R1, posY             ; ball->posY = pBall->posY + EQ_5TH(zdiff, ball->dirY)
ENDVY0:
ENDPBN: ; end if (pball != NULL)

        ; start of ball and sidewall collisions
        ; expected register contents at this point:
        ; r1 <-- ballAddr 
        ; r2 <-- ballVelAddr

        LBI R6, #-1                 ; r6 <-- -1 so we don't have to load it everytime

        ; right wall
        LD R0, R1, posX             ; r0 <-- ball->posX
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        ADD R0, R0, R4              ; r0 <-- ball->posX + BALL_RAD
        LBI R3, width_high
        SLBI R3, width_low          ; r3 <-- WIDTH
        SUB R0, R3, R0              ; r0 <-- (ball->posX + BALL_RAD) - WIDTH 
        BLTZ R0, ENDRW              ; if (ball->posX + BALL_RAD >= WIDTH)
        LD R0, R1, posX             ; r0 <-- ball->posX
        SUB R3, R3, R4
        SUBI R3, R3, #1             ; r3 <-- WIDTH - BALL_RAD - 1
        ST R3, R1, posX             ; ball->posX = WIDTH - BALL_RAD - 1
           
        LD R3, R2, dirX             ; r3 <-- ball->dirX
        SUBI R4, R3, #1
        BNEZ R4, #1                 ; if (ball->dirX == 1)
        ST R6, R2, dirX             ; ball->dirX = -1

        LD R3, R2, velX             ; r3 <-- ball->velX
        LBI R4, curve_reduce        ; r4 <-- CURVE_REDUCE
        SUB R0, R3, R4
        BLEZ R0, #2                 ; if (ball->velX > CURVE_REDUCE)
        SUB R0, R4, R3
        ST R0, R2, velX             ; ball->velX -= CURVE_REDUCE

        LD R3, R2, velY             ; r3 <-- ball->velY
        SUB R0, R4, R3
        BLEZ R0, #2                 ; if (ball->velY > CURVE_REDUCE)
        SUB R0, R3, R4
        ST R0, R2, velY             ; ball->velY -= CURVE_REDUCE

        LBI R0, SAVEBALL_HIGH
        SLBI R0, SAVEBALL_LOW
        JALR R0, #0                 ; save_ball()
        
        J ENDCOLRL
ENDRW: ; end if (ball->posX + BALL_RAD >= WIDTH)

        ; left wall
        LD R0, R1, posX             ; r0 <-- ball->posX
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        SUB R0, R4, R0              ; r0 <-- ball->posX - BALL_RAD
        LBI R3, #0
        SUB R0, R0, R3              ; r0 <-- 0 - (ball->posX - BALL_RAD)
        BLTZ R0, ENDCOLRL           ; if (ball->posX - BALL_RAD <= 0)
        LBI R3, ball_rad
        ADDI R3, R3, #1             ; r3 <-- BALL_RAD + 1
        ST R3, R1, posX             ; ball->posX = BALL_RAD + 1
           
        LD R3, R2, dirX             ; r3 <-- ball->dirX
        SUBI R4, R3, #-1
        BNEZ R4, #2                 ; if (ball->dirX == -1)
        LBI R3, #1
        ST R3, R2, dirX             ; ball->dirX = 1

        LD R3, R2, velX             ; r3 <-- ball->velX
        LBI R4, curve_reduce        ; r4 <-- CURVE_REDUCE
        SUB R0, R4, R3
        BLEZ R0, #2                 ; if (ball->velX > CURVE_REDUCE)
        SUB R0, R4, R3
        ST R0, R2, velX             ; ball->velX -= CURVE_REDUCE

        LD R3, R2, velY             ; r3 <-- ball->velY
        SUB R0, R4, R3
        BLEZ R0, #2                 ; if (ball->velY > CURVE_REDUCE)
        SUB R0, R4, R3
        ST R0, R2, velY             ; ball->velY -= CURVE_REDUCE

        LBI R0, SAVEBALL_HIGH
        SLBI R0, SAVEBALL_LOW
        JALR R0, #0                 ; save_ball()

ENDCOLRL: ; end if (ball->posX + BALL_RAD <= 0)

        ; top wall
        LD R0, R1, posY             ; r0 <-- ball->posY
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        SUB R0, R4, R0              ; r0 <-- ball->posY - BALL_RAD
        LBI R3, #0
        SUB R0, R0, R3              ; r0 <-- 0 - (ball->posY - BALL_RAD)
        BLTZ R0, ENDTW              ; if (ball->posX - BALL_RAD <= 0)
        LBI R3, ball_rad
        ADDI R3, R3, #1             ; r3 <-- BALL_RAD + 1
        ST R3, R1, posY             ; ball->posY = BALL_RAD + 1
           
        LD R3, R2, dirY             ; r3 <-- ball->dirY
        SUBI R4, R3, #-1
        BNEZ R4, #2                 ; if (ball->dirY == -1)
        LBI R3, #1
        ST R3, R2, dirY             ; ball->dirY = 1

        LD R3, R2, velX             ; r3 <-- ball->velX
        LBI R4, curve_reduce        ; r4 <-- CURVE_REDUCE
        SUB R0, R4, R3
        BLEZ R0, #2                 ; if (ball->velX > CURVE_REDUCE)
        SUB R0, R4, R3
        ST R0, R2, velX             ; ball->velX -= CURVE_REDUCE

        LD R3, R2, velY             ; r3 <-- ball->velY
        SUB R0, R4, R3
        BLEZ R0, #2                 ; if (ball->velY > CURVE_REDUCE)
        SUB R0, R4, R3
        ST R0, R2, velY             ; ball->velY -= CURVE_REDUCE

        LBI R0, SAVEBALL_HIGH
        SLBI R0, SAVEBALL_LOW
        JALR R0, #0                 ; save_ball()

        J ENDCOLTB
ENDTW:

        ; bottom wall
        LD R0, R1, posY             ; r0 <-- ball->posY
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        ADD R0, R4, R0              ; r0 <-- ball->posY + BALL_RAD
        LBI R3, height_high
        SLBI R3, height_low         ; r3 <-- HEIGHT
        SUB R0, R3, R0              ; r0 <-- (ball->posX + BALL_RAD) - HEIGHT
        BLTZ R0, ENDCOLTB           ; if (ball->posX + BALL_RAD >= HEIGHT)
        LD R0, R1, posY             ; r0 <-- ball->posY
        SUB R3, R4, R3
        SUBI R3, R3, #1             ; r3 <-- HEIGHT - BALL_RAD - 1
        ST R3, R1, posY             ; ball->posY = HEIGHT - BALL_RAD - 1
           
        LD R3, R2, dirY             ; r3 <-- ball->dirY
        SUBI R4, R3, #1
        BNEZ R4, #1                 ; if (ball->dirY == 1)
        ST R6, R2, dirY             ; ball->dirY = -1

        LD R3, R2, velX             ; r3 <-- ball->velX
        LBI R4, curve_reduce        ; r4 <-- CURVE_REDUCE
        SUB R0, R4, R3
        BLEZ R0, #2                 ; if (ball->velX > CURVE_REDUCE)
        SUB R0, R4, R3
        ST R0, R2, velX             ; ball->velX -= CURVE_REDUCE

        LD R3, R2, velY             ; r3 <-- ball->velY
        SUB R0, R4, R3
        BLEZ R0, #2                 ; if (ball->velY > CURVE_REDUCE)
        SUB R0, R4, R3
        ST R0, R2, velY             ; ball->velY -= CURVE_REDUCE

        LBI R0, SAVEBALL_HIGH
        SLBI R0, SAVEBALL_LOW
        JALR R0, #0                 ; save_ball()

ENDCOLTB: ; end if (ball->posX + BALL_RAD <= 0)

        ; start of ball and player/opp wall collisions
        ; expected register contents at this point:
        ; r1 <-- ballAddr 
        ; r2 <-- ballVelAddr

        ; ball and player wall collision
        LD R0, R1, posZ             ; r0 <-- ball->posZ
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        SUB R0, R4, R0              ; r0 <-- ball->posZ - BALL_RAD
        LBI R3, #0
        SUB R0, R0, R3              ; r0 <-- 0 - (ball->posZ - BALL_RAD)
        BLTZ R0, ENDPW              ; if (ball->posZ - BALL_RAD <= 0)

        LBI R0, paddle1Addr_high
        SLBI R0, paddle1Addr_low    ; r0 <-- paddle1Addr
        LBI R3, INTERSECT_HIGH
        SLBI R3, INTERSECT_LOW
        JALR R3, #0                 ; r0 <-- intersect(paddle)
        ; r0 <-- sect at this point

        LBI R3, firstAddr           ; r3 <-- first
        OR R4, R3, R0               ; r4 <-- sect || first
        BEQZ R4, NOINTRP            ; if (sect || first)
        LBI R4, ball_rad
        ST R4, R1, posZ             ; ball->posZ = BALL_RAD

        LBI R4, mouseAddr_high
        SLBI R4, mouseAddr_low      ; r4 <-- mouseAddr
        LBI R5, pMouseAddr          ; r5 <-- pMouseAddr

        BEQZ R3, INTRPNF            ; if (first)
        LD R3, R4, posX             ; r3 <-- mouse->posX
        LD R6, R5, posX             ; r6 <-- pmouse->posX
        SUB R6, R6, R3
        ST R6, R2, velX             ; ball->velX = mouse->posX - pmouse->posX

        LD R3, R4, posY             ; r3 <-- mouse->posY
        LD R6, R5, posY             ; r6 <-- pmouse->posY
        SUB R6, R6, R3
        ST R6, R2, velY             ; ball->velY = mouse->posY - pmouse->posY
        LBI R0, firstAddr
        LBI R3, #0
        ST R3, R0, #0               ; first = FALSE
        J INTRPN_ELSE

INTRPNF: ; end if (first)
        LD R0, R2, velZ             ; r0 <-- ball->velZ
        MULTI R0, R0, #-1           ; r0 <-- ball->velZ * -1
        ADDI R0, R0, velz_inc
        ST R0, R2, velZ             ; ball->velZ = (ball->velZ * -1) + VELZ_INC

        LD R0, R5, posX             ; r0 <-- pmouse->posX
        LD R3, R4, posX             ; r3 <-- mouse->posX
        SUB R3, R0, R3              ; r3 <-- mouse->posX - pmouse->posX
        LD R0, R2, velX             ; r0 <-- ball->velX
        SUB R3, R0, R3              ; r3 <-- (mouse->posX - pmouse->posX) - ball->velX 
        ST R3, R2, velX             ; ball->velX = (mouse->posX - pmouse->posX) - ball->velX 

        LD R0, R5, posY             ; r0 <-- pmouse->posY
        LD R3, R4, posY             ; r3 <-- mouse->posY
        SUB R3, R0, R3              ; r3 <-- mouse->posY - pmouse->posY
        LD R0, R2, velY             ; r0 <-- ball->velY
        SUB R3, R0, R3              ; r3 <-- (mouse->posY - pmouse->posY) - ball->velY 
        ST R3, R2, velY             ; ball->velY = (mouse->posY - pmouse->posY) - ball->velY

INTRPN_ELSE: ; end_else if (first)

        LD R0, R2, velX             ; r0 <-- ball->velX
        SUBI R3, R0, #0             ; r3 <-- ball->velX - 0
        BLTZ R3, #3                 ; if (ball->velX >= 0)
        LBI R3, #1
        ST R3, R2, dirX             ; ball->dirX = 1
        J #4
        MULTI R3, R0, #-1
        ST R3, R2, velX             ; ball->velX *= -1
        LBI R3, #-1
        ST R3, R2, dirX             ; ball->dirX = -1

        LD R0, R2, velY             ; r0 <-- ball->velY
        SUBI R3, R0, #0             ; r3 <-- ball->velY - 0
        BLTZ R3, #3                 ; if (ball->velY >= 0)
        LBI R3, #1
        ST R3, R2, dirY             ; ball->dirY = 1
        J #4
        MULTI R3, R0, #-1
        ST R3, R2, velY             ; ball->velY *= -1
        LBI R3, #-1
        ST R3, R2, dirY             ; ball->dirY = -1

        LBI R0, SAVEBALL_HIGH
        SLBI R0, SAVEBALL_LOW
        JALR R0, #0                 ; save_ball()

        J ENDOW

NOINTRP: ; end if (sect || first)
        
        LBI R0, scoreAddr_high
        SLBI R0, scoreAddr_low
        LD R3, R0, p2Score
        ADDI R3, R3, #1
        ST R3, R0, p2Score          ; oppScore++

        ; TODO: should i call restart here, or should we just reloop??
        HALT
    
        J ENDOW
ENDPW: ; end if (ball->posZ - BALL_RAD <= 0)

        LD R0, R1, posZ             ; r0 <-- ball->posZ
        LBI R3, ball_rad            ; r3 <-- BALL_RAD
        ADD R0, R0, R3              ; r0 <-- ball->posZ + ball_rad
        LBI R3, depth_high
        SLBI R3, depth_low          ; r3 <-- depth
        SUB R0, R3, R0
        BLTZ R0, ENDOW              ; if (ball->posZ + BALL_RAD >= DEPTH)
        LBI R0, paddle2Addr_high
        SLBI R0, paddle2Addr_low
        LBI R3, INTERSECT_HIGH
        SLBI R3, INTERSECT_LOW
        JALR R3, #0                 ; r0 <-- intersect(paddle2)
        ; r0 <-- sect at this point


        BEQZ R0, ENDINTROW          ; if (intersect(opponent))
        LD R3, R2, velZ
        ADDI R3, R3, velz_inc
        MULTI R3, R3, #-1
        ST R3, R2, velZ             ; ball->velZ = (ball->velZ + VELZ_INC) * -1 
        LD R3, R2, dirX
        MULTI R3, R3, #-1
        ST R3, R2, dirX             ; ball->dirX *= -1
        LD R3, R2, dirY
        MULTI R3, R3, #-1
        ST R3, R2, dirY             ; ball->dirY *= -1
        LBI R3, depth_high
        SLBI R3, depth_low
        LBI R4, ball_rad            ; r4 <-- BALL_RAD
        SUB R3, R4, R3
        ST R3, R1, posZ             ; ball->posZ = DEPTH - BALL_RAD
        J ENDOW
ENDINTROW: ; end if (intersect(opponent))

        LBI R0, scoreAddr_high
        SLBI R0, scoreAddr_low
        LD R3, R0, p1Score
        ADDI R3, R3, #1
        ST R3, R0, p1Score          ; playerScore++
        LBI R0, difficultyAddr
        LD R3, R0, #0
        ADDI R3, R3, #1
        ST R3, R0, #0               ; difficulty++

        ; TODO: call restart here?
        HALT

ENDOW: ; end if (ball->posZ + BALL_RAD >= DEPTH)

        ; this is a spining loop used to stall the calculation of the game state
        ;LBI R0, stallCnt_high
        ;SLBI R0, stallCnt_low
        ;BEQZ R0, #1
        ;SUBI R0, R0, #1

        LBI R0, GLOOP_HIGH
        SLBI R0, GLOOP_LOW
        JR R0, #0

SAVEBALL: ; save_ball() function: this modifies r3, r4, r5
        LBI R3, ballAddr_high
        SLBI R3, ballAddr_low
        LBI R4, pBallAddr
        LD R5, R3, posX
        ST R5, R4, posX             ; pBall->posX = ball->posX
        LD R5, R3, posY
        ST R5, R4, posY             ; pBall->posY = ball->posY
        LD R5, R3, posZ
        ST R5, R4, posZ             ; pBall->posZ = ball->posZ
        JR R7, #0                   ; return

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
        SUB R6, R5, R4              ; r6 <-- ball->posX + BALL_RAD - p->posX
        BLTZ R6, RETINTRF           ; if (ball->posX + BALL_RAD >= p->posX)

        LBI R4, ball_rad
        SUB R4, R4, R3              ; r4 <-- ball->posX - BALL_RAD
        LBI R6, paddle_width
        ADD R6, R5, R6              ; r6 <-- p->posX + PAD_WIDTH
        SUB R6, R4, R6              ; r6 <-- (ball->posX - BALL_RAD) - (p->posX + PAD_WIDTH)
        BLTZ R6, RETINTRF           ; if (ball->posX - BALL_RAD <= p->posX + PAD_WIDTH)

        LD R3, R1, posY             ; r3 <-- ball->posY
        LBI R4, ball_rad
        ADD R4, R3, R4              ; r4 <-- ball->posY + BALL_RAD
        LD R5, R0, posY             ; r5 <-- p->posY
        SUB R6, R5, R4              ; r6 <-- ball->posY + BALL_RAD - p->posY
        BLTZ R6, RETINTRF           ; if (ball->posY + BALL_RAD >= p->posY)

        LBI R4, ball_rad
        SUB R4, R4, R3              ; r4 <-- ball->posY - BALL_RAD
        LBI R6, paddle_height
        ADD R6, R5, R6              ; r6 <-- p->posY + PAD_HEIGHT
        SUB R6, R4, R6              ; r6 <-- (ball->posY - BALL_RAD) - (p->posY + PAD_HEIGHT)
        BLTZ R6, RETINTRF           ; if (ball->posX - BALL_RAD <= p->posY + PAD_HEIGHT)

        LBI R0, #1                  ; return TRUE
        JR R7, #0
RETINTRF:        
        LBI R0, #0
        JR R7, #0
