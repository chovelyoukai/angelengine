#include "pmove.qh"

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
    float oldZVel;
    
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
        else if (vlen2d(self.velocity) > cvar("sv_maxspeed"))
        {
            oldZVel = self.velocity.z;
            self.velocity.z = 0;
            self.velocity = normalize(self.velocity);
            self.velocity *= cvar("sv_maxspeed");
            self.velocity.z = oldZVel;
        }
    }
    self.moveFlags &= ~MF_JUMPRELEASED;

    self.velocity.z += 270;
    if (self.velocity.z < 270)
    {
        self.velocity.z = 270;
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

    fmove = input_movevalues.x;
    smove = input_movevalues.y;
#else
    makevectors(view_angles);

    fmove = input_movevalues.x;
    smove = input_movevalues.y;
#endif

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
}
