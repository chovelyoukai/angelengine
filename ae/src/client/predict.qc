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
		vector currentView = '0 0 0';
		float target;
		if (player.moveFlags & MF_REVERSEGRAV)
		{
			target = 180;
			sens = cvar("sensitivity");
			if (sens > 0)
			{
				localcmd("sensitivity ", ftos(sens * -1), "\n");
			}
			if (currentHeight > player.view_ofs.z)
			{
				currentHeight -= 10;
			}
			if (currentHeight < player.view_ofs.z)
			{
				currentHeight = player.view_ofs.z;
			}
		}
		else
		{
			target = 0;
			setviewprop(VF_ANGLES_Z, currentRoll);
			sens = cvar("sensitivity");
			if (sens < 0)
			{
				localcmd("sensitivity ", ftos(sens * -1), "\n");
			}
			if (currentHeight < player.view_ofs.z)
			{
				currentHeight += 10;
			}
			if (currentHeight > player.view_ofs.z)
			{
				currentHeight = player.view_ofs.z;
			}
		}


		currentRoll = Approach(currentRoll, target, cvar("cl_rollrate"));

		float tilt = 0;
		if (IsOnWall(player))
		{
			makevectors(view_angles);

			v_right.z = 0;
			v_right = normalize(v_right);

			float dot = v_right * player.wallNormal;

			tilt += dot * 7.5 * (player.moveFlags & MF_REVERSEGRAV ? -1 : 1);
		}

		currentTilt = Approach(currentTilt, tilt, cvar("cl_tiltrate"));

		setviewprop(VF_ANGLES_Z, currentRoll + currentTilt);
		currentView.z = currentHeight;
		setviewprop(VF_ORIGIN, player.origin + currentView);
	}
}

float Approach(float current, float target, float rate)
{
	if (current > target)
	{
		current -= rate * frametime;
		if (current < target)
		{
			current = target;
		}
	}
	else if (current < target)
	{
		current += rate * frametime;
		if (current > target)
		{
			current = target;
		}
	}

	return current;
}
