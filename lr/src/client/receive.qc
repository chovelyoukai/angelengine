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

    flags = readbyte();
    if (flags & FL_ORIGIN)
    {
        newOrigin.x = readcoord();
        newOrigin.y = readcoord();
        newOrigin.z = readcoord();
        
        if (isLocalPlayer)
        {
            if (vlen(self.origin - newOrigin) > 15)
            {
                setorigin(self, newOrigin);
            }
            else
            {
                self.correctOrigin = newOrigin;
                self.fixOrigin = TRUE;
            }
        }
        else
        {
            self.origin = newOrigin;
        }
    }
    if (flags & FL_VELOCITY)
    {
        newVelocity.x = readcoord();
        newVelocity.y = readcoord();
        newVelocity.z = readcoord();

        if (isLocalPlayer)
        {
            if (vlen(self.velocity - newVelocity) > 15)
            {
                self.velocity = newVelocity;
            }
            else
            {
                self.correctVelocity = newVelocity;
                self.fixVelocity = TRUE;
            }
        }
        else
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
        setsize(self, PLAYER_MIN_STAND, PLAYER_MAX_STAND);
    }
}
