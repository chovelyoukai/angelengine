#include "rocketlauncher.qh"

void RocketEquip(entity rocketLauncher)
{
	print("Equip RL!\n");
}

void RocketFire(entity rocketLauncher)
{
	vector start, aim;
	float flags = 0;
	flags |= MOVE_HITMODEL | MOVE_LAGGED;

	if (rocketLauncher.fireTimeout > time)
	{
		return;
	}
	rocketLauncher.fireTimeout = time + ROCKET_FIRE_TIME;

	makevectors(self.v_angle);
	start = self.origin + self.view_ofs;
	aim = start + v_forward * 10000;

	traceline(start, aim, flags, self);

	if (trace_fraction < 1)
	{
		if (trace_ent.classname == "player")
		{
			Damage(trace_ent, rocketLauncher, self, 10);
		}
	}
}

float RocketCanEquip(entity rocketLauncher)
{
	return TRUE;
}

float RocketCanSwitch(entity rocketLauncher)
{
	return TRUE;
}

entity RocketSpawn()
{
	entity rocketLauncher = spawn();

	rocketLauncher.Equip = RocketEquip;
	rocketLauncher.Fire = RocketFire;
	rocketLauncher.CanEquip = RocketCanEquip;
	rocketLauncher.CanSwitch = RocketCanSwitch;
	rocketLauncher.classname = "weapon_rocketlauncher";

	return rocketLauncher;
}
