#include "pmove.qh"

void FlyMove()
{
	float fmove, smove;
	float wishSpeed;
	float oldZVel;
    vector oldVel;
	vector wishDir;
	float accel, maxSpeed;

	if (cvar("sv_airfriction") > 0)
	{
		oldZVel = self.velocity.z;
		Friction(cvar("sv_airfriction"), cvar("sv_stopspeed"));
		self.velocity.z = oldZVel;
	}

#ifdef SSQC
	makevectors(self.v_angle);
#else
	makevectors(view_angles);
#endif

	fmove = -1 * input_movevalues.x;
	smove = input_movevalues.y;

	wishDir = v_up * fmove + v_right * smove;
	wishSpeed = vlen(wishDir);
	wishDir = normalize(wishDir);

	accel = cvar("sv_flyaccelerate");
    maxSpeed = cvar("sv_maxflyspeed");

	Accelerate(wishDir, wishSpeed, accel, maxSpeed);

    oldVel = self.velocity; 

	if (cvar("sv_airstep") > 0)
	{
		StepSlideMove();
	}
	else
	{
		SlideMove();
	}

    if (vlen(oldVel) > vlen(self.velocity))
    {
        self.velocity = oldVel;
    }
}
