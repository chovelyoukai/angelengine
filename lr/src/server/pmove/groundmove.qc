#include "pmove.qh"

float CheckJump()
{
	float umove = input_movevalues.z;
	
	if (umove <= 0)
	{
		return FALSE;
	}

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
	vector wishDir;

	float accel, maxSpeed;

	if (CheckJump())
	{
		AirMove();
		return;
	}

	Friction(cvar("sv_friction"), cvar("sv_stopspeed"));

	makevectors(self.v_angle);

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

	accel = cvar("sv_accelerate");
	maxSpeed = cvar("sv_maxspeed");

	Accelerate(wishDir, wishSpeed, accel, maxSpeed);

	SlideMove();
}
