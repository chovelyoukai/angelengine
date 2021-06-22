#include "pmove.qh"

void SetOnGround(float onGround)
{
    if (onGround == FALSE)
    {
        self.groundEntity = self;
    }
    else
    {
        self.groundNormal = trace_plane_normal;

        if (self.groundEntity == self)
        {
            OnTouchGround();
        }

        self.groundEntity = trace_ent;
    }
}

void OnTouchGround()
{
    float oldZVel = self.velocity.z;

    self.wallclipTime = time + cvar("sv_wallcliptime");
    self.velocity = ClipVelocity(self.groundNormal, OVERBOUNCE);
    if (self.velocity.z < oldZVel)
    {
        self.velocity.z = oldZVel;
    }
    self.landingTime = time + 0.1;
    self.landingVelocity = self.velocity;
    self.moveFlags &= ~MF_CANCRIT;

#ifdef SSQC
    self.stepTime = time;
    sound(self, CHAN_AUTO, "player/step.wav", 0.3, ATTN_NORM);
#endif

    return;
}

float IsOnGround(entity ent)
{
    // we can't stand on ourselves, so we use self as a sentinal value for
    // "not on ground"
    if (ent.groundEntity == ent)
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

void GroundTrace()
{
    vector end;

    end = self.origin;
    end.z -= 0.25;

    TracePlayer(self.origin, end);

    self.moveFlags &= ~MF_RAMPSLIDE;

    // if we didn't hit anything, we can't be on the ground
    if (trace_fraction >= 0.99)
    {
        SetOnGround(FALSE);
    }
    // if the ground is too steep, we can't stand on it
    else if (trace_plane_normal.z < 0.7)
    {
        SetOnGround(FALSE);
    }
    // if we *did* hit the ground but have some upwards velocity,
    // make us not on the ground (rampsliding)
    else if (self.velocity.z > 180)
    {
        self.moveFlags |= MF_RAMPSLIDE;
        SetOnGround(FALSE);
    }
    else
    {
        SetOnGround(TRUE);
    }
}

void Accelerate(vector wishDir, float wishSpeed, float accel, float maxSpeed)
{
    float addSpeed, accelSpeed, currentSpeed, originalWishSpeed;

    originalWishSpeed = wishSpeed;

    if (wishSpeed > maxSpeed)
    {
        wishSpeed = maxSpeed;
    }

    currentSpeed = DotProduct(self.velocity, wishDir);

    addSpeed = wishSpeed - currentSpeed;

    if (addSpeed <= 0)
    {
        return;
    }

    accelSpeed = accel * originalWishSpeed * frametime;

    if (accelSpeed > addSpeed)
    {
        accelSpeed = addSpeed;
    }

    self.velocity += accelSpeed * wishDir;
}

void Friction(float friction, float stopSpeed)
{
    vector newVel;
    float speed, newSpeed, control, drop;

    newVel = self.velocity;
    if (self.movetype != MOVETYPE_NOCLIP)
    {
        newVel.z = 0;
    }

    speed = vlen(newVel);

    if (speed < 1)
    {
        self.velocity.x = 0;
        self.velocity.y = 0;
        return;
    }

    if (speed < stopSpeed)
    {
        control = stopSpeed;
    }
    else
    {
        control = speed;
    }

    drop = control * friction * frametime;
    newSpeed = speed - drop;

    if (newSpeed < 0)
    {
        newSpeed = 0;
    }

    newSpeed /= speed;

    self.velocity = self.velocity * newSpeed;
}

void PlayerMove()
{
    float oldFrametime = frametime;
    float pmoveTime = cvar("sv_pmovetime");
    float remainingTime = time - self.lastMoveTime;
    float oldFlags = self.moveFlags;

    if (pmoveTime <= 0)
    {
        pmoveTime = 0.008;
    }

    while (remainingTime > pmoveTime)
    {
        frametime = pmoveTime;
        remainingTime -= pmoveTime;
        self.lastMoveTime += pmoveTime;

        GroundTrace();
        WallTrace();
        CheckJumpReleased();

        if (self.movetype == MOVETYPE_NONE)
        {
        }
        else if (self.movetype == MOVETYPE_NOCLIP)
        {
            NoclipMove();
        }
        else if (cvar("sv_fly") > 0)
        {
            FlyMove();
        }
        else if (IsOnGround(self))
        {
            GroundMove();
        }
        else if (IsOnWall())
        {
            WallMove();
        }
        else
        {
            AirMove();
        }

        touchtriggers();
    }

    frametime = oldFrametime;
}
