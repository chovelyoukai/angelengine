#include "player.qh"

void SV_RunClientCommand()
{
    PlayerMove();
}

void PlayerPreThink()
{
    if (self.oldOrigin != self.origin)
    {
        self.SendFlags |= FL_ORIGIN;
    }
    if (self.oldVelocity != self.velocity)
    {
        self.SendFlags |= FL_VELOCITY;
    }
    if (self.oldMovetype != self.movetype)
    {
        self.SendFlags |= FL_MOVETYPE;
    }
    if (self.oldMoveFlags != self.moveFlags)
    {
        self.SendFlags |= FL_MOVEFLAGS;
    }
    self.oldOrigin = self.origin;
    self.oldVelocity = self.velocity;
    self.oldMovetype = self.movetype;
    self.oldMoveFlags = self.moveFlags;

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
    if (self.oldOrigin != self.origin)
    {
        self.SendFlags |= FL_ORIGIN;
    }
    if (self.oldVelocity != self.velocity)
    {
        self.SendFlags |= FL_VELOCITY;
    }
    if (self.oldMovetype != self.movetype)
    {
        self.SendFlags |= FL_MOVETYPE;
    }
    if (self.oldMoveFlags != self.moveFlags)
    {
        self.SendFlags |= FL_MOVEFLAGS;
    }
    self.oldOrigin = self.origin;
    self.oldVelocity = self.velocity;
    self.oldMovetype = self.movetype;
    self.oldMoveFlags = self.moveFlags;
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
        WriteByte(MSG_ENTITY, ENT_PLAYER_OTHER);
    }
    else
    {
        WriteByte(MSG_ENTITY, ENT_PLAYER);
    }

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
    if (entFlags & FL_MOVETYPE)
    {
        WriteLong(MSG_ENTITY, self.movetype);
    }
    if (entFlags & FL_MOVEFLAGS)
    {
        WriteLong(MSG_ENTITY, self.moveFlags);
    }
    if (entFlags & FL_MODELINDEX)
    {
        WriteByte(MSG_ENTITY, self.modelindex);
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
    self.movetype = MOVETYPE_FLY;
    self.solid = SOLID_SLIDEBOX;
    self.deadflag = DEAD_NOT;
    self.SendEntity = PlayerUpdate;
    setorigin(self, spawnLocation.origin + '0 0 80');

    for (float i = 0; i < MAX_WEAPONS; i++)
    {
        if (self.weapons[i] != world)
        {
            remove(self.weapons[i]);
        }

        self.weapons[i] = world;
    }

    self.weapons[0] = RocketlauncherSpawn();
    self.weapons[1] = ShotgunSpawn();
    self.weapons[2] = ChovelSpawn();
    self.weapons[0].Equip(self.weapons[0]);
    self.currentWeapon = self.weapons[0];
}

void PlayerKill(float deathTimeout)
{
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;
    self.deadflag = DEAD_YES;
    self.deadTime = time + deathTimeout;

    self.SendFlags |= FL_ORIGIN;
    self.SendFlags |= FL_VELOCITY;
    self.SendFlags |= FL_MOVETYPE;
    self.SendEntity = PlayerUpdate;
}
