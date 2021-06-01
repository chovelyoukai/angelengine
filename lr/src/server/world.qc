#include "world.qh"

void PrecacheModels()
{
	precache_model("models/player.iqm");
	precache_model("models/weapon_world/w_rocket.iqm");
}

void main()
{
}

void worldspawn()
{
	PrecacheModels();
}

void StartFrame()
{
}


