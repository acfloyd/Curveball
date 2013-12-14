/*
Ball 
Here, all of the ball's data (such as position and direction),
and all of the functions needed for it to move and collide with stuff.
*/

#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <stdint.h>
#include "curveball.h"

void ball_update ()
{
    int16_t sect, zdiff, mouseDiff, mouseDir;
    int32_t tmp;

/*
    printf("ball->velX: %d, velY: %d, velZ: %d, posX: %d, posY: %d, posZ: %d, accX: %d, accY: %d\n",
        ball->velX, ball->velY, ball->velZ, ball->posX, ball->posY, ball->posZ, ball->accX, ball->accY);
*/

    // update the ball pos
    if (!first)
    {
        int16_t r0,r1,r2,r3,r4,r5,r6,r7;
        r6 = zdiff;

        ball->posZ += ball->velZ; 

        if (ball->posZ % UPDATE == 0)
        {
            ball->velX = ball->velX + ball->accX;
            if (ball->velX == 0)
            {
                if (ball->accX < 0)
                    ball->velX = -1;
            }
            ball->velY = ball->velY + ball->accY;
            if (ball->velY == 0)
            {
                if (ball->accY < 0)
                    ball->velY = -1;
            }
        }

        r0 = UPDATE >> ball->xStat;
        if (ball->posZ % r0 == 0)
        {
            ball->posX = ball->posX + (ball->velX >> ball->xStat);
        }

        r0 = UPDATE >> ball->yStat;
        if (ball->posZ % r0 == 0)
        {
            ball->posY = ball->posY + (ball->velY >> ball->yStat);
        }
    }

    // ball and side wall collision
    // TODO: play sounds on each collision
    // right wall or left wall
    if ((ball->posX + BALL_RAD >= WIDTH) || (ball->posX - BALL_RAD <= 0))
    {
        if (ball->posX + BALL_RAD >= WIDTH) {
            printf("right wall\n");
            ball->posX = WIDTH - BALL_RAD - 1;
        }
        else
        {
            printf("left wall\n");
            ball->posX = BALL_RAD + 1;
        }

        ball->velX *= -1;

        printf("ball->velX: %d, velY: %d, velZ: %d, posX: %d, posY: %d, posZ: %d, accX: %d, accY: %d\n",
            ball->velX, ball->velY, ball->velZ, ball->posX, ball->posY, ball->posZ, ball->accX, ball->accY);
    }

    // top wall and bottom
    if ((ball->posY - BALL_RAD <= 0) || (ball->posY + BALL_RAD >= HEIGHT))
    {
        if (ball->posY - BALL_RAD <= 0)
        {
            printf("top wall\n");
            ball->posY = BALL_RAD + 1;
        }
        else
        {
            printf("bottom wall\n");
            ball->posY = HEIGHT - BALL_RAD - 1;
        }

        ball->velY *= -1;
    }

    // ball and player wall collision
    if (ball->posZ - BALL_RAD <= 0)
    {
        printf("player wall\n");
        // we use the intersect function, found at the bottom of this page,
        // to detect collision between the paddle and the ball
        sect = intersect(paddle);

        // right now game just starts and does not wait for mouse click.
        // we will need to change this to listen for click when implemented
        if (sect || first)
        {
            // add to the velocity so the ball goes faster and it becomes more difficult.

            ball->posZ = BALL_RAD + 1;

            if (first) // if it's the first hit (the player is serving)
            {
                printf("first playerWall\n");
                ball->velZ = VELZ_START;
                mouseDiff = mouse->posX - pmouse->posX;
            }
            else
            {
                printf("sec playerWall\n");
                ball->velZ *= -1;
                ball->velZ += difficulty;
                mouseDiff = ball->velX + (mouse->posX - pmouse->posX);
            }

            if (mouseDiff >= 0)
                mouseDir = 1;
            else
            {
                mouseDiff *= -1;
                mouseDir = -1;
            }

            printf("mouseDiffX play = %d\n", mouseDiff);
            printf("ball->velX: %d, velY: %d, velZ: %d, posX: %d, posY: %d, posZ: %d, accX: %d, accY: %d, difficulty = %d\n",
                ball->velX, ball->velY, ball->velZ, ball->posX, ball->posY, ball->posZ, ball->accX, ball->accY, difficulty);

            if (mouseDiff != 0)
            {
                if (mouseDiff <= 30)
                {
                    ball->velX = VEL1 * mouseDir;
                    ball->accX = -1 * ball->velX;
                    ball->xStat = STATIC1;
                }
                else if (mouseDiff <= 60)
                {
                    ball->velX = VEL2;
                    ball->accX = -1 * VEL2;
                    ball->xStat = STATIC2;
                }
                else if (mouseDiff <= 90)
                {
                    ball->velX = VEL3;
                    ball->accX = -1 * VEL3;
                    ball->xStat = STATIC3;
                }
                else
                {
                    ball->velX = VEL4;
                    ball->accX = -1 * VEL4;
                    ball->xStat = STATIC4;
                }
            }


            if (first) // if it's the first hit (the player is serving)
            {
                first = FALSE;
                mouseDiff = mouse->posY - pmouse->posY;
            }
            else
                mouseDiff = ball->velY + (mouse->posY - pmouse->posY);

            if (mouseDiff >= 0)
                mouseDir = 1;
            else
            {
                mouseDiff *= -1;
                mouseDir = -1;
            }

            printf("mouseDiffY play = %d\n", mouseDiff);
            printf("ball->velX: %d, velY: %d, velZ: %d, posX: %d, posY: %d, posZ: %d, accX: %d, accY: %d\n",
                ball->velX, ball->velY, ball->velZ, ball->posX, ball->posY, ball->posZ, ball->accX, ball->accY);

            if (mouseDiff != 0)
            {
                if (mouseDiff <= 30)
                {
                    ball->velY = VEL1;
                    ball->accY = -1 * VEL1;
                    ball->yStat = STATIC1;
                }
                else if (mouseDiff <= 60)
                {
                    ball->velY = VEL2;
                    ball->accY = -1 * VEL2;
                    ball->yStat = STATIC2;
                }
                else if (mouseDiff <= 90)
                {
                    ball->velY = VEL3;
                    ball->accY = -1 * VEL3;
                    ball->yStat = STATIC3;
                }
                else
                {
                    ball->velY = VEL4;
                    ball->accY = -1 * VEL4;
                    ball->yStat = STATIC4;
                }
            }
        }
        else
        {
            // If the player's paddle doesn't hit the ball
            // and it isn't the first serve
            // increase the opponent's score and restart.
            printf("opp score!\n");
            oppScore++;
            ball->posZ = 0;
            ball->velZ = VELZ_START;

            // play a sound
            if (oppScore > 1)
                writeExit();

            setup(); 
        }
    }
    // opponent's wall and ball collision
    else if (ball->posZ + BALL_RAD >= DEPTH)
    {
        printf("opp wall\n");

        if (intersect(opponent) || first)
        {
            // opp hits the ball
            // move ball back to their wall
            ball->posZ = DEPTH - BALL_RAD - 1;

            if (first) // if it's the first hit (the player is serving)
            {
                printf("first opp\n");
                first = FALSE;
                ball->velZ = VELZ_START * -1;
                mouseDiff = opponent->posX - popponent->posX;
            }
            else
            {
                printf("sect opp\n");
                ball->velZ += difficulty;
                ball->velZ *= -1;
                mouseDiff = ball->velX + (opponent->posX - popponent->posX);
            }

            if (mouseDiff >= 0)
                mouseDir = 1;
            else
            {
                mouseDiff *= -1;
                mouseDir = -1;
            }

            printf("mouseDiffX opp = %d\n", mouseDiff);
            printf("ball->velX: %d, velY: %d, velZ: %d, posX: %d, posY: %d, posZ: %d, accX: %d, accY: %d\n",
                ball->velX, ball->velY, ball->velZ, ball->posX, ball->posY, ball->posZ, ball->accX, ball->accY);

            if (mouseDiff != 0)
            {
                if (mouseDiff <= 30)
                {
                    ball->velX = VEL1 * mouseDir;
                    ball->accX = -1 * ball->velX;
                    ball->xStat = STATIC1;
                }
                else if (mouseDiff <= 60)
                {
                    ball->velX = VEL2;
                    ball->accX = -1 * VEL2;
                    ball->xStat = STATIC2;
                }
                else if (mouseDiff <= 90)
                {
                    ball->velX = VEL3;
                    ball->accX = -1 * VEL3;
                    ball->xStat = STATIC3;
                }
                else
                {
                    ball->velX = VEL4;
                    ball->accX = -1 * VEL4;
                    ball->xStat = STATIC4;
                }
            }


            if (first) // if it's the first hit (the player is serving)
                mouseDiff = opponent->posY - popponent->posY;
            else
                mouseDiff = ball->velY + (opponent->posY - popponent->posY);

            if (mouseDiff >= 0)
                mouseDir = 1;
            else
            {
                mouseDiff *= -1;
                mouseDir = -1;
            }

            printf("mouseDiffY opp = %d\n", mouseDiff);
            printf("ball->velX: %d, velY: %d, velZ: %d, posX: %d, posY: %d, posZ: %d, accX: %d, accY: %d\n",
                ball->velX, ball->velY, ball->velZ, ball->posX, ball->posY, ball->posZ, ball->accX, ball->accY);

            if (mouseDiff != 0)
            {
                if (mouseDiff <= 30)
                {
                    ball->velY = VEL1;
                    ball->accY = -1 * VEL1;
                    ball->yStat = STATIC1;
                }
                else if (mouseDiff <= 60)
                {
                    ball->velY = VEL2;
                    ball->accY = -1 * VEL2;
                    ball->yStat = STATIC2;
                }
                else if (mouseDiff <= 90)
                {
                    ball->velY = VEL3;
                    ball->accY = -1 * VEL3;
                    ball->yStat = STATIC3;
                }
                else
                {
                    ball->velY = VEL4;
                    ball->accY = -1 * VEL4;
                    ball->yStat = STATIC4;
                }
            }
        }
        else // if opp miss
        {
            playerScore++;
            ball->posZ = DEPTH;
            ball->velZ = VELZ_START * -1;
            printf("player score! posZ = %d, velZ = %d\n", ball->posZ, ball->velZ);
            writeExit();

            // play sound

            if (playerScore > 1)
                writeExit();

            setup();
        }
    }
}

uint16_t intersect (Pad_t* p)
{
    return (uint16_t) (ball->posX + BALL_RAD >= p->posX &&
                        ball->posX - BALL_RAD <= p->posX + PAD_WIDTH &&
                        ball->posY + BALL_RAD >= p->posY &&
                        ball->posY - BALL_RAD <= p->posY + PAD_HEIGHT);
}
