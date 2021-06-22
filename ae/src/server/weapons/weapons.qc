#include "weapons.qh"
#include "damage.qh"

void Explode1() = [0, Explode2] {};
void Explode2() = [1, Explode3] {};
void Explode3() = [2, Explode4] {};
void Explode4() = [3, Explode5] {};
void Explode5() = [4, Explode6] {};
void Explode6() = [5, RemoveSelf] {}; 

float CheckWeapons()
{
	if (self.button0)
	{
		if (self.currentWeapon != world)
		{
			self.currentWeapon.Fire(self.currentWeapon);
		}

		return TRUE;
	}

	return FALSE;
}

void SwitchWeapons(float impulse)
{
	impulse--;

	if (self.weapons[impulse] != world &&
		self.currentWeapon != self.weapons[impulse])
	{
		// our current weapon must agree that it can be switched off of,
		// and our desired weapon must agree that it can be equipped.
		// this allows all kinds of weapon-specific behaviours.
		if (self.currentWeapon.CanSwitch(self.currentWeapon) &&
			self.weapons[impulse].CanEquip(self.weapons[impulse]))
		{
			self.currentWeapon = self.weapons[impulse];
			self.currentWeapon.Equip(self.currentWeapon);
		}
	}
}

void BecomeExplosion()
{
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;
    self.velocity = '0 0 0';
    self.touch = DoNothing;
    setmodel(self, "");
    Explode1();
}
