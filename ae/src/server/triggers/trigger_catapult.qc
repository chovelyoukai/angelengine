#include "trigger_catapult.qh"

void trigger_catapult()
{
	InitTrigger();
	self.touch = trigger_catapultTouch;
}

void trigger_catapultTouch()
{
	entity destination;

	if (other.classname != "player")
	{
		return;
	}

	destination = find(world, targetname, self.target);

	other.groundEntity = other;
	setorigin(other, other.origin + '0 0 1' * (other.moveFlags & MF_REVERSEGRAV ? -1 : 1));

	if (destination)
	{
		vector diff = destination.origin - other.origin;
		diff = normalize(diff) * self.maxspeed;
		other.velocity = diff;
	}
}
