#include "trigger_weaponstrip.qh"

void trigger_weaponstrip()
{
	InitTrigger();
	self.touch = trigger_weaponstripTouch;
}

void trigger_weaponstripTouch()
{
	float i;

	if (other.classname != "player")
	{
		return;
	}

	for (i = 0; i < MAX_WEAPONS; i++)
	{
		if (other.weapons[i].weaponType == self.weaponType)
		{
			RemoveWeapon(other, slot[self.weaponType]);
		}
	}
}
