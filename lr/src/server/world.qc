#include "world.qh"

void PrecacheModels()
{
	precache_model("models/player.iqm");
	precache_model("models/weapon_world/w_rocket.iqm");
    precache_sound("weapons/shotgun.ogg");
    precache_sound("weapons/fire_rocket.ogg");
    precache_sound("weapons/r_exp3.wav");
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


