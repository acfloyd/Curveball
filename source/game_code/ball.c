/*
Ball 
Here, all of the ball's data (such as position and direction),
and all of the functions needed for it to move and collide with stuff.
*/

#include <stdint.h>
#include "curveball.h"

void ball_update ()
{
    int16_t sect;

    // update ball pos
    ball->posX += ball->velX;
    ball->posY += ball->velY;
    ball->posZ += ball->velZ;

    // ball and side wall collision
    // right wall
    if (ball->posX + BALL_RAD >= WIDTH)
    {
        ball->velX *= -1;
        ball->posX = WIDTH - BALL_RAD;
    }
    // left wall
    else if (ball->posX - BALL_RAD <= 0)
    {
        ball->velX *= -1;
        ball->posX = BALL_RAD;
    }

    // top wall
    if (ball->posY - BALL_RAD <= 0)
    {
        ball->velY *= -1;
        ball->posY = BALL_RAD;
    }
    // bottom wall
    else if (ball->posY + BALL_RAD >= HEIGHT)
    {
        ball->velY *= -1;
        ball->posY = HEIGHT - BALL_RAD;
    }

    // ball and player wall collision
    if (ball->posZ - BALL_RAD <= 0)
    {
        // we use the intersect function, found at the bottom of this page,
        // to detect collision between the paddle and the ball
        // Intersection is made to be accurate.
        // TODO: handle the mouse case here
        sect = intersect(paddle);

        if (sect || first)
        {
            ball->velZ += VELZ_INC; // add to the velocity so the ball goes faster and it becomes more difficult.
            ball->velZ *= -1;
            ball->posZ = BALL_RAD;

            if (sect) // if the ball hits the paddle
            {
                if (first) // if it's the first hit (the player is serving)
                {
                    // base the velocity off of the paddle speed
                    ball->velX += (mouse->posX - pmouse->posX) / VELXY_FACTOR_FIRST; 
                    ball->velY += (mouse->posX - pmouse->posY) / VELXY_FACTOR_FIRST;
                    first = FALSE;
                }
                else // if the player isn't serving
                {
                    ball->velX += (mouse->posX - pmouse->posX) / VELXY_FACTOR_HIT;
                    ball->velY += (mouse->posY - pmouse->posY) / VELXY_FACTOR_HIT;
                }
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
        if (intersect(opponent))
        {
            // opp hits the ball
            ball->velZ += VELZ_INC;
            ball->velZ *= -1;

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
