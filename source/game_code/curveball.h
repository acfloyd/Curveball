

// game dimentions
#ifndef DEFINES
#define DEFINES

#define TRUE 1
#define FALSE 0
#define HEIGHT 384
#define WIDTH 512
#define DEPTH 1000
#endif

#include "ball.h"
#include "paddle.h"
#include "opponent.h"

// globals
Ball_t* ball; 
Ball_t* pball; // previous ball location to base the parabola curve off of 
Pad_t* opponent; // opponent's paddle
Pad_t* popponent; // prevoius opponent's paddle
Pad_t* paddle; // player's paddle
Pad_t* mouse; // current mouse location
Pad_t* pmouse; // previous mouse location

uint16_t stopped;
uint16_t first;

// scores and difficulty
uint16_t oppScore;
uint16_t playerScore;
uint16_t difficulty;

void setup();
void update_game();
void restart();
void mousePressed();
