#include "chovel.qh"
#ifdef SSQC
#include "../../server/player.qh"
#endif

void ChovelEquip(entity chovel)
{
	chovel.fireTimeout = time + deployTimes[WEP_CHOVEL];
#ifdef CSQC
	SetViewmodel(viewmodels[WEP_CHOVEL], deployTimes[WEP_CHOVEL]);
	chovel.think = ChovelThink;
	chovel.nextthink = time + cvar("sv_pmovetime");
#endif
}

void ChovelUnequip(entity chovel)
{
	chovel.nextthink = 0;
}

void ChovelFire(entity chovel)
{
	if (chovel.fireTimeout > time)
	{
		return;
	}

	chovel.think = ChovelAttack;
	chovel.nextthink = time + 0.25;
	chovel.fireTimeout = time + fireTimes[WEP_CHOVEL];
#ifdef CSQC
	if (player.moveFlags & MF_CANCRIT)
	{
		ViewmodelAttack(fireTimes[WEP_CHOVEL] + 1, VM_CHOVEL_CRIT_ATTACK);
	}
	else
	{
		ViewmodelAttack(fireTimes[WEP_CHOVEL]);
	}
#endif
}

void ChovelAttack()
{
#ifdef SSQC
	float flags = MOVE_LAGGED;
	vector aim;
	vector mins, maxs;
	entity player, oldSelf;

	player = self.owner;
	if (player.currentWeapon != self)
	{
		return;
	}

	makevectors(player.v_angle);
	aim = player.origin + player.view_ofs + (72 * v_forward);
	mins = '-24 -24 -24';
	maxs = '24 24 24';

	tracebox(player.origin + player.view_ofs, mins, maxs, aim,
             flags, player);

	if (trace_ent.classname == "player" && player.moveFlags & MF_CANCRIT)
	{
		SendKill(player);
		oldSelf = self;
		self = trace_ent;
		PlayerKill(player);
		self = oldSelf;
	}
	else if (trace_fraction < 1)
	{
		sound(self.owner, CHAN_AUTO, "weapons/chovel_hit.wav", 0.7, ATTN_NORM);
		particle(trace_endpos, trace_plane_normal, 0, 5);
	}
	else
	{
		sound(self.owner, CHAN_AUTO, "weapons/chovel_fire.wav", 0.7, ATTN_NORM);
	}
#else
	self.think = ChovelThink;
	self.nextthink = time + 0.75;
#endif
}

void ChovelThink()
{
#ifdef CSQC
	if (player.moveFlags & MF_CANCRIT &&
		viewmodel.frame != VM_CHOVEL_CRIT_IDLE &&
		viewmodel.frame != VM_CHOVEL_CRIT_ATTACK)
	{
		viewmodel.frame = VM_CHOVEL_CRIT_IDLE;
		viewmodel.frame1time = 0;
	}

	if (!(player.moveFlags & MF_CANCRIT))
	{
		viewmodel.fireTimeout = 0;
	}
	else
	{
		viewmodel.fireTimeout = time + 1;
	}
	
	self.nextthink = time + cvar("sv_pmovetime");
#endif
}

float ChovelCanEquip(entity chovel)
{
	return TRUE;
}

float ChovelCanUnequip(entity chovel)
{
	return TRUE;
}

entity ChovelSpawn()
{
	entity chovel = spawn();

	chovel.Equip = ChovelEquip;
	chovel.Unequip = ChovelUnequip;
	chovel.Fire = ChovelFire;
	chovel.CanEquip = ChovelCanEquip;
	chovel.CanUnequip = ChovelCanUnequip;
	chovel.Knockback = GenericKnockback;
	chovel.classname = "weapon_chovel";
	chovel.weaponType = WEP_CHOVEL;
	chovel.owner = self;

	return chovel;
}
