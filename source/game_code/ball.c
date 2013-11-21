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
    int16_t sect, zdiff;

    // update the ball pos
    if (pball != NULL)
    {
        ball->posZ += ball->velZ; 
        zdiff = (ball->velZ >= 0) ? (ball->posZ - pball->posZ) :
                    (pball->posZ - ball->posZ);

        if (ball->velX != 0)
        {
            if (ball->velX <= 30)
                ball->posX = pball->posX + EQ_2ND(zdiff, ball->dirX);
            else if (ball->velX <= 60)
                ball->posX = pball->posX + EQ_3RD(zdiff, ball->dirX);
            else if (ball->velX <= 90)
                ball->posX = pball->posX + EQ_4TH(zdiff, ball->dirX);
            else
                ball->posX = pball->posX + EQ_5TH(zdiff, ball->dirX);
        }

        if (ball->velY != 0)
        {
            if (ball->velY <= 30)
                ball->posY = pball->posY + EQ_2ND(zdiff, ball->dirY);
            else if (ball->velY <= 60)
                ball->posY = pball->posY + EQ_3RD(zdiff, ball->dirY);
            else if (ball->velY <= 90)
                ball->posY = pball->posY + EQ_4TH(zdiff, ball->dirY);
            else
                ball->posY = pball->posY + EQ_5TH(zdiff, ball->dirY);
        }
    }

    // ball and side wall collision
    // right wall
    if (ball->posX + BALL_RAD >= WIDTH)
    {
        printf("right wall\n");
        ball->posX = WIDTH - BALL_RAD - 1;

        if (ball->dirX == 1)
            ball->dirX = -1;

        if (ball->velX > CURVE_REDUCE)
            ball->velX -= CURVE_REDUCE;

        if (ball->velY > CURVE_REDUCE)
            ball->velY -= CURVE_REDUCE;

        save_ball();
    }
    // left wall
    else if (ball->posX - BALL_RAD <= 0)
    {
        printf("left wall\n");
        ball->posX = BALL_RAD + 1;

        if (ball->dirX == -1)
            ball->dirX = 1;

        if (ball->velX > CURVE_REDUCE)
            ball->velX -= CURVE_REDUCE;

        if (ball->velY > CURVE_REDUCE)
            ball->velY -= CURVE_REDUCE;

        save_ball();
    }

    // top wall
    if (ball->posY - BALL_RAD <= 0)
    {
        printf("top wall\n");
        ball->posY = BALL_RAD + 1;

        if (ball->dirY == -1)
            ball->dirY = 1;

        if (ball->velX > CURVE_REDUCE)
            ball->velX -= CURVE_REDUCE;

        if (ball->velY > CURVE_REDUCE)
            ball->velY -= CURVE_REDUCE;

        save_ball();
    }
    // bottom wall
    else if (ball->posY + BALL_RAD >= HEIGHT)
    {
        printf("bottom wall\n");
        ball->posY = HEIGHT - BALL_RAD - 1;

        if (ball->dirY == 1)
            ball->dirY = -1;

        if (ball->velX > CURVE_REDUCE)
            ball->velX -= CURVE_REDUCE;

        if (ball->velY > CURVE_REDUCE)
            ball->velY -= CURVE_REDUCE;

        save_ball();
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
            ball->posZ = BALL_RAD;

            if (first) // if it's the first hit (the player is serving)
            {
                ball->velX = mouse->posX - pmouse->posX;
                ball->velY = mouse->posY - pmouse->posY;
                first = FALSE;
            }
            else // if the player isn't serving
            {
                ball->velZ *= -1;
                ball->velZ += VELZ_INC;
                ball->velX = (mouse->posX - pmouse->posX) - ball->velX;
                ball->velY = (mouse->posY - pmouse->posY) - ball->velY;
            }

            // convert the velocity to a magnitude and save the direction
            if (ball->velX >=0)
                ball->dirX = 1;
            else
            {
                ball->velX *= -1;
                ball->dirX = -1;
            }

            if (ball->velY >=0)
                ball->dirY = 1;
            else
            {
                ball->velY *= -1;
                ball->dirY = -1;
            }
            
            save_ball();
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
            // opp hits the ball
            ball->velZ += VELZ_INC;
            ball->velZ *= -1;
            
            // only flip the direction of the x and y velocities for testing
            // this will show a continuation of the curve placed on the ball already
            ball->dirX *= -1;
            ball->dirY *= -1;

            // move ball back to their wall
            ball->posZ = DEPTH - BALL_RAD;
        }
        else // if opp miss
        {
            playerScore++;
            difficulty++;
            restart();
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
