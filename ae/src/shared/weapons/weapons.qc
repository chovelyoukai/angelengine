#include "weapons.qh"
#ifdef CSQC
#include "../../client/hud.qh"
#endif

void Explode1() = [0, Explode2] {};
void Explode2() = [1, Explode3] {};
void Explode3() = [2, Explode4] {};
void Explode4() = [3, Explode5] {};
void Explode5() = [4, Explode6] {};
void Explode6() = [5, RemoveSelf] {}; 

float CheckWeapons()
{
#ifdef SSQC
	if (self.button0)
#else
    if (input_buttons & BUTTON_ATTACK)
#endif
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
        if (self.currentWeapon == world)
        {
			self.currentWeapon = self.weapons[impulse];
			self.currentWeapon.Equip(self.currentWeapon);
        }
		else if (self.currentWeapon.CanUnequip(self.currentWeapon) &&
			self.weapons[impulse].CanEquip(self.weapons[impulse]))
		{
            self.currentWeapon.Unequip(self.currentWeapon);
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

void NextWeapon(entity playerEnt, float currentSlot)
{
    float newSlot;
    entity oldSelf;

    newSlot = (currentSlot + 1) % MAX_WEAPONS;

    while (newSlot != currentSlot)
    {
        if (playerEnt.weapons[newSlot] != world)
        {
            if (playerEnt.weapons[newSlot].CanEquip(playerEnt.weapons[newSlot]))
            {
                break;
            }
        }

        newSlot = (newSlot + 1) % MAX_WEAPONS;
    }

    if (newSlot == currentSlot)
    {
        return;
    }

    playerEnt.currentWeapon = playerEnt.weapons[newSlot];
    oldSelf = self;
    self = playerEnt;
    self.currentWeapon.Equip(self.currentWeapon);
    self = oldSelf;
}

void PreviousWeapon(entity playerEnt, float currentSlot)
{
    float newSlot;
    entity oldSelf;

    newSlot = (currentSlot - 1) % MAX_WEAPONS;

    while (newSlot != currentSlot)
    {
        if (playerEnt.weapons[newSlot] != world)
        {
            if (playerEnt.weapons[newSlot].CanEquip(playerEnt.weapons[newSlot]))
            {
                break;
            }
        }

        newSlot = (newSlot - 1) % MAX_WEAPONS;
    }

    if (newSlot == currentSlot)
    {
        return;
    }

    playerEnt.currentWeapon = playerEnt.weapons[newSlot];
    oldSelf = self;
    self = playerEnt;
    self.currentWeapon.Equip(self.currentWeapon);
    self = oldSelf;
}

#ifdef SSQC
void SendWeaponSpawn(float weaponType, entity target)
{
    msg_entity = target;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, CMD_WEAPON_SPAWN);
    WriteFloat(MSG_MULTICAST, weaponType);
    multicast('0 0 0', MULTICAST_ONE_R);
}

void SendWeaponRemove(float weaponType, entity target)
{
    msg_entity = target;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, CMD_WEAPON_REMOVE);
    WriteFloat(MSG_MULTICAST, weaponType);
    multicast('0 0 0', MULTICAST_ONE_R);
}

float PredictedProjectileUpdate(entity to, float entFlags)
{
    if (to == self.owner)
    {
        return FALSE;
    }
    
    WriteByte(MSG_ENTITY, ENT_PROJECTILE);
    WriteLong(MSG_ENTITY, entFlags);
    WriteByte(MSG_ENTITY, self.projectileType);

    if (entFlags & FL_ORIGIN)
    {
        WriteCoord(MSG_ENTITY, self.origin.x);
        WriteCoord(MSG_ENTITY, self.origin.y);
        WriteCoord(MSG_ENTITY, self.origin.z);
    }
    if (entFlags & FL_VELOCITY)
    {
        WriteCoord(MSG_ENTITY, self.velocity.x);
        WriteCoord(MSG_ENTITY, self.velocity.y);
        WriteCoord(MSG_ENTITY, self.velocity.z);
    }

    return TRUE;
}
#endif

#ifdef CSQC
void InitializeViewmodel()
{
    viewmodel = spawn();
    viewmodel.drawmask |= MASK_VIEWMODEL | MASK_ENGINE;
    viewmodel.renderflags |= RF_VIEWMODEL;
    viewmodel.solid = SOLID_NOT;
}

void UpdateViewmodel()
{
    if (viewmodel.fireTimeout <= time)
    {
        viewmodel.frame = 0;
        viewmodel.frame1time = 0;
    }

    viewmodel.frame1time += frametime;
}

void SetViewmodel(string modelName)
{
    setmodel(viewmodel, modelName);
    viewmodel.frame1time = 0;
    viewmodel.frame2time = time;
    viewmodel.frame = 0;
    viewmodel.lerpfrac = 0.5;
}

void ViewmodelAttack(float timeout, float weaponFrame = 1)
{
    viewmodel.frame = weaponFrame;
    viewmodel.frame1time = 0;
    viewmodel.fireTimeout = time + timeout;
}
#endif
