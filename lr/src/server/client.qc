#include "client.qh"

void ClientConnect()
{
	print(self.netname, " has connected.\n");

	for (float i = 0; i < MAX_WEAPONS; i++)
	{
		self.weapons[i] = world;
	}
}

void ClientDisconnect()
{
	print(self.netname, " has disconnected.\n");
}

void ClientKill()
{
	PlayerKill(cvar("sv_deathtimeout"));
}

void PutClientInServer()
{
	PlayerSpawn();
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
