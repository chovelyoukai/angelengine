#include "hammer.qh"

void HammerEquip(entity hammer)
{
    self.weaponType = WEP_HAMMER;
    hammer.fireTimeout = time + deployTimes[WEP_HAMMER];
#ifdef CSQC
    SetViewmodel(viewmodels[WEP_HAMMER]);
#endif
}

void HammerUnequip(entity shotgun)
{
}

void HammerFire(entity hammer)
{
    if (hammer.fireTimeout > time)
    {
        return;
    }

    hammer.think = HammerAttack;
    hammer.nextthink = time + 0.55;
    hammer.fireTimeout = time + fireTimes[WEP_HAMMER];
#ifdef CSQC
    ViewmodelAttack(fireTimes[WEP_HAMMER]);
#endif
}

void HammerAttack()
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
        sound(self.owner, CHAN_AUTO, "weapons/hammer_hit.ogg", 0.7, ATTN_NORM);
        particle(trace_endpos, trace_plane_normal, 0, 5);
    }
    else
    {
        sound(self.owner, CHAN_AUTO, "weapons/hammer_fire.wav", 0.7, ATTN_NORM);
    }
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
    hammer.Knockback = GenericKnockback;
    hammer.classname = "weapon_hammer";
    hammer.owner = self;

    return hammer;
}
