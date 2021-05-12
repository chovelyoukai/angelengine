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
	float oldZVel = self.velocity.z;

	self.wallclipTime = time + cvar("sv_wallcliptime");
	if (cvar("sv_rampboosts") > 0)
	{
		self.velocity = ClipVelocity(self.groundNormal, OVERBOUNCE);
	}
	if (cvar("sv_q2jump") > 0 && self.velocity.z < oldZVel)
	{
		self.velocity.z = oldZVel;
	}
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

	self.moveFlags &= ~MF_RAMPSLIDE;

	// if we didn't hit anything, we can't be on the ground
	if (trace_fraction == 1)
	{
		SetOnGround(FALSE);
	}
	// if the ground is too steep, we can't stand on it
	else if (trace_plane_normal.z < 0.7)
	{
		SetOnGround(FALSE);
	}
	// if we *did* hit the ground but have some upwards velocity,
	// make us not on the ground (rampsliding)
	else if (self.velocity.z > 180 && cvar("sv_rampslides") > 0)
	{
		self.moveFlags |= MF_RAMPSLIDE;
		SetOnGround(FALSE);
	}
	else
	{
		SetOnGround(TRUE);
	}
}

void Control(vector wishDir, float wishSpeed, float accel, float maxSpeed)
{
	vector wishVel;
	vector diff;
	vector flatVelocity;
	float currentSpeed;
	float multiplier, angle;

	if (wishSpeed == 0)
	{
		return;
	}

	// find out what velocity the player *wants* to have
	if (wishSpeed > maxSpeed)
	{
		wishSpeed = maxSpeed;
	}
	wishVel = normalize(wishDir);
	wishVel *= wishSpeed;

	flatVelocity = self.velocity;
	flatVelocity.z = 0;
	currentSpeed = vlen(flatVelocity);

	if (currentSpeed > 0)
	{
		angle = AngleToVelocity(wishVel);
		angle = RadiansToDegrees(angle);
	}
	else
	{
		angle = 0;
	}

	// if we are going faster than maxspeed, we don't want a wishvel going
	// straight forward to slow us down, so we will only allow ourselves to be
	// slowed when wishing at an angle.
	if (currentSpeed > maxSpeed && angle < 90)
	{
		multiplier = angle / 90;
		wishVel = ((1 - multiplier) * flatVelocity) + (multiplier * wishVel);
	}

	diff = flatVelocity - wishVel;
	// don't accelerate more than allowed.
	if (vlen(diff) > accel * frametime)
	{
		diff = normalize(diff);
		diff *= accel;
	}

	self.velocity -= diff;

	Accelerate(wishDir, wishSpeed, accel, maxSpeed);
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
	float pmoveTime = cvar("sv_pmovetime");
	float remainingTime = time - lastMovetime;

	while (remainingTime > pmoveTime)
	{
		frametime = pmoveTime;
		remainingTime -= pmoveTime;
		lastMovetime += pmoveTime;

		GroundTrace();

		if (self.movetype == MOVETYPE_NOCLIP)
		{
			NoclipMove();
		}
		else if (IsOnGround())
		{
			GroundMove();
		}
		else
		{
			AirMove();
		}
	}

	frametime = oldFrametime;
}
