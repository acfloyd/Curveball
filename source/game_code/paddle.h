
#ifndef P_DEFINES
#define P_DEFINES
#define PAD_HEIGHT 19
#define PAD_WIDTH 25
#endif 

typedef struct Paddle
{
    int16_t posX;
    int16_t posY;
} Pad_t;

void paddle_update();
