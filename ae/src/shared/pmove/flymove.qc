#include "pmove.qh"

void FlyMove()
{
	float fmove, smove;
	float wishSpeed;
	float oldZVel;
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
	self.accelType = ACCEL_FLY;

	Accelerate(wishDir, wishSpeed, accel, maxSpeed);

	SlideMove();
}
