#include "pmove.qh"

void SetGrindOrigin(float hitRight, float hitLeft)
{
	vector bottom = self.origin;
	vector start, stopLeft, stopRight;
	vector average;
	vector boxMins, boxMaxs;
	float flags = MOVE_NORMAL;
	float gravityMultiplier = 1;

	start = stopLeft = stopRight = '0 0 0';

	if (!hitRight && !hitLeft)
	{
		return;
	}

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		gravityMultiplier = -1;
	}

	boxMins = '-4 -4 -4';
	boxMaxs = '4 4 4';

	bottom.z += self.mins.z * gravityMultiplier;
	bottom.z -= SKATE_DIST_VERT * gravityMultiplier;

	if (hitRight)
	{
		start = bottom;
		start += v_right * SKATE_DIST_HORIZ;
		tracebox(start, boxMins, boxMaxs, bottom, flags, self);
		stopRight = trace_endpos;
	}
	if (hitLeft)
	{
		start = bottom;
		start -= v_right * SKATE_DIST_HORIZ;
		tracebox(start, boxMins, boxMaxs, bottom, flags, self);
		stopLeft = trace_endpos;
	}

	if (!hitRight)
	{
		stopLeft = stopRight = stopLeft + 0.25 * SKATE_DIST_HORIZ * normalize(bottom - start);
	}
	if (!hitLeft)
	{
		stopLeft = stopRight = stopRight + 0.25 * SKATE_DIST_HORIZ * normalize(bottom - start);
	}

	average.x = (stopRight.x + stopLeft.x) / 2;
	average.y = (stopRight.y + stopLeft.y) / 2;
	average.z = self.origin.z;

	average = (average + self.origin) / 2;

	TracePlayer(average, average);
	if (!trace_allsolid && trace_fraction > 0.99)
	{
		setorigin(self, average);
	}
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
	float j;
	float hitRight, hitLeft;
	float gravityMultiplier = 1;

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		gravityMultiplier = -1;
	}

	hitRight = hitLeft = FALSE;

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

	if (fabs(self.groundNormal.z) < 1)
	{
		traceline(bottom, bottom + ('0 0 -100' * gravityMultiplier), flags, self);
		if (trace_fraction < 1)
		{
			bottom = trace_endpos;
		}
	}

	for (j = -1; j <= 1; j++)
	{
		if (j == 0)
		{
			continue;
		}

		start = bottom;
		start += v_right * j * SKATE_DIST_HORIZ;
		stop = start;
		stop.z -= SKATE_DIST_VERT * gravityMultiplier;

		traceline(start, stop, flags, self);
#if 0
#ifdef CSQC
		entity hook = spawn();
		hook.projectileType = PROJ_HOOK;
		hook.ownerOrigin = start;
		setorigin(hook, trace_endpos);
		hook.think = RemoveSelf;
		hook.nextthink = time + 10.5;
#endif
#endif

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
				stopLocation = stop;
			}
		}
	}

	if (hitRight || hitLeft)
	{
		bottom.z -= SKATE_DIST_VERT * gravityMultiplier;
		bottom += normalize(bottom - stopLocation) * SKATE_TRACE_IN;

		tracebox(stopLocation, boxMins, boxMaxs, bottom, flags, self);
#if 0
#ifdef CSQC
		entity hook = spawn();
		hook.projectileType = PROJ_HOOK;
		hook.ownerOrigin = stopLocation;
		setorigin(hook, trace_endpos);
		hook.think = RemoveSelf;
		hook.nextthink = time + 10.5;
#endif
#endif
		if (trace_fraction == 1 || trace_allsolid)
		{
			return FALSE;
		}

		normal = trace_plane_normal;

		if (normal.z != 0)
		{
			return FALSE;
		}

		SetGrindOrigin(hitRight, hitLeft);

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
