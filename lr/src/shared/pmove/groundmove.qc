#include "pmove.qh"

float CheckJump()
{
	float umove = input_movevalues.z;
	
	if (umove <= 0)
	{
		return FALSE;
	}

	if (cvar("sv_trimp") > 0)
	{
		self.velocity.z += 270;
	}
	else
	{
		self.velocity.z = 270;
	}

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

	ClipVector(v_forward, self.groundNormal, OVERBOUNCE);
	ClipVector(v_right, self.groundNormal, OVERBOUNCE);
	v_forward = normalize(v_forward);
	v_right = normalize(v_right);


	wishDir = v_forward * fmove + v_right * smove;
	wishSpeed = vlen(wishDir);
	wishDir = normalize(wishDir);

	accel = cvar("sv_accelerate");
	maxSpeed = cvar("sv_maxspeed");

	Accelerate(wishDir, wishSpeed, accel, maxSpeed);

	speed = vlen(self.velocity);

	ClipVelocity(self.groundNormal, OVERBOUNCE);

	self.velocity = normalize(self.velocity);
	self.velocity *= speed;

	StepSlideMove();
}
