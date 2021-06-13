#include "rocketlauncher.qh"

void ChovelEquip(entity chovel)
{
    self.weaponType = WEP_CHOVEL;
    chovel.fireTimeout = time + deployTimes[WEP_CHOVEL];
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
}

void ChovelAttack()
{
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
    aim = player.origin + player.view_ofs + (48 * v_forward);
    mins = '-18 -18 -18';
    maxs = '18 18 18';

    tracebox(player.origin + player.view_ofs, mins, maxs, aim,
        flags, player);

    if (trace_ent.classname == "player" && player.moveFlags & MF_CANCRIT)
    {
        oldSelf = self;
        self = trace_ent;
        ClientKill();
        self = oldSelf;
    }
    else if (trace_fraction < 1)
    {
        sound(self.owner, CHAN_AUTO, "weapons/chovel_hit.wav", 1, ATTN_NORM);
        particle(trace_endpos, trace_plane_normal, 0, 5);
    }
    else
    {
        sound(self.owner, CHAN_AUTO, "weapons/chovel_fire.wav", 1, ATTN_NORM);
    }
}

float ChovelCanEquip(entity chovel)
{
    return TRUE;
}

float ChovelCanSwitch(entity chovel)
{
    return TRUE;
}

entity ChovelSpawn()
{
    entity chovel = spawn();

    chovel.Equip = ChovelEquip;
    chovel.Fire = ChovelFire;
    chovel.CanEquip = ChovelCanEquip;
    chovel.CanSwitch = ChovelCanSwitch;
    chovel.Knockback = GenericKnockback;
    chovel.classname = "weapon_chovel";
    chovel.owner = self;

    return chovel;
}
