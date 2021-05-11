#include "pmove.qh"

void AirMove()
{
	float fmove, smove;
	float wishSpeed;
	vector wishDir;

	float accel, maxSpeed;

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

	accel = cvar("sv_airaccelerate");
	maxSpeed = cvar("sv_maxairspeed");

	Accelerate(wishDir, wishSpeed, accel, maxSpeed);

	self.velocity.z -= cvar("sv_gravity") * frametime;
	
	SlideMove();
}
