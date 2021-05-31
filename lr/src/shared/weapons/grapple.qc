#include "grapple.qh"

void GrappleEquip(entity grapple)
{
	print("Equip GH!\n");
}

void GrappleFire(entity grapple)
{
	if (grapple.fireTimeout > time)
	{
		return;
	}
	print("fire!\n");
	grapple.fireTimeout = time + GRAPPLE_FIRE_TIME;
}

float GrappleCanEquip(entity grapple)
{
	return TRUE;
}

float GrappleCanSwitch(entity grapple)
{
	return TRUE;
}

entity GrappleSpawn()
{
	entity grapple = spawn();

	grapple.Equip = GrappleEquip;
	grapple.Fire = GrappleFire;
	grapple.CanEquip = GrappleCanEquip;
	grapple.CanSwitch = GrappleCanSwitch;
	grapple.classname = "weapon_grapple";

	return grapple;
}
