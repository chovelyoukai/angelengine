#include "rocketlauncher.qh"

void ChovelEquip(entity chovel)
{
    self.weaponType = WEP_CHOVEL;
    chovel.fireTimeout = time + fireTimes[WEP_CHOVEL];
}

void ChovelFire(entity chovel)
{
    float flags = MOVE_LAGGED;
    vector aim;
    vector mins, maxs;
    entity oldSelf;

    if (chovel.fireTimeout > time)
    {
        return;
    }

    makevectors(self.v_angle);
    aim = self.origin + self.view_ofs + (64 * v_forward);
    mins = '-18 -18 -18';
    maxs = '18 18 18';

    tracebox(self.origin + self.view_ofs, mins, maxs, aim, flags, self); 

    if (trace_ent.classname == "player")
    {
        oldSelf = self;
        self = trace_ent;
        ClientKill();
        self = oldSelf;
    }
    else if (trace_fraction < 1)
    {
        particle(trace_endpos, trace_plane_normal, 0, 5);
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
