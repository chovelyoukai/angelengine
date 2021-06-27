#include "pmove.qh"

void JumpSpeedReduce()
{
    float oldZVel;
    float maxSpeed;

    if (cvar("sv_skate") > 0)
    {
        if (self.grindTime > 0)
        {
            return;
        }
        maxSpeed = cvar("sv_maxskatespeed");
    }
    else
    {
        maxSpeed = cvar("sv_maxspeed");
    }

    if (vlen2d(self.velocity) > maxSpeed)
    {
    oldZVel = self.velocity.z;
    self.velocity.z = 0;
    self.velocity = normalize(self.velocity);
    self.velocity *= maxSpeed;
    self.velocity.z = oldZVel;
    }
}

void CheckJumpReleased()
{
    float umove = input_movevalues.z;

    if (umove <= 0)
    {
        self.moveFlags |= MF_JUMPRELEASED;
    }
    else if (!IsOnGround(self))
    {
        self.moveFlags &= ~MF_JUMPRELEASED;
    }
}

float CanBhop()
{
    if (cvar("sv_rockethop") > 0)
    {
        return TRUE;
    }

    if (cvar("sv_skate") > 0)
    {
        return FALSE;
    }

#ifdef SSQC
    if (self.currentWeapon.classname == "weapon_rocketlauncher")
#else
    if (viewmodel.weaponType == WEP_ROCKETLAUNCHER)
#endif
    {
        return FALSE;
    }


    return TRUE;
}

float CheckJump()
{
    float umove = input_movevalues.z;
    
    if (umove <= 0)
    {
        return FALSE;
    }

    if (!CanBhop())
    {
        if(!(self.moveFlags & MF_JUMPRELEASED))
        {
            return FALSE;
        }
        else 
        {
            JumpSpeedReduce();
        }
    }
    self.moveFlags &= ~MF_JUMPRELEASED;

    if (self.moveFlags & MF_RAMPSLIDE && self.velocity.z < -180)
    {
        self.moveFlags |= MF_CANCRIT;
    }
    if (self.grinding)
    {
        self.moveFlags |= MF_CANCRIT;
    }
    self.velocity.z += 270;
    if (self.velocity.z < 270)
    {
        self.velocity.z = 270;
    }

    if (self.velocity.z > 300)
    {
        self.moveFlags |= MF_CANCRIT;
    }

    return TRUE;
}

void GroundMove()
{
    float fmove, smove;
    float wishSpeed;
    float speed;
    vector wishDir;

    float accel, maxSpeed;

    if (CheckJump())
    {
        AirMove();
        return;
    }

    self.accelType = ACCEL_GROUND;

    Friction(cvar("sv_friction"), cvar("sv_stopspeed"));

#ifdef SSQC
    makevectors(self.v_angle);
#else
    makevectors(view_angles);
#endif

    fmove = input_movevalues.x;
    smove = input_movevalues.y;

    v_forward.z = 0;
    v_right.z = 0;

    v_forward = ClipVector(v_forward, self.groundNormal, OVERBOUNCE);
    v_right = ClipVector(v_right, self.groundNormal, OVERBOUNCE);
    v_forward = normalize(v_forward);
    v_right = normalize(v_right);


    wishDir = v_forward * fmove + v_right * smove;
    wishSpeed = vlen(wishDir);
    wishDir = normalize(wishDir);

    accel = cvar("sv_accelerate");
    maxSpeed = cvar("sv_maxspeed");

    Accelerate(wishDir, wishSpeed, accel, maxSpeed);

    speed = vlen(self.velocity);

    self.velocity = ClipVelocity(self.groundNormal, OVERBOUNCE);

    self.velocity = normalize(self.velocity);
    self.velocity *= speed;

    StepSlideMove();

#ifdef SSQC
    float stepTimeout;
    float pitch;
    speed = vlen(self.velocity);
    if (speed < 1)
    {
        return;
    }
    else if (speed >= cvar("sv_maxspeed"))
    {
        stepTimeout = 0.4;
    }
    else
    {
        stepTimeout = 1.4 - (vlen(self.velocity) / cvar("sv_maxspeed"));
    }

    if (time - self.stepTime > stepTimeout)
    {
        pitch = 100 + (10 * random()) - 5;
        self.stepTime = time;
        sound(self, CHAN_AUTO, "player/step.wav", 0.3, ATTN_NORM, pitch);
    }
#endif
}
