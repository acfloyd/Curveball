
#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include "curveball.h"

int grid[1000][1000];

void main (int argc, char** argv)
{
    // X is rows, Z is col, value is Y

    if (argc != 3)
    {
        printf("usage: insert difference in mouse position to define curve used\n"
                "<x position difference> <y position difference>\n");
        exit(0);
    }

    oppScore = 0;
    playerScore = 0;

    ball = (Ball_t*)malloc(sizeof(Ball_t));
    ball->posZ = 0;
    ball->velZ = VELZ_START;

    // TODO: this is only for testing, pmouse should be checked in the setup function
    pmouse = (Pad_t*)malloc(sizeof(Pad_t));
    pmouse->posX = WIDTH / 2;
    pmouse->posY = HEIGHT / 2;
    pmouse->posX += atoi(argv[1]);
    pmouse->posY += atoi(argv[2]);

    setup();

    printf("curve X = %d, Y = %d\n", atoi(argv[1]), atoi(argv[2]));
    printf("pmouse posX: %d, posY: %d\n", pmouse->posX, pmouse->posY);

    // for testing, the program ends after so many wall hits
    while (TRUE)
    {
        /*
        if (ball->posX % 5 < 3)
        {
            if (ball->posZ % 10 < 5)
                grid[ball->posX / 5][ball->posZ / 10] = ball->posY;
            else
                grid[ball->posX / 5][ball->posZ / 10 + 1] = ball->posY;
        }
        else
        {
            if (ball->posZ % 10 < 5)
                grid[ball->posX / 5 + 1][ball->posZ / 10] = ball->posY;
            else
                grid[ball->posX / 5 + 1][ball->posZ / 10 + 1] = ball->posY;
        }
        */
        grid[ball->posX][ball->posZ] = ball->posY;

        update_game();
    }

}

void setup ()
{
    first = TRUE;

    // init the ball and the opponent
    ball->posX = WIDTH / 2;
    ball->posY = HEIGHT / 2;
    ball->velX = 0;
    ball->velY = 0;
    ball->accX = 0;
    ball->accY = 0;

    // TODO: these do not need initial locations for the actual game code
    // the locations should be read from the updated registers
    opponent = (Pad_t*)malloc(sizeof(Pad_t));
    opponent->posX = WIDTH / 2;
    opponent->posY = HEIGHT / 2;

    popponent = (Pad_t*)malloc(sizeof(Pad_t));
    popponent->posX = WIDTH / 2;
    popponent->posY = HEIGHT / 2;

    paddle = (Pad_t*)malloc(sizeof(Pad_t));
    paddle->posX = WIDTH / 2;
    paddle->posY = HEIGHT / 2;

    mouse = (Pad_t*)malloc(sizeof(Pad_t));
    mouse->posX = WIDTH / 2;
    mouse->posY = HEIGHT / 2;

    pmouse->posX += 30;

    difficulty = 1;

    // TODO: wait for a mouse click here
}

void update_game ()
{
    opp_update();
    paddle_update();
    ball_update();
}

void writeExit ()
{
    FILE *fp;
    int i,j;
    fp=fopen("test.txt", "w");
    fprintf(fp, "0\t");
    for (i = 0; i < 1000; i++)
    {
        fprintf(fp, "%d\t", i);
    }
    fprintf(fp,"\n");

    for (i = 0; i < 1000; i++)
    {
        fprintf(fp, "%d\t", i);
        for (j = 0; j < 1000; j++)
        {
            fprintf(fp, "%d\t", grid[i][j]);
        }
        fprintf(fp, "\n");
    }
    fclose(fp);
    exit(0);
}

void mousePressed ()
{
    // make sure game hasn't started yet
    // TODO: not used
    if (stopped)
        stopped = FALSE;
}
