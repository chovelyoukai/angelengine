#include "rocketlauncher.qh"

void ShotgunEquip(entity shotgun)
{
    self.weaponType = WEP_SHOTGUN;
    shotgun.fireTimeout = time + deployTimes[WEP_SHOTGUN];
}

void ShotgunFire(entity shotgun)
{
    float i, j, flags = MOVE_LAGGED;
    float speed;
    float damage;
    vector aim;

    if (shotgun.fireTimeout > time)
    {
        return;
    }

    makevectors(self.v_angle);
    damage = vlen(self.velocity) / 120;
    damage = clamp(1, damage, 15);

    for (i = -1; i <= 1; i++)
    {
        for (j = -1; j <= 1; j++)
        {
            aim = self.origin + self.view_ofs + v_forward * 10000;
            aim += (v_right * i * 600) + (v_up * j * 300);
            traceline(self.origin + self.view_ofs, aim, flags, self);
            
            if (trace_fraction < 1 && trace_ent.classname == "player")
            {
                particle(trace_endpos, trace_plane_normal, 64, damage * 3);
                Damage(trace_ent, shotgun, self, damage);
            }
            else if (trace_fraction < 1)
            {
                particle(trace_endpos, trace_plane_normal, 0, damage);
            }
        }
    }

    speed = 100 + (10 * random()) - 5;
    sound(self, CHAN_AUTO, "weapons/shotgun.ogg", 1, ATTN_NORM, speed);

    shotgun.fireTimeout = time + fireTimes[WEP_SHOTGUN];
}

float ShotgunCanEquip(entity shotgun)
{
    return TRUE;
}

float ShotgunCanSwitch(entity shotgun)
{
    return TRUE;
}

entity ShotgunSpawn()
{
    entity shotgun = spawn();

    shotgun.Equip = ShotgunEquip;
    shotgun.Fire = ShotgunFire;
    shotgun.CanEquip = ShotgunCanEquip;
    shotgun.CanSwitch = ShotgunCanSwitch;
    shotgun.Knockback = GenericKnockback;
    shotgun.classname = "weapon_shotgun";
    shotgun.owner = self;

    return shotgun;
}
