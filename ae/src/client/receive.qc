#include "receive.qh"

void CSQC_Ent_Update(float isNew)
{
    float entType = readbyte();

    switch (entType)
    {
    case ENT_PLAYER:
        ReceivePlayer(isNew, TRUE);
        break;
    case ENT_PLAYER_OTHER:
        ReceivePlayer(isNew, FALSE);
        break;
    case ENT_DAMAGER:
        ReceiveDamager();
    }
}

void CSQC_EntRemove()
{
    remove(self);
}

void ReceivePlayer(float isNew, float isLocalPlayer)
{
    vector newOrigin;
    vector newVelocity;
    float flags;
    float moveInterp = cvar("cl_moveinterp");
    float frameDifference = clientcommandframe - servercommandframe;

    flags = readshort();
    if (flags & FL_ORIGIN)
    {
        newOrigin.x = readcoord();
        newOrigin.y = readcoord();
        newOrigin.z = readcoord();
        
        if (isLocalPlayer && cvar("cl_receive") > 0)
        {
            if (flags & FL_SNAP)
            {
                setorigin(self, newOrigin);
            }
            else
            {
                self.correctOrigin = newOrigin;
                self.fixOrigin = TRUE;
            }
        }
        else if (!isLocalPlayer)
        {
            self.origin = newOrigin;
        }
    }
    if (flags & FL_VELOCITY)
    {
        newVelocity.x = readcoord();
        newVelocity.y = readcoord();
        newVelocity.z = readcoord();

        if (isLocalPlayer && cvar("cl_receive") > 0)
        {
            if (vlen(self.velocity - newVelocity) > 0.1 * vlen(self.velocity)
                * frameDifference || cvar("cl_errorcorrect") == 0)
            {
                self.velocity = newVelocity;
            }
            else
            {
                self.correctVelocity = newVelocity;
                self.fixVelocity = TRUE;
            }
        }
        else if (!isLocalPlayer)
        {
            self.velocity = newVelocity;
        }
    }
    if (flags & FL_MOVETYPE)
    {
        self.movetype = readlong();
        if (isLocalPlayer && self.movetype == MOVETYPE_WALK)
        {
            self.movetype = MOVETYPE_FLY;
        }
    }
    if (flags & FL_MOVEFLAGS)
    {
        self.moveFlags = readlong();
    }
    if (flags & FL_DISCONNECT && !(flags & FL_MODELINDEX))
    {
        setmodel(self, "");
        setsize(self, '0 0 0', '0 0 0');
        return;
    }
    if (flags & FL_MODELINDEX)
    {
        readbyte();
    }

    if (isLocalPlayer)
    {
        player = self;  
    }
    else if (!isLocalPlayer && isNew)
    {
        self.drawmask = MASK_ENGINE;
        setmodel(self, "models/player.iqm");
    }
    setsize(self, PLAYER_MIN_STAND, PLAYER_MAX_STAND);
    self.solid = SOLID_BBOX;
}

void ReceiveDamager()
{
    float flags;
    self.classname = "damager";
    self.timeLeft = time + 1;
    self.knockback = FALSE;
    flags = readbyte();
    if (flags & FL_DAMAGESPAWN)
    {
        self.origin.x = readcoord();
        self.origin.y = readcoord();
        self.origin.z = readcoord();
        self.health = readfloat();
        setorigin(self, self.origin);
    }
    if (flags & FL_KNOCKBACK)
    {
        self.knockback = TRUE;
    }
}

void CSQC_Ent_Remove()
{
    remove(self);
}
