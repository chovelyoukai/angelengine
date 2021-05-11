#include "pmove.qh"

void SetOnGround(float onGround)
{
	if (onGround == FALSE)
	{
		self.groundEntity = self;
	}
	else
	{
		self.groundNormal = trace_plane_normal;

		if (self.groundEntity == self)
		{
			OnTouchGround();
		}

		self.groundEntity = trace_ent;
	}
}

void OnTouchGround()
{
	self.velocity = ClipVelocity(self.groundNormal, OVERBOUNCE);
	return;
}

float IsOnGround()
{
	// we can't stand on ourselves, so we use self as a sentinal value for
	// "not on ground"
	if (self.groundEntity == self)
	{
		return FALSE;
	}
	else
	{
		return TRUE;
	}
}

void GroundTrace()
{
	vector end;

	end = self.origin;
	end.z -= 0.25;

	TracePlayer(self.origin, end);

	if (trace_fraction < 1)
	{
		SetOnGround(TRUE);
	}
	else
	{
		SetOnGround(FALSE);
	}
}

void PlayerMove()
{
	float fmove, smove, umove;
	float oldFrametime = frametime;

	frametime = time - lastMovetime;
	lastMovetime = time;

	GroundTrace();

	fmove = input_movevalues.x;
	smove = input_movevalues.y;
	umove = input_movevalues.z;

	makevectors(self.v_angle);

	self.velocity = fmove * v_forward + smove * v_right + umove * v_up;

	SlideMove();

	frametime = oldFrametime;
}
