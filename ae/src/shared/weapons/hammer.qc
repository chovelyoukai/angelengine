#include "hammer.qh"

void HammerEquip(entity hammer)
{
	hammer.fireTimeout = time + deployTimes[WEP_HAMMER];
#ifdef CSQC
	SetViewmodel(viewmodels[WEP_HAMMER], deployTimes[WEP_HAMMER]);
#endif
}

void HammerUnequip(entity shotgun)
{
}

void HammerFire(entity hammer)
{
	float gravityMultiplier = 1;

	if (hammer.fireTimeout > time)
	{
		return;
	}

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		gravityMultiplier = -1;
	}

	traceline(self.origin, self.origin - ('0 0 1000' * gravityMultiplier),
	          0, self);
	float dist = 1000 * trace_fraction;
	float accel = cvar("sv_gravity");

	// how long will it take us to reach the ground?
	float t = (-1 * dist) + sqrt((dist * dist) + (2 * accel * dist));
	t /= (2 * accel);

	if (trace_fraction < 1 && self.velocity.z < -1000 && t > 0.3 && t < 0.4 &&
		!(self.moveFlags & MF_REVERSEGRAV))
	{
		hammer.think = HammerAttack2;
		hammer.nextthink = time + 0.4;
		hammer.fireTimeout = time + fireTimes[WEP_HAMMER];
		hammer.velocity.z = self.velocity.z;
#ifdef CSQC
		ViewmodelAttack(fireTimes[WEP_HAMMER], 4);
#endif
	}
	else if (trace_fraction < 1 && self.velocity.z > 1000 && t > 0.3 && t < 0.4 &&
		self.moveFlags & MF_REVERSEGRAV)
	{
		hammer.think = HammerAttack2;
		hammer.nextthink = time + 0.4;
		hammer.fireTimeout = time + fireTimes[WEP_HAMMER];
		hammer.velocity.z = self.velocity.z;
#ifdef CSQC
		ViewmodelAttack(fireTimes[WEP_HAMMER], 4);
#endif
	}
	else
	{
		hammer.think = HammerAttack;
		hammer.nextthink = time + 0.5;
		hammer.fireTimeout = time + fireTimes[WEP_HAMMER];
#ifdef CSQC
		ViewmodelAttack(fireTimes[WEP_HAMMER]);
#else
		hammer.frags = 20;
#endif
	}
}

void HammerAttack()
{
	if (self != self.owner.currentWeapon)
	{
		return;
	}

#ifdef SSQC
	float flags = MOVE_LAGGED;
	float speed;
	vector ownerOrigin = self.owner.origin + self.owner.view_ofs;
	vector aim;

	if (self.frags == 0)
	{
		return;
	}
	else if (self.frags == 20)
	{
		sound(self.owner, CHAN_AUTO, "weapons/hammer_fire.wav", 0.7, ATTN_NORM);
	}

	makevectors(self.owner.v_angle);

	if (self.owner.moveFlags & MF_REVERSEGRAV)
	{
		v_right *= -1;
	}

	aim = ownerOrigin + (100 * v_forward) + ((self.frags - 10) * 10 * v_right);

	traceline(ownerOrigin, aim, flags, self.owner);

	if (trace_fraction < 1)
	{
		speed = 110 - (random() * 40);
		sound(self.owner, CHAN_AUTO, "weapons/hammer_hit.ogg", 0.1, ATTN_NORM, speed);
		speed = 110 - (random() * 40);
		sound(self.owner, CHAN_AUTO, "weapons/hammer_hit2.ogg", 0.1, ATTN_NORM, speed);
		particle(trace_endpos, trace_plane_normal, 96, 10);
		particle(trace_endpos, trace_plane_normal, 192, 20);
	}

	if (trace_ent.classname == "player")
	{
		Damage(trace_ent, self, self.owner, 3);
	}

	self.nextthink = time + 0.01;
	self.frags--;
#endif
}

void HammerAttack2()
{
	if (self != self.owner.currentWeapon)
	{
		return;
	}

#ifdef SSQC
	SendHammerAttack();
	setorigin(self, self.owner.origin);
	RadiusDamage(self, self.owner, 100, 1000);
#else
	vector effectOrigin;
	float direction = self.owner.moveFlags & MF_REVERSEGRAV ? -1 : 1;
	effectOrigin = self.owner.origin;
	effectOrigin.z += PLAYER_MIN_STAND.z * direction;
	HammerEffects(effectOrigin, direction);
#endif
	if (input_movevalues.z > 0)
	{
		self.owner.velocity.z = -1 * self.velocity.z;
	}
}

#ifdef SSQC
void SendHammerAttack()
{
	entity player = world;
	vector ownerOrigin = self.owner.origin;

	player = find(player, classname, "player");
	ownerOrigin.z += PLAYER_MIN_STAND.z * 
		(self.owner.moveFlags & MF_REVERSEGRAV ? -1 : 1);

	while (player != world)
	{
		if (player != self.owner)
		{
			msg_entity = player;
			WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
			WriteByte(MSG_MULTICAST, CMD_HAMMER);
			WriteCoord(MSG_MULTICAST, ownerOrigin.x);
			WriteCoord(MSG_MULTICAST, ownerOrigin.y);
			WriteCoord(MSG_MULTICAST, ownerOrigin.z);
			WriteLong(MSG_MULTICAST, self.owner.moveFlags & MF_REVERSEGRAV ? -1 : 1);
			multicast('0 0 0', MULTICAST_ONE_R);
		}
		player = find(player, classname, "player");
	}
}
#endif

void HammerEffects(vector position, float direction)
{
	vector forward = '1 0 0';
	vector right = '0 1 0';
	vector down = '0 0 -1' * 1000 * direction;
	vector aim;
	float i, gravityMultiplier = 1;

	traceline(position, position - ('0 0 1000' * direction), 0, world);
	position = trace_endpos;
	position += '0 0 500' * direction;
	for (i = 0; i < 75; i++)
	{
		aim = position + down;
		aim += forward * ((random() * 1000) - 500);
		aim += right * ((random() * 1000) - 500);
		traceline(position, aim, 0, world);
		particle(trace_endpos, trace_plane_normal, 96, 5);
		aim = position + down;
		aim += forward * ((random() * 1000) - 500);
		aim += right * ((random() * 1000) - 500);
		traceline(position, aim, 0, world);
		particle(trace_endpos, trace_plane_normal, 192, 10);
	}

	entity tempEnt = spawn();
	setorigin(tempEnt, position);
	sound(tempEnt, CHAN_AUTO, "weapons/hammer_hit3.ogg", 0.7, ATTN_NORM);
	remove(tempEnt);
}

void HammerKnockback(entity target, entity inflictor, entity attacker, float amount)
{
#ifdef SSQC
	makevectors(attacker.v_angle);
	v_right *= amount * 10;
	target.velocity -= v_right;
#endif
}

float HammerCanEquip(entity hammer)
{
	return TRUE;
}

float HammerCanUnequip(entity hammer)
{
	return TRUE;
}

entity HammerSpawn()
{
	entity hammer = spawn();

	hammer.Equip = HammerEquip;
	hammer.Unequip = HammerUnequip;
	hammer.Fire = HammerFire;
	hammer.CanEquip = HammerCanEquip;
	hammer.CanUnequip = HammerCanUnequip;
	hammer.Knockback = HammerKnockback;
	hammer.classname = "weapon_hammer";
	hammer.weaponType = WEP_HAMMER;
	hammer.owner = self;

	return hammer;
}
