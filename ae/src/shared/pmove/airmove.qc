#include "pmove.qh"

void ApplyGravity()
{
	float gravity = cvar("sv_gravity");

	if (cvar("sv_skate") > 0)
	{
		gravity /= 2;
	}

	if (IsOnWall(self))
	{
		return;
	}

	if (self.moveFlags & MF_RAMPSLIDE)
	{
		return;
	}
	
	if (self.moveFlags & MF_REVERSEGRAV)
	{
		self.velocity.z += cvar("sv_gravity") * frametime;
	}
	else
	{
		self.velocity.z -= cvar("sv_gravity") * frametime;
	}
}

void AirMove()
{
	float fmove, smove;
	float wishSpeed;
	float wishAngle;
	float minQWAngle;
	vector wishDir;

	float accel, maxSpeed;

	if ((self.moveFlags & MF_RAMPSLIDE) || ((self.moveFlags & MF_DOUBLEJUMP) && self.canDoubleJump))
	{
		CheckJump();
	}

#ifdef SSQC
	makevectors(self.v_angle);
#else
	makevectors(view_angles);
#endif

	fmove = input_movevalues.x;
	smove = input_movevalues.y;

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		smove *= -1;
	}

	v_forward.z = 0;
	v_right.z = 0;

	v_forward = normalize(v_forward);
	v_right = normalize(v_right);

	wishDir = v_forward * fmove + v_right * smove;
	wishDir.z = 0;
	wishSpeed = vlen(wishDir);
	wishDir = normalize(wishDir);

	wishAngle = AngleToVelocity(wishDir);
	minQWAngle = QWAccelThreshold();

	if (wishAngle < minQWAngle && self.moveFlags & MF_DIFFERENTIAL)
	{
		accel = cvar("sv_airaccelerate");
		if (self.moveFlags & MF_BURDENED)
		{
			maxSpeed = cvar("sv_maxburdenedairspeed");
		}
		else
		{
			maxSpeed = cvar("sv_maxairspeed");
		}
	}
	else
	{
		accel = cvar("sv_airstrafeaccelerate");
		maxSpeed = cvar("sv_maxairstrafespeed");
	}

	wishAngle += 0.03;
	if (wishAngle < minQWAngle && self.moveFlags & MF_DIFFERENTIAL)
	{
		self.accelType = ACCEL_Q3;
	}
	else
	{
		self.accelType = ACCEL_QW;
	}

	Accelerate(wishDir, wishSpeed, accel, maxSpeed);

	ApplyGravity();

	StepSlideMove();
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
