
#ifndef B_DEFINES
#define B_DEFINES
#define BALL_RAD 35
#define VELZ_INC 20
#define VELXY_FACTOR_FIRST 10
#define VELXY_FACTOR_HIT 2

#define VEL_FACTOR 2000
#endif

typedef struct Ball 
{
    int16_t posX;
    int16_t posY;
    int16_t posZ;
    int16_t velX;
    int16_t velY;
    int16_t velZ;
} Ball_t;

void ball_update();
uint16_t intersect();

