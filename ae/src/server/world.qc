#include "world.qh"

void PrecacheModels()
{
	precache_model("models/player.iqm");
    precache_model("models/objects/health.iqm");
    precache_model("models/objects/speed.iqm");
    precache_model("models/weapons/chovel.iqm");
    precache_model("models/weapons/hammer.iqm");
	precache_model("models/weapons/rocket.iqm");
	precache_model("models/weapons/rocketlauncher.iqm");
    precache_model("models/weapons/shotgun.iqm");
    precache_sound("null.wav");
    precache_sound("player/grind.ogg");
    precache_sound("player/step.wav");
    precache_sound("world/pickup_health.wav");
    precache_sound("world/pickup_speed.wav");
    precache_sound("world/pickup_weapon.wav");
    precache_sound("world/respawn_health.wav");
    precache_sound("world/respawn_speed.wav");
    precache_sound("world/respawn_weapon.wav");
    precache_sound("weapons/chovel_fire.wav");
    precache_sound("weapons/chovel_hit.wav");
    precache_sound("weapons/hammer_fire.wav");
    precache_sound("weapons/hammer_hit.ogg");
    precache_sound("weapons/hammer_hit2.ogg");
    precache_sound("weapons/hammer_hit3.ogg");
    precache_sound("weapons/rocket_fire.ogg");
    precache_sound("weapons/shotgun_fire.ogg");
    precache_sound("weapons/r_exp3.wav");
}

void Stats()
{
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


