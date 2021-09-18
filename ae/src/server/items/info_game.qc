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

	self.nextthink = time + 1;
	self.think = info_gameThink;

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
			timeToSend = -1;
			self.winTime--;
			break;
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, CMD_GAMETIME);
	WriteLong(MSG_MULTICAST, timeToSend);
	multicast('0 0 0', MULTICAST_ALL);

	if (timeToSend - 1 == 0 && self.currentStatus != STATUS_WIN)
	{
		self.currentStatus++;
	}

	self.nextthink = time + 1;
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
