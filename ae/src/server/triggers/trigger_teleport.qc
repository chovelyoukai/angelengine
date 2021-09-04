#include "trigger_teleport.qh"

void info_teleport_destination()
{
}

void trigger_teleport()
{
	InitTrigger();
	self.touch = trigger_teleportTouch;
}

void trigger_teleportTouch()
{
	entity destination;

	if (other.classname != "player")
	{
		return;
	}

	destination = find(world, targetname, self.target);

	if (destination)
	{
		setorigin(other, destination.origin);
		if (self.resetVelocity)
		{
			other.velocity = '0 0 0';
		}
		if (self.redirectVelocity)
		{
			float speed = vlen(other.velocity);
			vector newVel;

			makevectors(destination.angles);
			newVel = v_forward * speed;
			other.velocity = newVel;
		}
		if (self.dontRedirectAngles == 0)
		{
			other.v_angle = destination.angles;
		}
		other.SendFlags |= FL_SNAP;
	}
}
