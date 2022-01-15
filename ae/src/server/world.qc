#include "world.qh"

void PrecacheModels()
{
	precache_model("models/player.iqm");
	precache_model("models/objects/board.iqm");
	precache_model("models/objects/health.iqm");
	precache_model("models/objects/speed.iqm");
	precache_model("models/weapons/chovel.iqm");
	precache_model("models/weapons/grenade.iqm");
	precache_model("models/weapons/grenadelauncher.iqm");
	precache_model("models/weapons/grapple.iqm");
	precache_model("models/weapons/hammer.iqm");
	precache_model("models/weapons/hook.iqm");
	precache_model("models/weapons/rocket.iqm");
	precache_model("models/weapons/rocketlauncher.iqm");
	precache_model("models/weapons/shotgun.iqm");
	precache_sound("null.wav");
	precache_sound("player/grind.ogg");
	precache_sound("player/land.wav");
	precache_sound("player/step.wav");
	precache_sound("player/superjump.wav");
	precache_sound("player/wallattach.wav");
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
	precache_sound("weapons/grenade_fire.ogg");
	precache_sound("weapons/hook_fire.ogg");
	precache_sound("weapons/rocket_fire.ogg");
	precache_sound("weapons/shotgun_fire.ogg");
	precache_sound("weapons/r_exp3.wav");

	precache_sound("music/countdown.wav");
	precache_sound("music/ends/end1.wav");
	precache_sound("music/ends/end2.wav");
	precache_sound("music/ends/end3.wav");
	precache_sound("music/ends/end4.wav");
	precache_sound("music/ends/end5.wav");
	precache_sound("music/ends/end6.wav");
	precache_sound("music/ends/end7.wav");
	precache_sound("music/ends/end8.wav");
	precache_sound("music/ends/end9.wav");
	precache_sound("music/ends/end10.wav");
	precache_sound("music/starts/start1.wav");
	precache_sound("music/starts/start2.wav");
	precache_sound("music/starts/start3.wav");
	precache_sound("music/starts/start4.wav");
	precache_sound("music/starts/start5.wav");
	precache_sound("music/starts/start6.wav");
	precache_sound("music/starts/start7.wav");
	precache_sound("music/starts/start8.wav");
	precache_sound("music/starts/start9.wav");
	precache_sound("music/starts/start10.wav");
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

	gameMode = GM_FFADM;
	winPoints = 20;
	gameInfo = world;

	Stats();
}

void StartFrame()
{
}


