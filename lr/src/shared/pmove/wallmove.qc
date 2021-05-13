#include "pmove.qh"

void SetOnWall(float onWall)
{
	if (onWall == FALSE)
	{
		self.wallEntity = self;
	}
	else
	{
		self.wallNormal = trace_plane_normal;

		if (self.wallEntity == self)
		{
			OnTouchWall();
		}

		self.wallEntity = trace_ent;
	}
}

void OnTouchWall()
{
	self.wallrunStart = time;
	if (self.velocity.z > 0)
	{
		self.velocity.z = 0;
	}
}

float IsOnWall()
{
	if (self.wallEntity == self)
	{
		return FALSE;
	}
	else
	{
		return TRUE;
	}
}

void WallTrace()
{
	vector start, end;

	if (IsOnGround() || self.moveFlags & MF_RAMPSLIDE)
	{
		SetOnWall(FALSE);
		return;
	}

	if (!IsOnWall() && input_movevalues.z > 0)
	{
		SetOnWall(FALSE);
		return;
	}

	if (time - self.wallrunEnd < cvar("sv_wallrun_timeout"))
	{
		SetOnWall(FALSE);
		return;
	}

#ifdef SSQC
	makevectors(self.v_angle);
#else
	makevectors(view_angles);
#endif

	v_right.z = 0;
	v_forward.z = 0;
	v_right = normalize(v_right);
	v_forward = normalize(v_forward);

	start = self.origin;// - cvar("sv_wallrun_distance") * v_forward;
	end = start + cvar("sv_wallrun_distance") * v_right;
	TracePlayer(start, end);

	if (trace_fraction < 1 && trace_plane_normal.z == 0 && trace_ent == world)
	{
		SetOnWall(TRUE);
		return;
	}

	end = start + cvar("sv_wallrun_distance") * v_right * -1;
	TracePlayer(start, end);

	if (trace_fraction < 1 && trace_plane_normal.z == 0 && trace_ent == world)
	{
		SetOnWall(TRUE);
		return;
	}

	SetOnWall(FALSE);
}

float CheckWallJump()
{
	float umove = input_movevalues.z;
	vector add;

	if (umove <= 0)
	{
		return FALSE;
	}

	if (time - self.wallrunStart < cvar("sv_wallrun_jumpdelay"))
	{
		return FALSE;
	}

	self.wallrunEnd = time; 

	add = 0.7 * vlen(self.velocity) * self.wallNormal;

	if (vlen(add) < 270)
	{
		add = 270 * normalize(add);
	}

	self.velocity += add;
	return TRUE;
}

void WallMove()
{
	float fmove, smove;
	float wishSpeed;
	vector wishDir;

	float accel, maxSpeed;
	
	if (CheckWallJump())
	{
		AirMove();
		return;
	}
	
	Friction(cvar("sv_wallrun_friction"), cvar("sv_stopspeed"));

#ifdef SSQC
	makevectors(self.v_angle);
#else
	makevectors(view_angles);
#endif
	
	fmove = input_movevalues.x;
	smove = input_movevalues.y;

	v_forward = ClipVector(v_forward, self.wallNormal, OVERBOUNCE);
	v_right = ClipVector(v_right, self.wallNormal, OVERBOUNCE);

	v_forward = normalize(v_forward);
	v_right = normalize(v_right);

	wishDir = v_forward * fmove + v_right * smove;
	wishSpeed = vlen(wishDir);
	wishDir = normalize(wishDir);

	accel = cvar("sv_wallaccelerate");
	maxSpeed = cvar("sv_maxwallspeed");

	Accelerate(wishDir, wishSpeed, accel, maxSpeed);

	StepSlideMove();
}
