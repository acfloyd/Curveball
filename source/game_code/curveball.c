
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include "curveball.h"

int grid[100][100];

void main (int argc, char** argv)
{
    // X is rows, Z is col, value is Y

    if (argc != 4)
    {
        printf("usage: insert ball velocities with format below\n<velX> <velY> <velZ>\n");
        exit(0);
    }

    setup();

    ball->velX = atoi(argv[1]);
    ball->velY = atoi(argv[2]);
    ball->velZ = atoi(argv[3]);

    printf("ball: velX=%d, velY=%d, velZ=%d\n", ball->velX, ball->velY, ball->velZ);

    // for testing, the program ends after so many wall hits
    while (TRUE)
    {
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

        update_game();
    }

}

void setup ()
{
    // init the ball and the opponent
    pball = NULL;
    ball = (Ball_t*)malloc(sizeof(Ball_t));
    ball->posX = WIDTH / 2;
    ball->posY = HEIGHT / 2;
    ball->posZ = BALL_RAD;
    ball->velX = 0;
    ball->velY = 0;
    ball->velZ = 100;

    opponent = (Pad_t*)malloc(sizeof(Pad_t));
    opponent->posX = WIDTH / 2;
    opponent->posY = HEIGHT / 2;
    paddle = (Pad_t*)malloc(sizeof(Pad_t));
    paddle->posX = WIDTH / 2;
    paddle->posY = WIDTH / 2;
    mouse = (Pad_t*)malloc(sizeof(Pad_t));
    mouse->posX = WIDTH / 2;
    mouse->posY = HEIGHT / 2;
    pmouse = (Pad_t*)malloc(sizeof(Pad_t));
    pmouse->posX = WIDTH / 2;
    pmouse->posY = HEIGHT / 2;
    
    oppScore = 0;
    playerScore = 0;
    difficulty = 1;
}

void update_game ()
{
    opp_update();
    ball_update();
    paddle_update();
}

void restart ()
{
    // TODO: temp stop for simulation
    FILE *fp;
    int i,j;
    fp=fopen("test.txt", "w");
    fprintf(fp, "0\t");
    for (i = 0; i < 100; i++)
    {
        fprintf(fp, "%d\t", i*10);
    }
    fprintf(fp,"\n");

    for (i = 0; i < 100; i++)
    {
        fprintf(fp, "%d\t", i*5);
        for (j = 0; j < 100; j++)
        {
            fprintf(fp, "%d\t", grid[i][j]);
        }
        fprintf(fp, "\n");
    }
    fclose(fp);
    exit(0);


    fprintf(fp, "%d\t%d\t%d\n", ball->posX, ball->posY, ball->posZ);

    stopped = TRUE;
    first = TRUE;
    free((void*)ball);
    ball = malloc(sizeof(Ball_t));
    oppScore = 0;
    playerScore = 0;
}

void mousePressed ()
{
    // make sure game hasn't started yet
    if (stopped)
        stopped = FALSE;
}
