#include "predict.qh"

void Predict()
{
	float interp = cvar("cl_moveinterp");
	float correction = 1 - interp;
	float sens;
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
		setviewprop(VF_ORIGIN, player.origin + player.view_ofs);
		if (player.moveFlags & MF_REVERSEGRAV)
		{
			if (currentRoll < 180)
			{
				currentRoll += cvar("cl_rollrate") * frametime;
				if (currentRoll > 180)
				{
					currentRoll = 180;
				}
			}
			setviewprop(VF_ANGLES_Z, currentRoll);
			sens = cvar("sensitivity");
			if (sens > 0)
			{
				localcmd("sensitivity ", ftos(sens * -1), "\n");
			}
		}
		else
		{
			if (currentRoll > 0)
			{
				currentRoll -= cvar("cl_rollrate") * frametime;
				if (currentRoll < 0)
				{
					currentRoll = 0;
				}
			}
			setviewprop(VF_ANGLES_Z, currentRoll);
			sens = cvar("sensitivity");
			if (sens < 0)
			{
				localcmd("sensitivity ", ftos(sens * -1), "\n");
			}
		}
	}
}
