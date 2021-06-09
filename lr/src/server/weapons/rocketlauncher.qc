#include "rocketlauncher.qh"

void RocketlauncherEquip(entity rocketLauncher)
{
    print("Equip RL!\n");
}

void RocketlauncherFire(entity rocketLauncher)
{
    if (rocketLauncher.fireTimeout > time)
    {
        return;
    }

    EmitRocket();

    rocketLauncher.fireTimeout = time + ROCKET_FIRE_TIME;
}

float RocketlauncherCanEquip(entity rocketLauncher)
{
    return TRUE;
}

float RocketlauncherCanSwitch(entity rocketLauncher)
{
    return TRUE;
}

entity RocketlauncherSpawn()
{
    entity rocketLauncher = spawn();

    rocketLauncher.Equip = RocketlauncherEquip;
    rocketLauncher.Fire = RocketlauncherFire;
    rocketLauncher.CanEquip = RocketlauncherCanEquip;
    rocketLauncher.CanSwitch = RocketlauncherCanSwitch;
    rocketLauncher.classname = "weapon_rocketlauncher";
    rocketLauncher.owner = self;

    return rocketLauncher;
}

void RocketRadiusKnockback(entity ignore)
{
    float distance;
    float amount;
    entity target;
    vector center, bottom, closest;

    target = findradius(self.origin, ROCKET_RADIUS);

    while (target)
    {
        if (target == ignore)
        {
            target = target.chain;
            continue;
        }

        if (!CanDamage(target, self))
        {
            target = target.chain;
            continue;
        }

        amount = ROCKET_DAMAGE;

        center = target.origin;
        bottom = target.origin;
        bottom.z -= 40;

        if (vlen(bottom - self.origin) < vlen(center - self.origin))
        {
            closest = bottom;
        }
        else
        {
            closest = center;
        }

        distance = vlen(closest - self.origin);

        amount = (amount * (0.5 - 1) * distance / 121) + amount;

        if (target == self.owner && !IsOnGround(target))
        {
            amount *= 0.6;
        }
        else
        {
            amount *= 0.5;
        }

        RocketKnockback(target, self, self.owner, amount);

        target = target.chain;
    }
}

void RocketKnockback(entity target, entity inflictor, entity attacker,
    float amount)
{
    vector direction;
    float distance;
    float multiplier;

    if (target.classname != "player")
    {
        return;
    }

    direction = target.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
    distance = vlen(direction);
    direction = normalize(direction);
    
    if (target == attacker && !IsOnGround(target))
    {
        multiplier = 15.2;
    }
    else
    {
        multiplier = 7.455;
    }

    target.velocity += (direction * amount * multiplier);
}

void EmitRocket()
{
    vector start, muzzle;
    entity rocket;
    float traceFlags = MOVE_HITMODEL | MOVE_LAGGED;

    makevectors(self.v_angle);
    start = self.origin + self.view_ofs;
    muzzle = start + v_forward * 15;

    traceline(start, muzzle, traceFlags, self);

    rocket = spawn();
    rocket.classname = "rocket";
    rocket.Knockback = RocketKnockback;
    rocket.owner = self;
    rocket.movetype = MOVETYPE_FLYMISSILE;
    rocket.solid = SOLID_BBOX;
    rocket.velocity = v_forward * ROCKET_VELOCITY;
    rocket.angles = vectoangles(rocket.velocity);

    setmodel(rocket, "models/weapon_world/w_rocket.iqm");
    setsize(rocket, '0 0 0', '0 0 0');
    setorigin(rocket, trace_endpos);

    rocket.effects |= EF_DIMLIGHT;
    rocket.touch = RocketTouch;
}

void RocketTouch()
{
    vector direction = normalize(self.velocity);

    setorigin(self, self.origin - (v_forward * 1));
    setmodel(self, "");
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;

    RocketRadiusKnockback(other);

    remove(self);
}
