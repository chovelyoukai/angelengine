#include "predict.qh"

void Predict()
{
    float inputFrame;
    entity oldSelf;

    if (player)
    {
        for (inputFrame = servercommandframe + 1;
            inputFrame < clientcommandframe; inputFrame += 1)
        {
            if(!getinputstate(inputFrame))
            {
                continue;
            }

            oldSelf = self;
            self = player;
            PlayerMove();
            self = oldSelf;
        }

        if (player.fixOrigin)
        {
            setorigin(player, (player.origin + player.correctOrigin) / 2);
            if (vlen(player.origin - player.correctOrigin) > 0.1)
            {
                player.fixOrigin = FALSE;
            }
        }
        if (player.fixVelocity)
        {
            player.velocity = (player.velocity + player.correctVelocity) / 2;
            if (vlen(player.velocity - player.correctVelocity) > 0.1)
            {
                player.fixVelocity = FALSE;
            }
        }
        setviewprop(VF_ORIGIN, player.origin + PLAYER_VIEW_STAND);
    }
}
