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
        PlayerSpawn();
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
    if (self.sendTime < time)
    {
        self.SendFlags |= FL_NETNAME;
        self.oldNetname = self.netname;

        self.SendFlags |= FL_ORIGIN | FL_VELOCITY | FL_MOVETYPE |
            FL_MOVEFLAGS;

        self.sendTime = time + cvar("sv_send_interval");
    }
    self.oldOrigin = self.origin;
    self.oldVelocity = self.velocity;
    self.oldMovetype = self.movetype;
    self.oldMoveFlags = self.moveFlags;

    if (self.health > 100 && self.nextHealthTick < time)
    {
        if (self.health < 101)
        {
            self.health = 100;
        }
        else
        {
            self.health--;
        }
        self.nextHealthTick = time + 1;
    }
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
    if (entFlags > 1023)
    {
        entFlags &= ~FL_NETNAME;
    }

    WriteLong(MSG_ENTITY, entFlags);

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
    if (entFlags & FL_NETNAME)
    {
        WriteString(MSG_ENTITY, self.netname);
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
    setorigin(self, spawnLocation.origin + '0 0 80');
    self.SendEntity = PlayerUpdate;
    self.SendFlags |= FL_SNAP;
    self.moveFlags = 0;

    for (float i = 0; i < MAX_WEAPONS; i++)
    {
        if (self.weapons[i] != world)
        {
            remove(self.weapons[i]);
        }

        self.weapons[i] = world;
    }

    self.weaponsHeld = 0;
    self.weaponType = WEP_NONE;
    self.currentWeapon = world;
}

void PlayerKill(entity killer)
{
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;
    self.deadflag = DEAD_YES;

    self.SendFlags |= FL_ORIGIN;
    self.SendFlags |= FL_VELOCITY;
    self.SendFlags |= FL_MOVETYPE;
    self.SendEntity = PlayerUpdate;

    SendPlayerDeath();

    bprint(10000, killer.netname, " killed ", self.netname, "\n");
}

void SendPlayerDeath()
{
    msg_entity = self;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, CMD_DEATH);
    multicast('0 0 0', MULTICAST_ONE_R);
}
