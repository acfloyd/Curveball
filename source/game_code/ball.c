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

void save_ball ()
{
    if (pball == NULL)
        pball = (Ball_t *)malloc(sizeof(Ball_t));

    pball->posX = ball->posX;
    pball->posY = ball->posY;
    pball->posZ = ball->posZ;
    pball->velX = ball->velX;
    pball->velY = ball->velY;
    pball->velZ = ball->velZ;
}

void ball_update ()
{
    int16_t sect, zdiff, mouseDiff;
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
            ball->velY = ball->velY + ball->accY;
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
        printf("player wall\n", first);
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
                if (mouse->posX > pmouse->posX)
                    mouseDiff = mouse->posX - pmouse->posX;
                else
                    mouseDiff = pmouse->posX - mouse->posX;

                if (mouseDiff != 0)
                {
                    if (mouseDiff <= 30)
                    {
                        ball->velX = VEL1;
                        ball->accX = -1 * VEL1;
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

                if (mouse->posY > pmouse->posY)
                    mouseDiff = mouse->posY - pmouse->posY;
                else
                    mouseDiff = pmouse->posY - mouse->posY;

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

                first = FALSE;
            }
            else // if the player isn't serving
            {
                // TODO: nothing really done here yet
                ball->velZ *= -1;
                ball->velZ += VELZ_INC;
                ball->velX = (mouse->posX - pmouse->posX) - ball->velX;
                ball->velY = (mouse->posY - pmouse->posY) - ball->velY;
                ball->accX = (ball->velX / 4) * -1;
                ball->accY = (ball->velY / 4) * -1;
                restart(); 
            }
        }
        else
        {
            // If the player's paddle doesn't hit the ball
            // and it isn't the first serve
            // increase the opponent's score and restart.
            oppScore++;
            restart(); 
        }
    }
    // opponent's wall and ball collision
    else if (ball->posZ + BALL_RAD >= DEPTH)
    {
        printf("opp wall\n");
        if (intersect(opponent))
        {
            // TODO: nothing really done here yet
            // opp hits the ball
            ball->velZ += VELZ_INC;
            ball->velZ *= -1;

            // move ball back to their wall
            ball->posZ = DEPTH - BALL_RAD;
            restart();
        }
        else // if opp miss
        {
            playerScore++;
            difficulty++;
            restart();
        }
        restart();
    }
}

uint16_t intersect (Pad_t* p)
{
    return (uint16_t) (ball->posX + BALL_RAD >= p->posX &&
                        ball->posX - BALL_RAD <= p->posX + PAD_WIDTH &&
                        ball->posY + BALL_RAD >= p->posY &&
                        ball->posY - BALL_RAD <= p->posY + PAD_HEIGHT);
}
