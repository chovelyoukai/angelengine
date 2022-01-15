#include "pmove.qh"

void SetOnWall(float onWall)
{
	if (onWall == FALSE)
	{
		self.wallEntity = self;
	}
	else
	{
		if (self.wallEntity == self)
		{
			if (!OnTouchWall())
			{
				SetOnWall(FALSE);
				return;
			}
		}

		self.wallNormal = trace_plane_normal;
		self.wallEntity = trace_ent;
	}
}

float OnTouchWall()
{
	if (self.wallNormal * trace_plane_normal > 0.1 &&
		time - self.wallrunEnd < cvar("sv_wallrun_timeout"))
	{
		return FALSE;
	}

#ifdef SSQC
	sound(self, CHAN_AUTO, "player/wallattach.wav", 1.0, ATTN_NORM);
#endif
	self.wallrunStart = time;
	self.canDoubleJump = TRUE;
	return TRUE;
}

float IsOnWall(entity ent)
{
	if (ent.wallEntity == self)
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

	if (!(self.moveFlags & MF_WALLRUN))
	{
		SetOnWall(FALSE);
		return;
	}

	if (IsOnGround(self) || self.moveFlags & MF_RAMPSLIDE)
	{
		SetOnWall(FALSE);
		return;
	}

	if (!(input_buttons & BUTTON_MOD1))
	{
		SetOnWall(FALSE);
		return;
	}

	if (cvar("sv_fly") > 0)
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

	float trace1_fraction;
	vector trace1_plane_normal;
	int trace1_surfaceflagsi;
	int trace1_endcontentsi;

	float mult;
	for (mult = 1; mult >= -1; mult -= 2)
	{
		start = self.origin + '0 0 15';
		end = start + cvar("sv_wallrun_distance") * v_right * mult;
		tracebox(start, WALL_TRACE_MIN, WALL_TRACE_MAX, end, 0, self);

		trace1_fraction = trace_fraction;
		trace1_plane_normal = trace_plane_normal;
		trace1_surfaceflagsi = trace_surfaceflagsi;
		trace1_endcontentsi = trace_endcontentsi;

		start = self.origin + '0 0 -15';
		end = start + cvar("sv_wallrun_distance") * v_right * mult;
		tracebox(start, WALL_TRACE_MIN, WALL_TRACE_MAX, end, 0, self);

		if (trace1_fraction < 1 && trace1_plane_normal.z == 0 &&
			!(trace1_surfaceflagsi & 0x10) && !(trace1_endcontentsi & CONTENTBIT_PLAYERCLIP) &&
			trace_fraction < 1 && trace_plane_normal.z == 0 &&
			!(trace_surfaceflagsi & 0x10) && !(trace_endcontentsi & CONTENTBIT_PLAYERCLIP))
		{
			if (trace1_fraction > 0.1 && trace_fraction > 0.1)
			{
				self.velocity -= trace_plane_normal * 10;
			}
			SetOnWall(TRUE);
			return;
		}
	}

	SetOnWall(FALSE);
}

float CheckWallJump()
{
	float umove = input_movevalues.z;
	vector add;

	if (umove <= 0)
	{
		self.moveFlags |= MF_JUMPRELEASED;
		return FALSE;
	}

	if (time - self.wallrunStart < cvar("sv_wallrun_jumpdelay"))
	{
		return FALSE;
	}

	self.moveFlags &= ~MF_JUMPRELEASED;
	self.wallrunEnd = time; 

#ifdef SSQC
	makevectors(self.v_angle);
#else
	makevectors(view_angles);
#endif

	v_forward.z = 0;
	v_forward = normalize(v_forward);

	add = WALL_JUMP_FORWARDVEL * v_forward;

	add.z += WALL_JUMP_ZVEL;
	add += self.wallNormal * WALL_JUMP_OUTVEL;

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		add.z *= -1;
	}

	self.velocity += add;

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		if (self.velocity.z < -1 * WALL_JUMP_ZVEL)
		{
			self.velocity.z = -1 * WALL_JUMP_ZVEL;
		}
	}
	else
	{
		if (self.velocity.z > WALL_JUMP_ZVEL)
		{
			self.velocity.z = WALL_JUMP_ZVEL;
		}
	}

	self.wallrunStart = time;
	self.canDoubleJump = TRUE;
	SetOnWall(FALSE);

#ifdef SSQC
	sound(self, CHAN_AUTO, "player/step.wav", 0.3, ATTN_NORM);
#endif

	return TRUE;
}

void WallMove()
{
	if (CheckWallJump())
	{
		AirMove();
		return;
	}

	self.accelType = ACCEL_WALL;

	vector oldVel;
	if (self.moveFlags & MF_REVERSEGRAV)
	{
		if (self.velocity.z < 0)
		{
			self.velocity.z += cvar("sv_gravity") * frametime * 0.5;
		}
		else
		{
			oldVel = self.velocity;
			Friction(cvar("sv_wallrun_friction"), cvar("sv_stopspeed"));
			self.velocity.x = oldVel.x;
			self.velocity.y = oldVel.y;
		}
	}
	else
	{
		if (self.velocity.z > 0)
		{
			self.velocity.z -= cvar("sv_gravity") * frametime * 0.5;
		}
		else
		{
			oldVel = self.velocity;
			Friction(cvar("sv_wallrun_friction"), cvar("sv_stopspeed"));
			oldVel.z = 0;
			if (vlen(oldVel) < cvar("sv_maxwallspeed"))
			{
				oldVel = cvar("sv_maxwallspeed") * normalize(oldVel);
			}
			self.velocity.x = oldVel.x;
			self.velocity.y = oldVel.y;
		}
	}

	AirMove();
}
