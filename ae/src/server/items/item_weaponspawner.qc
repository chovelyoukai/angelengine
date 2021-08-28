#include "item_weaponspawner.qh"

void item_weaponspawner()
{
	if (self.weaponType < 0 || self.weaponType >= WEP_LAST)
	{
		remove(self);
		return;
	}
	setmodel(self, viewmodels[self.weaponType]);
	setsize(self, '-16 -16 -16', '16 16 16');
	self.frame = 0;
	self.solid = SOLID_TRIGGER;
	self.enabled = TRUE;
	self.think = item_weaponspawnerThink;
	self.touch = item_weaponspawnerTouch;
}

void item_weaponspawnerTouch()
{
	if (other.classname == "player" && self.enabled)
	{
		if (other.weapons[slot[self.weaponType]] != world)
		{
			return;
		}
		GiveWeapon(other, self.weaponType);
		self.enabled = FALSE;
		self.effects |= EF_ADDITIVE;
		self.nextthink = time + ITEM_WEAPONSPAWNER_RESPAWN;
		sound(self, CHAN_AUTO, "world/pickup_weapon.wav", 1, ATTN_NORM);
	}
}

void item_weaponspawnerThink()
{
	self.enabled = TRUE;
	self.effects &= ~EF_ADDITIVE;
	sound(self, CHAN_AUTO, "world/respawn_weapon.wav", 0.5, ATTN_NORM);
}
