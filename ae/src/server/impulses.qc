#include "impulses.qh"

void CheckImpulses()
{
	if (self.impulse >= IMP_SLOT1 && self.impulse < MAX_WEAPONS)
	{
		SwitchWeapons(self.impulse);
	}

    if (self.impulse == 69)
    {
        SendKill(self);
    }

	self.impulse = 0;
}
