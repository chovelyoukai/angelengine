#include "pmove.qh"

void AirMove()
{
	float fmove, smove;
	float wishSpeed;
	float oldZVel;
	vector wishDir;

	float accel, maxSpeed;

	if (self.moveFlags & MF_RAMPSLIDE)
	{
		CheckJump();
	}

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

	fmove = input_movevalues.x;
	smove = input_movevalues.y;

	v_forward.z = 0;
	v_right.z = 0;

	v_forward = normalize(v_forward);
	v_right = normalize(v_right);

	wishDir = v_forward * fmove + v_right * smove;
	wishDir.z = 0;
	wishSpeed = vlen(wishDir);
	wishDir = normalize(wishDir);

	if (AngleToVelocity(wishDir) > QWAccelThreshold())
	{
		accel = cvar("sv_airstrafeaccelerate");
		maxSpeed = cvar("sv_maxairstrafespeed");
	}
	else
	{
		accel = cvar("sv_airaccelerate");
		maxSpeed = cvar("sv_maxairspeed");
	}

	if (cvar("sv_aircontrol") > 0)
	{
		accel = cvar("sv_airaccelerate");
		maxSpeed = cvar("sv_maxairspeed");
		Control(wishDir, wishSpeed, accel, maxSpeed);
	}
	else
	{
		Accelerate(wishDir, wishSpeed, accel, maxSpeed);
	}

	if (!(self.moveFlags & MF_RAMPSLIDE && cvar("sv_rampslide_gravity") == 0))
	{
		self.velocity.z -= cvar("sv_gravity") * frametime;
	}

	if (cvar("sv_airstep") > 0)
	{
		StepSlideMove();
	}
	else
	{
		SlideMove();
	}
}

float AngleToVelocity(vector direction)
{
	float angle;
	vector vel2D = self.velocity;
	vel2D.z = 0;
	
	if (vlen(direction) < 0.01)
	{
		return 0;
	}

	angle = acos(DotProduct(direction, vel2D) / (vlen(direction) * vlen(vel2D)));
	return angle;
}

float QWAccelThreshold()
{
	float angle;

	angle = acos(cvar("sv_maxairstrafespeed") / vlen2d(self.velocity));

	return angle;
}
