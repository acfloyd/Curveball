
#ifndef B_DEFINES
#define B_DEFINES

#define BALL_RAD 35
#define VELZ_INC 20
#define VELXY_FACTOR_FIRST 10
#define VELXY_FACTOR_HIT 2

#define VEL_FACTOR 2000
#define CURVE_REDUCE 20

#define T_2ND(Z) ((Z * 11) / 1200)
#define T_3RD(Z) ((Z * 11) / 800)
#define T_4TH(Z) ((Z * 13) / 600)
#define T_5TH(Z) ((Z * 16) / 400)

#define EQ_2ND(Z, D) (D * ((54 * T_2ND(Z)) - (5 * T_2ND(Z) * T_2ND(Z))))
#define EQ_3RD(Z, D) (D *((54 * T_3RD(Z)) - (5 * T_3RD(Z) * T_3RD(Z))))
#define EQ_4TH(Z, D) (D *((63 * T_4TH(Z)) - (5 * T_4TH(Z) * T_4TH(Z))))
#define EQ_5TH(Z, D) (D * ((77 * T_5TH(Z)) - (5 * T_5TH(Z) * T_5TH(Z))))

#endif

typedef struct Ball 
{
    int16_t posX;
    int16_t posY;
    int16_t posZ;
    int16_t velX;
    int16_t velY;
    int16_t velZ;
    int16_t dirX;
    int16_t dirY;
} Ball_t;

void save_ball();
void ball_update();
uint16_t intersect();

