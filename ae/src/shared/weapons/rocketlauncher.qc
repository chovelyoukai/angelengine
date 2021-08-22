#include "rocketlauncher.qh"
#pragma target fte

void RocketlauncherEquip(entity rocketLauncher)
{
    self.weaponType = WEP_ROCKETLAUNCHER;
    rocketLauncher.fireTimeout = time + deployTimes[WEP_ROCKETLAUNCHER];

    self.moveFlags |= MF_BURDENED;

#ifdef CSQC
    SetViewmodel(viewmodels[WEP_ROCKETLAUNCHER]);
#endif
}

void RocketlauncherUnequip(entity rocketLauncher)
{
    self.moveFlags &= ~MF_BURDENED;
}

void RocketlauncherFire(entity rocketLauncher)
{
    if (rocketLauncher.fireTimeout > time)
    {
        return;
    }

#ifdef SSQC
    float speed = 100 + (10 * random()) - 5;
    sound(self, CHAN_AUTO, "weapons/rocket_fire.ogg", 0.3, 0.5, speed);
#else
    ViewmodelAttack(fireTimes[WEP_ROCKETLAUNCHER]);
#endif

    EmitRocket();

    rocketLauncher.fireTimeout = time + fireTimes[WEP_ROCKETLAUNCHER];
}

float RocketlauncherCanEquip(entity rocketLauncher)
{
    return TRUE;
}

float RocketlauncherCanUnequip(entity rocketLauncher)
{
    return TRUE;
}

entity RocketlauncherSpawn()
{
    entity rocketLauncher = spawn();

    rocketLauncher.Equip = RocketlauncherEquip;
    rocketLauncher.Unequip = RocketlauncherUnequip;
    rocketLauncher.Fire = RocketlauncherFire;
    rocketLauncher.CanEquip = RocketlauncherCanEquip;
    rocketLauncher.CanUnequip = RocketlauncherCanUnequip;
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

    while (target != world)
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
        else if (target == self.owner)
        {
            amount *= 0.5;
        }

#ifdef SSQC
        if (target.classname == "player" && target != self.owner)
        {
            SendHit(self.owner, amount);
        }
#endif
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

    if (IsOnGround(target) && target.landingTime > time &&
        !(target.moveFlags & MF_RAMPSLIDE))
    {
        target.velocity.x = target.landingVelocity.x;
        target.velocity.y = target.landingVelocity.y;
        direction.z = 2;
    }

    target.velocity += (direction * amount * multiplier);
    setorigin(target, target.origin + '0 0 1');
#ifdef SSQC
    target.moveFlags |= MF_CANCRIT;
    SendDamage(target, amount, inflictor.origin, TRUE);
#endif
}

void EmitRocket()
{
    vector start, muzzle;
    entity rocket;
    float traceFlags = MOVE_NORMAL;

#ifdef SSQC
    makevectors(self.v_angle);
    start = self.origin + self.view_ofs;
#else
    makevectors(view_angles);
    start = self.origin + PLAYER_VIEW_STAND;
#endif
    muzzle = start + (v_forward * 19) + (v_up * -3);

    traceline(start, muzzle, traceFlags, self);

    rocket = spawn();
    rocket.classname = "rocket";
    rocket.projectileType = PROJ_ROCKET;
    rocket.Knockback = RocketKnockback;
    rocket.owner = self;
    rocket.movetype = MOVETYPE_FLYMISSILE;
    rocket.solid = SOLID_BBOX;
    rocket.velocity = v_forward * ROCKET_VELOCITY;
    rocket.angles = vectoangles(rocket.velocity);
#ifdef SSQC
    rocket.SendEntity = PredictedProjectileUpdate;
    rocket.SendFlags |= FL_ORIGIN | FL_VELOCITY;
#endif

    setmodel(rocket, "models/weapons/rocket.iqm");
    setsize(rocket, '0 0 0', '0 0 0');
    setorigin(rocket, trace_endpos);

    rocket.effects |= EF_DIMLIGHT;
    rocket.touch = RocketTouch;

#ifdef CSQC
    rocket.drawmask = MASK_ENGINE;
#endif
}

void RocketTouch()
{
    vector direction = normalize(self.velocity);

    traceline(self.origin, self.origin + direction, 0, self);

    if (trace_ent == world && trace_fraction < 1)
    {
        if (trace_surfaceflagsi & 0x10)
        {
            remove(self);
            return;
        }
    }

    setorigin(self, self.origin - (v_forward * 1));
    setmodel(self, "");
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;

    RocketRadiusKnockback(self);

    setorigin(self, self.origin - (v_forward * 16));

#ifdef SSQC
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin.x);
    WriteCoord(MSG_MULTICAST, self.origin.y);
    WriteCoord(MSG_MULTICAST, self.origin.z);
    multicast(self.origin, MULTICAST_ALL);
#endif

    remove(self);
}
