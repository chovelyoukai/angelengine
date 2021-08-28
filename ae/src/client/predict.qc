#include "predict.qh"

void Predict()
{
	float interp = cvar("cl_moveinterp");
	float correction = 1 - interp;
	if (player)
	{
		if (player.fixOrigin)
		{
			setorigin(player, interp * player.origin + correction
			          * player.correctOrigin);
			if (vlen(player.origin - player.correctOrigin) > 0.1)
			{
				player.fixOrigin = FALSE;
			}
		}
		if (player.fixVelocity)
		{
			player.velocity = interp * player.velocity + correction
			                  * player.correctVelocity;
			if (vlen(player.velocity - player.correctVelocity) > 0.1)
			{
				player.fixVelocity = FALSE;
			}
		}
		getinputstate(clientcommandframe - 1);
		UpdateViewmodel();
		setviewprop(VF_ORIGIN, player.origin + PLAYER_VIEW_STAND);
	}
}
