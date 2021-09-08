#include "grapple.qh"
#pragma target fte

void GrappleEquip(entity grapple)
{
	self.weaponType = WEP_GRAPPLE;
	grapple.fireTimeout = time + deployTimes[WEP_GRAPPLE];

#ifdef CSQC
	SetViewmodel(viewmodels[WEP_GRAPPLE], deployTimes[WEP_GRAPPLE]);
#endif
}

void GrappleUnequip(entity grapple)
{
}

void GrappleFire(entity grapple)
{
	if (grapple.fireTimeout > time)
	{
		return;
	}

#ifdef SSQC
	float speed = 100 + (10 * random()) - 5;
	sound(self, CHAN_AUTO, "weapons/hook_fire.ogg", 0.3, 0.5, speed);

	if (self.currentHook == world)
	{
		EmitHook();
	}
	else
	{
		remove(self.currentHook);	
		self.currentHook = world;
		self.grappled = FALSE;
	}
#else
	ViewmodelAttack(fireTimes[WEP_GRAPPLE]);
#endif
	grapple.fireTimeout = time + fireTimes[WEP_GRAPPLE];
}

float GrappleCanEquip(entity grapple)
{
	return TRUE;
}

float GrappleCanUnequip(entity grapple)
{
	return TRUE;
}

entity GrappleSpawn()
{
	entity grapple = spawn();

	grapple.Equip = GrappleEquip;
	grapple.Unequip = GrappleUnequip;
	grapple.Fire = GrappleFire;
	grapple.CanEquip = GrappleCanEquip;
	grapple.CanUnequip = GrappleCanUnequip;
	grapple.classname = "weapon_grapple";
	grapple.weaponType = WEP_GRAPPLE;
	grapple.owner = self;

	return grapple;
}

void HookTouch()
{
	if (other.classname == "player")
	{
		return;
	}
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	if (self.owner != world)
	{
		self.owner.hookDistance = vlen(self.origin - self.owner.origin);
		self.owner.grappled = TRUE;
	}
}

#ifdef SSQC
void EmitHook()
{
	vector start, muzzle;
	entity hook;
	float traceFlags = MOVE_NORMAL;

	makevectors(self.v_angle);
	start = self.origin + self.view_ofs;
	muzzle = start + (v_forward * 19);

	traceline(start, muzzle, traceFlags, self);

	hook = spawn();
	hook.classname = "hook";
	hook.projectileType = PROJ_HOOK;
	hook.owner = self;
	hook.movetype = MOVETYPE_FLYMISSILE;
	hook.solid = SOLID_BBOX;
	hook.velocity = v_forward * HOOK_VELOCITY;
	hook.angles = vectoangles(hook.velocity);
	hook.SendEntity = ProjectileUpdate;
	hook.SendFlags |= FL_ORIGIN | FL_VELOCITY | FL_OWNER | FL_OWNERORIGIN;

	self.currentHook = hook;

	setmodel(hook, "models/weapons/rocket.iqm");
	setsize(hook, '0 0 0', '0 0 0');
	setorigin(hook, trace_endpos);

	hook.effects |= EF_DIMLIGHT;
	hook.touch = HookTouch;
}
#endif
