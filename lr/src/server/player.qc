#include "player.qh"

void SV_RunClientCommand()
{
	PlayerMove();
	self.SendFlags |= FL_ORIGIN;
	self.SendFlags |= FL_VELOCITY;
	self.SendEntity = PlayerUpdate;
}

void PlayerPreThink()
{
	if (!self.deadflag)
	{
		CheckImpulses();
		CheckWeapons();
	}
	else
	{
		if (time > self.deadTime)
		{
			PlayerSpawn();
		}
	}
}

void PlayerPostThink()
{
}

void SetNewParms()
{
}

void SetChangeParms()
{
}

float PlayerUpdate(entity to, float entFlags)
{
	if (to != self)
	{
		return FALSE;
	}

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteByte(MSG_ENTITY, entFlags);

	if (entFlags & FL_ORIGIN)
	{
		WriteCoord(MSG_ENTITY, self.origin.x);
		WriteCoord(MSG_ENTITY, self.origin.y);
		WriteCoord(MSG_ENTITY, self.origin.z);
	}
	if (entFlags & FL_VELOCITY)
	{
		WriteCoord(MSG_ENTITY, self.velocity.x);
		WriteCoord(MSG_ENTITY, self.velocity.y);
		WriteCoord(MSG_ENTITY, self.velocity.z);
	}

	return TRUE;
}

void PlayerSpawn()
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
	self.deadflag = DEAD_NOT;
	setorigin(self, spawnLocation.origin + '0 0 80');

	for (float i = 0; i < MAX_WEAPONS; i++)
	{
		if (self.weapons[i] != world)
		{
			remove(self.weapons[i]);
		}

		self.weapons[i] = world;
	}

	self.weapons[0] = GrappleSpawn();
	self.weapons[1] = GrappleSpawn();
	self.currentWeapon = self.weapons[0];
}

void PlayerKill(entity player, float deathTimeout)
{
	player.movetype = MOVETYPE_NONE;
	player.solid = SOLID_NOT;
	player.deadflag = DEAD_YES;
	player.deadTime = deathTimeout;
}
