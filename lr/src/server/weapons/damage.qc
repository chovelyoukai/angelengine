#include "damage.qh"

float CanDamage(entity target, entity inflictor)
{
    if (target.movetype == MOVETYPE_PUSH)
    {
        traceline(inflictor.origin, 0.5 * (target.absmin +
            target.absmax), TRUE, inflictor);
        if (trace_fraction == 1 || trace_ent == target)
        {
            return TRUE;
        }
        else
        {
            return FALSE;
        }
    }

	traceline(inflictor.origin, target.origin, TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;
	
	traceline(inflictor.origin, target.origin + '15 15 0',
		TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, target.origin + '-15 -15 0',
		TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, target.origin + '-15 15 0',
		TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, target.origin + '15 -15 0',
		TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
}

void RadiusDamage(entity inflictor, entity attacker, float amount,
    float radius)
{
    entity target;
    float realAmount;

    target = findradius(inflictor.origin, radius);

    while(target != world)
    {
        realAmount = vlen(target.origin - inflictor.origin);

        realAmount = amount * (1 - (realAmount / radius));

        if (realAmount > 0)
        {
            Damage(target, inflictor, attacker, realAmount);
        }

        target = target.chain;
    }
}

void RadiusKnockback(entity inflictor, entity attacker, float amount,
    float radius)
{
    entity target;

    target = findradius(inflictor.origin, radius);

    while(target != world)
    {
        inflictor.Knockback(target, inflictor, attacker, amount);
        target = target.chain;
    }
}

void Damage(entity target, entity inflictor, entity attacker, float amount)
{
    entity oldSelf;

    target.health -= amount;

    if (target.classname == "player" && target.health <= 0)
    {
        target.health = 0;
        oldSelf = self;
        self = target;
        ClientKill();
        self = oldSelf;
    }

    inflictor.Knockback(target, inflictor, attacker, amount);
}

void GenericKnockback(entity target, entity inflictor, entity attacker,
    float amount)
{
    vector direction;
    direction = target.origin - inflictor.owner.origin;
    direction = normalize(direction);
    direction *= amount * 10;
    target.velocity += direction;

    target.SendFlags |= FL_VELOCITY;
    target.SendEntity = PlayerUpdate;
}
