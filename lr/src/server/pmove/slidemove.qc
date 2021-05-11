#include "pmove.qh"

void TracePlayer(vector start, vector end)
{
	tracebox(start, PLAYER_MIN_STAND, PLAYER_MAX_STAND, end, 0, self);
}

vector ClipVelocity(vector normal, float overbounce)
{
	return ClipVector(self.velocity, normal, overbounce);
}

vector ClipVector(vector inVector, vector normal, float overbounce)
{
	float backoff;
	vector change, out;

	backoff = DotProduct(inVector, normal);

	if (backoff < 0)
	{
		backoff *= overbounce;
	}
	else
	{
		backoff /= overbounce;
	}

	change = normal * backoff;
	out = inVector - change;

	return out;
}

float DoesInteract(vector normal)
{
	if (DotProduct(self.velocity, normal) >= SLIDEMOVE_INTERACT_EPSILON)
	{
		return FALSE;
	}
	else
	{
		return TRUE;
	}
}

float SlideMove()
{
	vector end, dir;
	vector oldVel, lastValidOrigin;
	vector planes[MAX_CLIP_PLANES];
	float value, numplanes;
	float moves, maxmoves;
	float i, j, k;
	float remainingTime, blocked;

	remainingTime = frametime;
	maxmoves = 4;
	blocked = FALSE;
	numplanes = 0;

	oldVel = self.velocity;
	lastValidOrigin = self.origin;

	if (IsOnGround())
	{
		if (self.groundNormal.z == 1 && self.velocity.z < 0)
		{
			self.velocity.z = 0;
		}
	}

	for (moves = 0; moves < maxmoves; moves++)
	{
		end = self.origin + self.velocity * remainingTime;
		TracePlayer(self.origin, end);

		// if we are stuck in something, we are done
		if (trace_allsolid)
		{
			self.origin = lastValidOrigin;
			blocked = TRUE;
			return blocked;
		}

		// move us to wherever the box stopped
		if (trace_fraction > 0)
		{
			self.origin = trace_endpos;
			lastValidOrigin = trace_endpos;
		}

		// if we didn't hit anything, we are done.
		if (trace_fraction == 1)
		{
			break;
		}

		// we must have hit something
		blocked = TRUE;

		remainingTime -= trace_fraction * remainingTime;
		
		for (i = 0; i < numplanes; i++)
		{
			if (DotProduct(trace_plane_normal, planes[i]) >
				(1 - SLIDEMOVE_INTERACT_EPSILON))
			{
				self.velocity = self.velocity + trace_plane_normal;
				break;
			}
		}

		if (i < numplanes)
		{
			continue;
		}

		// if we hit too many planes, we are trapped
		if (numplanes > MAX_CLIP_PLANES)
		{
			self.velocity = '0 0 0';
			blocked = TRUE;
			return blocked;
		}

		planes[numplanes] = trace_plane_normal;
		numplanes++;

		for (i = 0; i < numplanes; i++)
		{
			if (DoesInteract(planes[i]) == FALSE)
			{
				continue;
			}

			self.velocity = ClipVelocity(planes[i], OVERBOUNCE);

			for (j = 0; j < numplanes; j++)
			{
				if (j == i || DoesInteract(planes[j]) == FALSE)
				{
					continue;
				}

				self.velocity = ClipVelocity(planes[j], OVERBOUNCE);

				// did we move back into the first plane?
				if (DoesInteract(planes[i]) == FALSE)
				{
					continue;
				}

				dir = CrossProduct(planes[i], planes[j]);
				dir = normalize(dir);
				value = DotProduct(dir, self.velocity);
				self.velocity = dir * value;

				for (k = 0; k < numplanes; k++)
				{
					if (k == i || j == i || DoesInteract(planes[k]) == FALSE)
					{
						continue;
					}

					self.velocity = '0 0 0';
					break;
				}
			}
		}
	}

	return blocked;
}
