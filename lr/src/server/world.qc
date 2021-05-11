#include "world.qh"

void PrecacheModels()
{
	precache_model("models/player.iqm");
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


