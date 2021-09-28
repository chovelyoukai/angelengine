#include "info_game.qh"

void info_game()
{
	if (self.points <= 0)
	{
		self.points = 5;
	}

	if (self.setupTime <= 0)
	{
		self.setupTime = 15;
	}
	if (self.gameTime <= 0)
	{
		self.gameTime = 10 * 60;
	}

	self.currentStatus = STATUS_SETUP;
	self.winTime = 15;

	self.nextthink = time + 0.1;
	self.think = info_gameThink;

	gameInfo = self;

	SetGameMode(self.mode, self.points);
}

void info_gameThink()
{
	float timeToSend = 0;

	switch (self.currentStatus)
	{
		case STATUS_SETUP:
			timeToSend = self.setupTime;
			self.setupTime--;
			break;
		case STATUS_GAME:
			timeToSend = self.gameTime;
			self.gameTime--;
			break;
		case STATUS_WIN:
			timeToSend = self.winTime;
			self.winTime--;
			break;
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, CMD_GAMETIME);
	WriteLong(MSG_MULTICAST, timeToSend);
	multicast('0 0 0', MULTICAST_ALL);

	if (timeToSend - 1 == 0)
	{
		if (self.currentStatus != STATUS_WIN)
		{
			self.currentStatus++;
			if (self.currentStatus == STATUS_GAME)
			{
				self.think = PlayStartSound;
			}
			else if (self.currentStatus == STATUS_WIN)
			{
				LoseGame();
			}
		}
		else
		{
			EndGame();
		}
	}

	self.nextthink = time + 1;
}

void PlayStartSound()
{
	string fname = "music/starts/start";

	if (cvar("sv_playsounds") != 0)
	{
		fname = strcat(fname, ftos(floor(10 * random()) + 1), ".wav");
		sound(world, CHAN_AUTO, fname, 1.0, ATTN_NONE);
	}

	self.think = info_gameThink;
	self.think();
}

void PlayEndSound()
{
	string fname = "music/ends/end";

	if (cvar("sv_playsounds") != 0)
	{
		fname = strcat(fname, ftos(floor(10 * random()) + 1), ".wav");
		sound(world, CHAN_AUTO, fname, 1.0, ATTN_NONE);
	}

	self.think = info_gameThink;
	self.think();
}

void SetGameMode(float newMode, float newPoints)
{
	entity player;

	gameMode = newMode;
	winPoints = newPoints;

	player = world;
	player = find(world, classname, "player");

	while (player != world)
	{
		SendGameMode(player);
		player.frags = 0;
		player = find(player, classname, "player");
	}
}

void SendGameMode(entity to)
{
	msg_entity = to;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, CMD_GAMEMODE);
	WriteByte(MSG_MULTICAST, gameMode);
	WriteLong(MSG_MULTICAST, winPoints);
	multicast('0 0 0', MULTICAST_ONE_R);
}

void EndGame()
{
	changelevel(mapname);
}

void WinGame(entity player)
{
	bprint(10000, player.netname, " has won the game!\n");
	gameInfo.currentStatus = STATUS_WIN;
	gameInfo.think = PlayEndSound;
}

void LoseGame()
{
	bprint(10000, "No one could win the game...\n");
	gameInfo.currentStatus = STATUS_WIN;
	gameInfo.think = PlayEndSound;
}

void UpdatePoints(entity player)
{
	if (gameInfo == world)
	{
		player.frags++;
	}

	switch(gameInfo.mode)
	{
		case GM_FFADM:
			player.frags++;
			if (player.frags >= gameInfo.points)
			{
				WinGame(player);
			}
			break;
		case GM_FFABALL:
			if (ball.owner == player)
			{
				player.frags++;
			}
			if (player.frags >= gameInfo.points)
			{
				WinGame(player);
			}
			break;
	}
}
