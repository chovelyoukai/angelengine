#include "world.qh"

void PrecacheModels()
{
	precache_model("models/player.iqm");
    precache_model("models/objects/health.iqm");
	precache_model("models/weapons/rocket.iqm");
    precache_sound("world/pickup_health.wav");
    precache_sound("world/pickup_weapon.wav");
    precache_sound("world/respawn_health.wav");
    precache_sound("world/respawn_weapon.wav");
    precache_sound("weapons/chovel_fire.wav");
    precache_sound("weapons/chovel_hit.wav");
    precache_sound("weapons/rocket_fire.ogg");
    precache_sound("weapons/shotgun_fire.ogg");
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


