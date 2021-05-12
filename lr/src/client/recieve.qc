#include "recieve.qh"

void CSQC_Ent_Update(float isNew)
{
	float entType = readbyte();
	float flags;

	switch (entType)
	{
	case ENT_PLAYER:
		flags = readbyte();
		if (flags & FL_ORIGIN)
		{
			self.origin.x = readcoord();
			self.origin.y = readcoord();
			self.origin.z = readcoord();
			setorigin(self, self.origin);
		}
		if (flags & FL_VELOCITY)
		{
			self.velocity.x = readcoord();
			self.velocity.y = readcoord();
			self.velocity.z = readcoord();
		}
		player = self;	
	}
}
