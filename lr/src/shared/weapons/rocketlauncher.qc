#include "rocketlauncher.qh"

void RocketEquip(entity rocketLauncher)
{
    print("Equip RL!\n");
}

void RocketFire(entity rocketLauncher)
{
    if (rocketLauncher.fireTimeout > time)
    {
        return;
    }

    EmitRocket();

    rocketLauncher.fireTimeout = time + ROCKET_FIRE_TIME;
}

float RocketCanEquip(entity rocketLauncher)
{
    return TRUE;
}

float RocketCanSwitch(entity rocketLauncher)
{
    return TRUE;
}

entity RocketSpawn()
{
    entity rocketLauncher = spawn();

    rocketLauncher.Equip = RocketEquip;
    rocketLauncher.Fire = RocketFire;
    rocketLauncher.CanEquip = RocketCanEquip;
    rocketLauncher.CanSwitch = RocketCanSwitch;
    rocketLauncher.classname = "weapon_rocketlauncher";

    return rocketLauncher;
}

void RocketKnockback(entity target, entity inflictor, entity attacker,
    float amount)
{
    vector direction;
    float distance;
    if (target.classname != "player")
    {
        return;
    }
    direction = target.origin - inflictor.origin;
    distance = vlen(direction);
    direction = normalize(direction);
    direction *= (amount * 200) / distance;
    target.velocity += direction;
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

    RadiusKnockback(self, self.owner, 100, 200);

    remove(self);
}
