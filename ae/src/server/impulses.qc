#include "impulses.qh"

void CheckImpulses()
{
	if (self.impulse >= IMP_SLOT1 && self.impulse < MAX_WEAPONS)
	{
		SwitchWeapons(self.impulse);
	}

	if (self.impulse == IMP_DROP)
	{
		RemoveWeapon(self, slot[self.currentWeapon.weaponType]);
	}

	self.impulse = 0;
}
