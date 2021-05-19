#include "impulses.qh"

void CheckImpulses()
{
	if (self.impulse >= IMP_SLOT1 && self.impulse < MAX_WEAPONS)
	{
		SwitchWeapons(self.impulse);
	}
	switch (self.impulse)
	{
		case IMP_SUICIDE:
			ClientKill();
			break;
	}

	self.impulse = 0;
}
