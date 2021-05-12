#include "pmove.qh"

void NoclipMove()
{
	float fmove, smove, umove, speedMult;
	float wishSpeed, accel, maxSpeed, friction;
	vector wishDir;

	speedMult = cvar("sv_noclipspeed");

	fmove = input_movevalues.x * speedMult;
	smove = input_movevalues.y * speedMult;
	umove = input_movevalues.z * speedMult;

	makevectors(self.v_angle);

	wishDir = fmove * v_forward + smove * v_right + umove * v_up;
	wishSpeed = vlen(wishDir);
	wishDir = normalize(wishDir);

	accel = cvar("sv_noclipaccelerate");
	maxSpeed = cvar("sv_maxnoclipspeed");
	friction = cvar("sv_noclipfriction");

	Friction(friction, cvar("sv_stopspeed"));
	Accelerate(wishDir, wishSpeed, accel, maxSpeed);
	SlideMove();
}
