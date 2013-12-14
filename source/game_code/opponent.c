#include <stdint.h>
#include "curveball.h"

void opp_update ()
{
    opponent->posX = ball->posX;
    opponent->posY = ball->posY;
    popponent->posX = opponent->posX;
    popponent->posY = opponent->posY;

    // TODO: read in new opponent values from the spart
}
