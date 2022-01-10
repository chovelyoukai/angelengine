#include "pmove.qh"

void SetGrindOrigin()
{
	vector bottom = self.origin;
	vector start, stopLeft, stopRight;
	vector average;
	vector boxMins, boxMaxs;
	float flags = MOVE_NORMAL;
	float gravityMultiplier = 1;

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		gravityMultiplier = -1;
	}

	boxMins = '-4 -4 -4';
	boxMaxs = '4 4 4';

	bottom.z += self.mins.z * gravityMultiplier;
	bottom.z -= 8 * gravityMultiplier;

	start = bottom;
	start += v_right * 24;
	tracebox(start, boxMins, boxMaxs, bottom, flags, self);
	stopRight = trace_endpos;

	start = bottom;
	start -= v_right * 24;
	tracebox(start, boxMins, boxMaxs, bottom, flags, self);
	stopLeft = trace_endpos;

	average.x = (stopRight.x + stopLeft.x) / 2;
	average.y = (stopRight.y + stopLeft.y) / 2;
	average.z = self.origin.z;

	average = (average + self.origin) / 2;

	setorigin(self, average);
}

void StickToGround()
{

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		TracePlayer(self.origin, self.origin + '0 0 18');
		if (trace_fraction < 1 && trace_plane_normal.z < -0.7)
		{
			setorigin(self, trace_endpos);
		}
	}
	else
	{
		TracePlayer(self.origin, self.origin - '0 0 18');
		if (trace_fraction < 1 && trace_plane_normal.z > 0.7)
		{
			setorigin(self, trace_endpos);
		}
	}
}

float CheckGrind()
{
	vector bottom, start, stop, stopLocation = '0 0 0';
	vector normal, forward, backward;
	vector boxMins, boxMaxs;
	float fmove = input_movevalues.x;
	float speed;
	float flags = MOVE_NORMAL;
	float i, j;
	float hitRight, hitLeft, hit;
	float gravityMultiplier = 1;

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		gravityMultiplier = -1;
	}

	hitRight = hitLeft = hit = FALSE;

	boxMins = '-4 -4 -4';
	boxMaxs = '4 4 4';

	if (!(input_buttons & BUTTON_MOD1))
	{
		return FALSE;
	}

	makevectors(vectoangles(self.velocity));

	forward = backward = '0 0 0';

	bottom = self.origin;
	bottom.z += self.mins.z * gravityMultiplier;

	for (i = -1; i <= 0; i++)
	{
		for (j = -1; j <= 1; j++)
		{
			if (j == 0)
			{
				continue;
			}

			start = bottom;
			start += (v_forward * i * 24) + (v_right * j * 24);
			stop = start;
			stop.z -= 1 * gravityMultiplier;

			traceline(start, stop, flags, self);

			if (trace_fraction == 1)
			{
				if (j == -1)
				{
					hitLeft = TRUE;
					stopLocation = stop;
				}
				else
				{
					hitRight = TRUE;
				}
			}
		}
	}

	if (hitRight && hitLeft)
	{
		hit = TRUE;
	}

	if (hit)
	{
		bottom.z -= 8 * gravityMultiplier;
		stopLocation.z -= 7 * gravityMultiplier;

		tracebox(stopLocation, boxMins, boxMaxs, bottom, flags, self);
		if (trace_fraction == 1)
		{
			return FALSE;
		}

		normal = trace_plane_normal;

		SetGrindOrigin();

		forward.x = -1 * normal.y;
		forward.y = normal.x;
		forward = normalize(forward);
		backward.x = normal.y;
		backward.y = -1 * normal.x;
		backward = normalize(backward);

		speed = vlen(self.velocity);

		if (fmove > 0)
		{
#ifdef SSQC
			makevectors(self.v_angle);
#else
			makevectors(view_angles);
#endif
			if (DotProduct(v_forward, forward) > 0)
			{
				self.velocity = speed * forward;
			}
			else
			{
				self.velocity = speed * backward;
			}
		}
		else
		{
			if (DotProduct(self.velocity, forward) > 0)
			{
				self.velocity = speed * forward;
			}
			else
			{
				self.velocity = speed * backward;
			}
		}

#ifdef SSQC
		if (self.grindTime < time)
		{
			sound(self, CHAN_VOICE, "player/grind.ogg", 0.3, ATTN_NORM);
			self.grindTime = time + 2;
		}
#endif

		return TRUE;
	}
	else
	{
		return FALSE;
	}
}
