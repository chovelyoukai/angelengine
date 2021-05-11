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

void Accelerate(vector wishDir, float wishSpeed, float accel, float maxSpeed)
{
	float addSpeed, accelSpeed, currentSpeed, originalWishSpeed;

	originalWishSpeed = wishSpeed;

	if (wishSpeed > maxSpeed)
	{
		wishSpeed = maxSpeed;
	}

	currentSpeed = DotProduct(self.velocity, wishDir);

	addSpeed = wishSpeed - currentSpeed;

	if (addSpeed <= 0)
	{
		return;
	}

	accelSpeed = accel * originalWishSpeed * frametime;

	if (accelSpeed > addSpeed)
	{
		accelSpeed = addSpeed;
	}

	self.velocity += accelSpeed * wishDir;
}

void Friction(float friction, float stopSpeed)
{
	vector newVel;
	float speed, newSpeed, control;

	newVel = self.velocity;
	newVel.z = 0;

	speed = vlen(newVel);
	if (!speed)
	{
		return;
	}

	if (speed < stopSpeed)
	{
		control = stopSpeed;
	}
	else
	{
		control = speed;
	}

	newSpeed = speed - (frametime * control * friction);

	if (newSpeed < 0)
	{
		newSpeed = 0;
	}

	newSpeed /= speed;

	self.velocity = self.velocity * newSpeed;
}

void PlayerMove()
{
	float oldFrametime = frametime;

	frametime = time - lastMovetime;
	lastMovetime = time;

	GroundTrace();

	if (IsOnGround())
	{
		GroundMove();
	}
	else
	{
		AirMove();
	}

	frametime = oldFrametime;
}
