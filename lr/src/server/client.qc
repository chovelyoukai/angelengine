#include "client.qh"
#include "player.qh"

void ClientConnect()
{
}

void ClientDisconnect()
{
}

void ClientKill()
{
}

void PutClientInServer()
{
	entity spawnLocation = SelectSpawn();

	self.classname = "player";
	self.health = self.max_health = 100;
	self.flags = FL_CLIENT;
	self.effects |= EF_FULLBRIGHT;
	setmodel(self, "models/player.iqm");
	setsize(self, PLAYER_MIN_STAND, PLAYER_MAX_STAND);
	self.angles = spawnLocation.angles;
	self.fixangle = TRUE;
	self.view_ofs = PLAYER_VIEW_STAND;
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_WALK;
	self.solid = SOLID_SLIDEBOX;
	setorigin(self, spawnLocation.origin + '0 0 80');
}

entity SelectSpawn()
{
	entity spot, thing;
	float nearby;

	spot = lastSpawn;

	while (TRUE)
	{
		spot = find(spot, classname, "info_player_start");
		if (spot != world)
		{
			if (spot == lastSpawn)
			{
				return spot;
			}

			nearby = 0;
			thing = findradius(spot.origin, 32);

			while (thing)
			{
				if (thing.classname == "player")
				{
					nearby++;
				}

				thing = thing.chain;
			}

			if (nearby == 0)
			{
				lastSpawn = spot;
				return spot;
			}
		}
	}
	
	return spot;
}
