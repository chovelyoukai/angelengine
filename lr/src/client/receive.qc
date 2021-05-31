#include "receive.qh"

void CSQC_Ent_Update(float isNew)
{
	float entType = readbyte();

	switch (entType)
	{
	case ENT_PLAYER:
		ReceivePlayer(isNew, TRUE);
		break;
	case ENT_PLAYER_OTHER:
		ReceivePlayer(isNew, FALSE);
		break;
	}
}

void CSQC_EntRemove()
{
	remove(self);
}

void ReceivePlayer(float isNew, float isLocalPlayer)
{
	vector newOrigin;
	vector newVelocity;
	float flags;
	float moveInterp = cvar("cl_moveinterp");
	float interp;
	float diff;

	flags = readbyte();
	self.movetype = MOVETYPE_WALK;
	if (flags & FL_ORIGIN)
	{
		newOrigin.x = readcoord();
		newOrigin.y = readcoord();
		newOrigin.z = readcoord();

		diff = vlen(newOrigin - self.origin);
		
	//	if (isLocalPlayer)
	//	{
	//		print("diff origin is: ", ftos(diff), "\n");
	//	}

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
	if (flags & FL_MOVETYPE)
	{
		self.movetype = readlong();
	}
	if (flags & FL_MODELINDEX)
	{
		readbyte();
	}

	if (isLocalPlayer)
	{
		player = self;	
	}
	else if (!isLocalPlayer && isNew)
	{
		self.drawmask = MASK_ENGINE;
		setmodel(self, "models/player.iqm");
		setsize(self, PLAYER_MIN_STAND, PLAYER_MAX_STAND);
	}
}
