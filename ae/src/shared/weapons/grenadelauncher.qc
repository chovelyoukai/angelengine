#include "grenadelauncher.qh"

void GrenadelauncherEquip(entity grenadelauncher)
{
	grenadelauncher.fireTimeout = time + deployTimes[WEP_GRENADELAUNCHER];
#ifdef CSQC
	SetViewmodel(viewmodels[WEP_GRENADELAUNCHER], deployTimes[WEP_GRENADELAUNCHER]);
#endif
}

void GrenadelauncherUnequip(entity grenadelauncher)
{
}

void GrenadelauncherFire(entity grenadelauncher)
{
	if (grenadelauncher.fireTimeout > time)
	{
		return;
	}
#ifdef SSQC
	vector start, muzzle;
	vector direction;
	float traceFlags = MOVE_NORMAL;
	float gravityMultiplier = 1;

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		gravityMultiplier = -1;
	}

	makevectors(self.v_angle);
	start = self.origin + self.view_ofs;

	muzzle = start + (v_forward * 19) + (v_up * -3 * gravityMultiplier);
	direction = (v_forward * 10) + (v_up * 2 * gravityMultiplier);
	traceline(start, muzzle, traceFlags, self);
	EmitGrenade(trace_endpos, direction);

	direction = (v_forward * 10) + (v_up * 4 * gravityMultiplier);
	EmitGrenade(trace_endpos, direction);

	direction = (v_forward * 10) + (v_up * gravityMultiplier) + (v_right * 2);
	EmitGrenade(trace_endpos, direction);

	direction = (v_forward * 10) + (v_up * gravityMultiplier) + (v_right * -2);
	EmitGrenade(trace_endpos, direction);

	sound(self, CHAN_AUTO, "weapons/grenade_fire.ogg", 0.5, ATTN_NORM);
	sound(self, CHAN_AUTO, "weapons/hook_fire.ogg", 0.5, ATTN_NORM);
#else
	ViewmodelAttack(fireTimes[WEP_GRENADELAUNCHER]);
#endif

	grenadelauncher.fireTimeout = time + fireTimes[WEP_GRENADELAUNCHER];
}

float GrenadelauncherCanEquip(entity grenadelauncher)
{
	return TRUE;
}

float GrenadelauncherCanUnequip(entity grenadelauncher)
{
	return TRUE;
}

entity GrenadelauncherSpawn()
{
	entity grenadelauncher = spawn();

	grenadelauncher.Equip = GrenadelauncherEquip;
	grenadelauncher.Unequip = GrenadelauncherUnequip;
	grenadelauncher.Fire = GrenadelauncherFire;
	grenadelauncher.CanEquip = GrenadelauncherCanEquip;
	grenadelauncher.CanUnequip = GrenadelauncherCanUnequip;
	grenadelauncher.Knockback = GenericKnockback;
	grenadelauncher.classname = "weapon_grenadelauncher";
	grenadelauncher.weaponType = WEP_GRENADELAUNCHER;
	grenadelauncher.owner = self;

	return grenadelauncher;
}

#ifdef SSQC
void EmitGrenade(vector muzzle, vector direction)
{
	entity grenade = spawn();
	direction = normalize(direction);

	grenade.classname = "grenade";
	grenade.projectileType = PROJ_GRENADE;
	grenade.Knockback = RocketKnockback;
	grenade.owner = self;
	grenade.movetype = MOVETYPE_BOUNCE;
	grenade.solid = SOLID_BBOX;
	grenade.velocity = direction * GRENADE_VELOCITY;
	grenade.angles = vectoangles(grenade.velocity);
	grenade.avelocity.x = 1000 * random();
	grenade.avelocity.y = 1000 * random();
	grenade.avelocity.z = 1000 * random();

	setmodel(grenade, "models/weapons/grenade.iqm");
	setsize(grenade, '0 0 0', '0 0 0');
	setorigin(grenade, muzzle);

	grenade.effects |= EF_DIMLIGHT;
	grenade.touch = GrenadeTouch;
	grenade.think = GrenadeThink;
	grenade.nextthink = time + 2.5 + (1 * random());

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		grenade.gravity = -1;
	}
}

void GrenadeTouch()
{
	if (other == self.owner)
	{
		return;
	}
	if (other.classname == "player")
	{
		GrenadeThink();
	}

	if (vlen(self.velocity) < 5)
	{
		self.velocity = '0 0 0';
		self.avelocity = '0 0 0';
		self.touch = DoNothing;
		self.movetype = MOVETYPE_NONE;
	}
}

void GrenadeThink()
{
	RadiusDamage(self, self.owner, 45, 300);

	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord(MSG_MULTICAST, self.origin.x);
	WriteCoord(MSG_MULTICAST, self.origin.y);
	WriteCoord(MSG_MULTICAST, self.origin.z);
	multicast(self.origin, MULTICAST_ALL);
	remove(self);
}
#endif
