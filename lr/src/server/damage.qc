#include "damage.qh"

void RadiusDamage(entity inflictor, entity attacker, float amount, float radius)
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

	ApplyKnockback(target, inflictor.origin, amount);
}

void ApplyKnockback(entity target, vector source, float amount)
{
	vector direction;
	direction = source - target.origin;
	direction = normalize(direction);
	direction *= amount;
	target.velocity += direction;
}
