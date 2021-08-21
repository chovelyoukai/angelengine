#include "predict.qh"

void Predict()
{
    if (player)
    {
        if (player.fixOrigin)
        {
            setorigin(player, 0.9 * player.origin + 0.1 * player.correctOrigin);
            if (vlen(player.origin - player.correctOrigin) > 0.1)
            {
                player.fixOrigin = FALSE;
            }
        }
        if (player.fixVelocity)
        {
            player.velocity = 0.9 * player.velocity + 0.1
                * player.correctVelocity;
            if (vlen(player.velocity - player.correctVelocity) > 0.1)
            {
                player.fixVelocity = FALSE;
            }
        }
        getinputstate(clientcommandframe - 1);
        //UpdateViewmodel();
        setviewprop(VF_ORIGIN, player.origin + PLAYER_VIEW_STAND);
    }
}
