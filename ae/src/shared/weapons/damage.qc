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
    target.health -= amount;

#ifdef SSQC
    entity oldSelf;
    if (target.classname == "player" && target.health <= 0)
    {
        SendKill(attacker);
        target.health = 0;
        oldSelf = self;
        self = target;
        PlayerKill(attacker);
        self = oldSelf;
    }
    else
    {
        SendHit(attacker, amount);
    }

    SendDamage(target, amount, attacker.origin, FALSE);
#endif
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
}

#ifdef SSQC
void SendHit(entity target, float damage)
{
    msg_entity = target;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, CMD_HIT);
    WriteLong(MSG_MULTICAST, damage);
    multicast('0 0 0', MULTICAST_ONE_R);
}

void SendKill(entity target)
{
    msg_entity = target;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, CMD_KILL);
    multicast('0 0 0', MULTICAST_ONE_R);
}

void SendDamage(entity target, float amount, vector spot, float knockback)
{
    msg_entity = target;
    spot = target.origin - spot;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    if (knockback)
    {
        WriteByte(MSG_MULTICAST, CMD_DAMAGE_KNOCKBACK);
    }
    else
    {
        WriteByte(MSG_MULTICAST, CMD_DAMAGE_HURT);
    }
    WriteCoord(MSG_MULTICAST, spot.x);
    WriteCoord(MSG_MULTICAST, spot.y);
    WriteCoord(MSG_MULTICAST, spot.z);
    WriteFloat(MSG_MULTICAST, amount);
    multicast('0 0 0', MULTICAST_ONE_R);
}
#endif
