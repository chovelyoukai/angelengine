#include "shotgun.qh"

void ShotgunEquip(entity shotgun)
{
    shotgun.fireTimeout = time + deployTimes[WEP_SHOTGUN];
#ifdef CSQC
    SetViewmodel(viewmodels[WEP_SHOTGUN], deployTimes[WEP_SHOTGUN]);
#endif
}

void ShotgunUnequip(entity shotgun)
{
}

void ShotgunFire(entity shotgun)
{
    if (shotgun.fireTimeout > time)
    {
        return;
    }
#ifdef SSQC
    float i, j, k, flags = MOVE_LAGGED;
    float speed;
    float damage;
    float accumulatedDamage[9];
    entity hitEntities[9];
    float hitCount = 0;

    vector aim;

    makevectors(self.v_angle);
    damage = vlen(self.velocity) / 120;
    damage = clamp(1, damage, 15);

    for (i = 0; i < 9; i++)
    {
        accumulatedDamage[i] = 0;
        hitEntities[i] = world;
    }

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

                for (k = 0; k < hitCount; k++)
                {
                    if (hitEntities[k] == trace_ent)
                    {
                        break;
                    }
                }
                if (k == hitCount)
                {
                    hitEntities[k] = trace_ent;
                    hitCount++;
                }
                accumulatedDamage[k] += damage;

            }
            else if (trace_fraction < 1)
            {
                particle(trace_endpos, trace_plane_normal, 0, damage);
            }
        }
    }

    for (k = 0; k < hitCount; k++)
    {
        Damage(hitEntities[k], shotgun, self, accumulatedDamage[k]);
    }

    speed = 110 - (damage * 2);
    sound(self, CHAN_AUTO, "weapons/shotgun_fire.ogg", 0.5, ATTN_NORM, speed);
#else
    ViewmodelAttack(fireTimes[WEP_SHOTGUN]);
#endif

    shotgun.fireTimeout = time + fireTimes[WEP_SHOTGUN];
}

float ShotgunCanEquip(entity shotgun)
{
    return TRUE;
}

float ShotgunCanUnequip(entity shotgun)
{
    return TRUE;
}

entity ShotgunSpawn()
{
    entity shotgun = spawn();

    shotgun.Equip = ShotgunEquip;
    shotgun.Unequip = ShotgunUnequip;
    shotgun.Fire = ShotgunFire;
    shotgun.CanEquip = ShotgunCanEquip;
    shotgun.CanUnequip = ShotgunCanUnequip;
    shotgun.Knockback = GenericKnockback;
    shotgun.classname = "weapon_shotgun";
    shotgun.weaponType = WEP_SHOTGUN;
    shotgun.owner = self;

    return shotgun;
}
