#include "damager.qh"

void SpawnDamager(entity target, float amount, vector spot, float knockback)
{
	entity damager = spawn();
	damager.owner = target;
	damager.think = RemoveSelf;
	damager.nextthink = time + 1;
	damager.SendEntity = SendDamager;
	damager.SendFlags |= FL_DAMAGESPAWN;
    if (knockback)
    {
        damager.SendFlags |= FL_KNOCKBACK;
    }
	damager.health = amount;
	setorigin(damager, spot);
}

float SendDamager(entity to, float sendFlags)
{
	float id = ENT_DAMAGER;
    vector offset;

	if (to != self.owner)
		return FALSE;

	WriteByte(MSG_ENTITY, id);
	WriteByte(MSG_ENTITY, self.SendFlags);
	if (self.SendFlags & FL_DAMAGESPAWN)
	{
        offset = self.owner.origin - self.origin;
		WriteCoord(MSG_ENTITY, offset.x);
		WriteCoord(MSG_ENTITY, offset.y);
		WriteCoord(MSG_ENTITY, offset.z);
		WriteFloat(MSG_ENTITY, self.health);
	}

	return TRUE;
}
