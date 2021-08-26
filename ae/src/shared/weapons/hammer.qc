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

    traceline(self.origin, self.origin - '0 0 1000', 0, self);
    float dist = 1000 * trace_fraction;
    float accel = cvar("sv_gravity");
    float vel = self.velocity.z * -1;

    // how long will it take us to reach the ground?
    float t = (-1 * dist) + sqrt((dist * dist) + (2 * accel * dist));
    t /= (2 * accel);

    if (trace_fraction < 1 && self.velocity.z < -1000 && t > 0.3 && t < 0.4)
    {
        hammer.think = HammerAttack2;
        hammer.nextthink = time + 0.4;
        hammer.fireTimeout = time + fireTimes[WEP_HAMMER];
#ifdef CSQC
        ViewmodelAttack(fireTimes[WEP_HAMMER], 3);
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
#ifdef SSQC
    vector forward = '1 0 0';
    vector right = '0 1 0';
    vector down = '0 0 -1' * 1000;
    vector ownerOrigin, aim;
    float i;

    ownerOrigin = self.owner.origin;

    traceline(ownerOrigin, ownerOrigin - '0 0 1000', 0, self.owner);
    ownerOrigin = trace_endpos;
    ownerOrigin += '0 0 500';
    for (i = 0; i < 300; i++)
    {
        aim = ownerOrigin + down;
        aim += forward * ((random() * 1000) - 500);
        aim += right * ((random() * 1000) - 500);
        traceline(ownerOrigin, aim, 0, self.owner);
        particle(trace_endpos, trace_plane_normal, 96, 10);
        particle(trace_endpos, trace_plane_normal, 192, 20);
    }
    sound(self.owner, CHAN_AUTO, "weapons/hammer_hit3.ogg", 0.7, ATTN_NORM);

    setorigin(self, self.owner.origin);
    RadiusDamage(self, self.owner, 100, 1000);
#endif
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
    hammer.owner = self;

    return hammer;
}
