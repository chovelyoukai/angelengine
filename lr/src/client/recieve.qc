#include "recieve.qh"

void CSQC_Ent_Update(float isNew)
{
	vector newOrigin;
	vector newVelocity;
	float entType = readbyte();
	float flags;
	float moveInterp = cvar("cl_moveinterp");
	float interp;
	float diff;

	switch (entType)
	{
	case ENT_PLAYER:
		flags = readbyte();
		self.movetype = MOVETYPE_WALK;
		if (flags & FL_ORIGIN)
		{
			newOrigin.x = readcoord();
			newOrigin.y = readcoord();
			newOrigin.z = readcoord();

			diff = vlen(newOrigin - self.origin);

			if (diff > 320)
			{
				interp = 0;
			}
			else
			{
				interp = diff / 320;
			}

			if (moveInterp == 0)
			{
				interp = 0;
			}

			newOrigin = (self.origin * interp) + (newOrigin * (1 - interp));

			setorigin(self, newOrigin);
		}
		if (flags & FL_VELOCITY)
		{
			newVelocity.x = readcoord();
			newVelocity.y = readcoord();
			newVelocity.z = readcoord();

			diff = vlen(newVelocity - self.velocity);

			if (diff > 320)
			{
				interp = 0;
			}
			else
			{
				interp = diff /320;
			}

			if (moveInterp == 0)
			{
				interp = 0;
			}

			newVelocity = (self.velocity * interp) + (newVelocity * (1 - interp));
			self.velocity = newVelocity;
		}
		player = self;	
	}
}
