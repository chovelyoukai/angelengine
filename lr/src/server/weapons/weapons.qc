#include "weapons.qh"

float CheckWeapons()
{
	if (self.button0)
	{
		if (self.currentWeapon != world)
		{
			self.currentWeapon.attack();
		}

		return TRUE;
	}

	return FALSE;
}

void SwitchWeapons(float impulse)
{
	self.currentWeapon = self.weapons[impulse];
}
