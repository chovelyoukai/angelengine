#include "weapons.qh"
#include "damage.qh"

float CheckWeapons()
{
	if (self.button0)
	{
		if (self.currentWeapon != world)
		{
			self.currentWeapon.Fire(self.currentWeapon);
		}

		return TRUE;
	}

	return FALSE;
}

void SwitchWeapons(float impulse)
{
	impulse--;

	if (self.weapons[impulse] != world &&
		self.currentWeapon != self.weapons[impulse])
	{
		// our current weapon must agree that it can be switched off of,
		// and our desired weapon must agree that it can be equipped.
		// this allows all kinds of weapon-specific behaviours.
		if (self.currentWeapon.CanSwitch(self.currentWeapon) &&
			self.weapons[impulse].CanEquip(self.weapons[impulse]))
		{
			self.currentWeapon = self.weapons[impulse];
			self.currentWeapon.Equip(self.currentWeapon);
		}
		else
		{
			print("can't switch :(\n");
		}
	}
}
