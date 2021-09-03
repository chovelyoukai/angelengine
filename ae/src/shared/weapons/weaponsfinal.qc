#include "weapondefs.qh"
#include "../player.qh"

// This file exists because FTEQCC doesn't support relocation, so an array
// of functions must be defined after functions are defined, not simply
// prototyped. All the functions in this file also depend on this array.

var entity() weaponSpawns[WEP_LAST] = 
{
	RocketlauncherSpawn,
	ShotgunSpawn,
	ChovelSpawn,
	HammerSpawn
}

void GiveWeapon(entity playerEnt, float weaponType)
{
	entity weapon, oldSelf;

	if (playerEnt.weapons[slot[weaponType]] != world)
	{
		return;
	}
	if (weaponType <= WEP_NONE || weaponType >= WEP_LAST)
	{
		return;
	}
	weapon = weaponSpawns[weaponType]();
	weapon.owner = playerEnt;
	playerEnt.weapons[slot[weaponType]] = weapon;
	if (playerEnt.weaponsHeld == 0)
	{
		playerEnt.currentWeapon = weapon;
		oldSelf = self;
		self = playerEnt;
		self.currentWeapon.Equip(self.currentWeapon);
		self = oldSelf;
	}
	playerEnt.weaponsHeld++;

#ifdef SSQC
	SendWeaponSpawn(weaponType, playerEnt);
#endif
}

void RemoveWeapon(entity playerEnt, float currentSlot)
{
	float wepType;
	float shouldSwitch = FALSE;

	if (currentSlot < 0 || currentSlot >= MAX_WEAPONS)
	{
		return;
	}
	if (playerEnt.weapons[currentSlot] == world)
	{
		return;
	}
	if (!playerEnt.weapons[currentSlot].CanUnequip(self.weapons[currentSlot]))
	{
		return;
	}

	wepType = (playerEnt.weapons[currentSlot]).weaponType;

	if (playerEnt.currentWeapon == playerEnt.weapons[currentSlot])
	{
		playerEnt.weapons[currentSlot].Unequip(playerEnt.weapons[currentSlot]);
		shouldSwitch = TRUE;
	}
	remove(playerEnt.weapons[currentSlot]);
	playerEnt.weaponsHeld--;
	playerEnt.weapons[currentSlot] = world;
	if (shouldSwitch == TRUE)
	{
		playerEnt.currentWeapon = world;
		NextWeapon(playerEnt, currentSlot);
	}

#ifdef SSQC
	SendWeaponRemove(wepType, playerEnt);
#else
	if (playerEnt.currentWeapon == world)
	{
		SetViewmodel("");
	}
#endif
}
