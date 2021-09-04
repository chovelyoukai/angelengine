#include "trigger_weapongive.qh"

void trigger_weapongive()
{
	InitTrigger();
	self.touch = trigger_weapongiveTouch;
}

void trigger_weapongiveTouch()
{
	if (other.classname != "player")
	{
		return;
	}
	
	GiveWeapon(other, self.weaponType);
}
