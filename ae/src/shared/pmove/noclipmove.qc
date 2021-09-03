#include "pmove.qh"

void NoclipMove()
{
	float fmove, smove, umove, speedMult;
	float wishSpeed, accel, maxSpeed, friction;
	vector wishDir;

	speedMult = cvar("sv_noclipspeed");

	self.accelType = ACCEL_NOCLIP;

	fmove = input_movevalues.x * speedMult;
	smove = input_movevalues.y * speedMult;
	umove = input_movevalues.z * speedMult;

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		smove *= -1;
		umove *= -1;
	}

#ifdef SSQC
	makevectors(self.v_angle);
#else
	makevectors(view_angles);
#endif

	wishDir = fmove * v_forward + smove * v_right + umove * v_up;
	wishSpeed = vlen(wishDir);
	wishDir = normalize(wishDir);

	accel = cvar("sv_noclipaccelerate");
	maxSpeed = cvar("sv_maxnoclipspeed");
	friction = cvar("sv_noclipfriction");

	Friction(friction, cvar("sv_stopspeed"));
	Accelerate(wishDir, wishSpeed, accel, maxSpeed);

	self.origin = self.origin + self.velocity * frametime;
	//SlideMove();
}
