#include <stdint.h>
#include "curveball.h"

void paddle_update ()
{
    pmouse->posX = paddle->posX;
    pmouse->posY = paddle->posY;
    paddle->posX = mouse->posX;
    paddle->posY = mouse->posY;
}
