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
	CheckImpulses();
	CheckWeapons();
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
