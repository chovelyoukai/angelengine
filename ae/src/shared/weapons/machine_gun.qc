#include "machine_gun.qh"

void MachineGunEquip(entity machine_gun)
{
	machine_gun.fireTimeout = time + deployTimes[WEP_MACHINE_GUN];
#ifdef CSQC
	SetViewmodel(viewmodels[WEP_MACHINE_GUN], deployTimes[WEP_MACHINE_GUN]);
#endif
}

void MachineGunUnequip(entity machine_gun)
{
}

void MachineGunFire(entity machine_gun)
{
	if (machine_gun.fireTimeout > time)
	{
		return;
	}
#ifdef SSQC
	float speed, flags = MOVE_LAGGED;
	vector aim;

	makevectors(self.v_angle);
	aim = self.origin + self.view_ofs + v_forward * 10000;
	aim += v_right * 300 * (random() - 0.5);
	aim += v_up * 300 * (random() - 0.5);
	traceline(self.origin + self.view_ofs, aim, flags, self);

	speed = 110 - (random() * 20);
	sound(self, CHAN_AUTO, "weapons/machine_gun_fire.wav", 0.5, ATTN_NORM, speed);

	if (trace_fraction < 1 && trace_ent.classname == "player")
	{
		particle(trace_endpos, trace_plane_normal, 64, 5 * 3);
		Damage(trace_ent, machine_gun, self, 5);
	}
	else if (trace_fraction < 1)
	{
		particle(trace_endpos, trace_plane_normal, 0, 5);
		particle(trace_endpos, trace_plane_normal, 192, 2);
	}
#else
	ViewmodelAttack(fireTimes[WEP_MACHINE_GUN]);
#endif

	machine_gun.fireTimeout = time + fireTimes[WEP_MACHINE_GUN];
}

float MachineGunCanEquip(entity machine_gun)
{
	return TRUE;
}

float MachineGunCanUnequip(entity machine_gun)
{
	return TRUE;
}

entity MachineGunSpawn()
{
	entity machine_gun = spawn();

	machine_gun.Equip = MachineGunEquip;
	machine_gun.Unequip = MachineGunUnequip;
	machine_gun.Fire = MachineGunFire;
	machine_gun.CanEquip = MachineGunCanEquip;
	machine_gun.CanUnequip = MachineGunCanUnequip;
	machine_gun.Knockback = GenericKnockback;
	machine_gun.classname = "weapon_shotgun";
	machine_gun.weaponType = WEP_MACHINE_GUN;
	machine_gun.owner = self;

	return machine_gun;
}
