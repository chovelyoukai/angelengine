#include "world.qh"

void PrecacheModels()
{
	precache_model("models/player.iqm");
	precache_model("models/weapon_world/w_rocket.iqm");
    precache_sound("weapons/shotgun.ogg");
}

void Stats()
{
    clientstat(STAT_WEAPON, EV_FLOAT, weaponType);
}

void main()
{
}

void worldspawn()
{
	PrecacheModels();

    Stats();
}

void StartFrame()
{
}


