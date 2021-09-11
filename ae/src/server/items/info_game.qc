#include "info_game.qh"

void info_game()
{
	if (self.points <= 0)
	{
		self.points = 5;
	}

	SetGameMode(self.mode, self.points);
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
		player = find(world, classname, "player");
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
