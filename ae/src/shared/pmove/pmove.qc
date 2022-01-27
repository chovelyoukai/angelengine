#include "pmove.qh"

void SetOnGround(float onGround)
{
	if (onGround == FALSE)
	{
		self.moveFlags &= ~MF_GRINDING;
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
	self.velocity = ClipVelocity(self.groundNormal, OVERBOUNCE);
	if (self.moveFlags & MF_REVERSEGRAV && self.velocity.z > oldZVel)
	{
		self.velocity.z = oldZVel;
	}
	if (!(self.moveFlags & MF_REVERSEGRAV) && self.velocity.z < oldZVel)
	{
		self.velocity.z = oldZVel;
	}
	self.landingTime = time;
	self.landingVelocity = self.velocity;
	self.moveFlags &= ~MF_CANCRIT;
	self.canDoubleJump = TRUE;

	self.wallNormal = '0 0 0';

#ifdef SSQC
	self.stepTime = time;
	sound(self, CHAN_AUTO, "player/land.wav", 0.5, ATTN_NORM, 150);
#endif

	return;
}

float IsOnGround(entity ent)
{
	// we can't stand on ourselves, so we use self as a sentinal value for
	// "not on ground"
	if (ent.groundEntity == ent)
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
	vector clippedVelocity;
	vector end;

	end = self.origin;
	if (self.moveFlags & MF_REVERSEGRAV)
	{
		end.z += 0.25;
	}
	else
	{
		end.z -= 0.25;
	}

	TracePlayer(self.origin, end);

	self.moveFlags &= ~MF_RAMPSLIDE;

	clippedVelocity = ClipVelocity(trace_plane_normal, OVERBOUNCE);
	// if we didn't hit anything, we can't be on the ground
	if (trace_fraction >= 0.99)
	{
		SetOnGround(FALSE);
	}
	// if the ground is too steep, we can't stand on it
	else if (!(self.moveFlags & MF_REVERSEGRAV) && trace_plane_normal.z < 0.7)
	{
		SetOnGround(FALSE);
	}
	else if (self.moveFlags & MF_REVERSEGRAV && trace_plane_normal.z > -0.7)
	{
		SetOnGround(FALSE);
	}
	// if we *did* hit the ground but still have some vertical velocity,
	// make us not on the ground (rampsliding)
	else if ((clippedVelocity.z > 250 || clippedVelocity.z < -250) &&
	         !(input_buttons & BUTTON_MOD1))
	{
		self.velocity = clippedVelocity;
		self.moveFlags |= MF_RAMPSLIDE;
		SetOnGround(FALSE);
	}
	else
	{
		SetOnGround(TRUE);
	}
}

float CanStand(float normal)
{
	if (self.moveFlags & MF_REVERSEGRAV && normal > -0.7)
	{
		return FALSE;
	}
	else if (!(self.moveFlags & MF_REVERSEGRAV) && normal < 0.7)
	{
		return FALSE;
	}
	else
	{
		return TRUE;
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
	float speed, newSpeed, control, drop;

	newVel = self.velocity;
	if (self.movetype != MOVETYPE_NOCLIP)
	{
		newVel.z = 0;
	}

	speed = vlen(newVel);

	if (speed < 1)
	{
		self.velocity.x = 0;
		self.velocity.y = 0;
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

	drop = control * friction * frametime;
	newSpeed = speed - drop;

	if (newSpeed < 0)
	{
		newSpeed = 0;
	}

	newSpeed /= speed;

	self.velocity = self.velocity * newSpeed;
}

void CutHookVelocity()
{
	vector direction;
	float distance;
	float difference;

	if (self.currentHook == world)
	{
		return;
	}
#ifdef SSQC
	self.currentHook.SendFlags |= FL_OWNERORIGIN;
#endif
	if (self.grappled == FALSE)
	{
		return;
	}

	direction = self.origin - self.currentHook.origin;
	distance = vlen(direction);
	difference = distance - self.hookDistance;

	if (distance > self.hookDistance && DotProduct(self.velocity, direction) > 0)
	{
		self.velocity -= Projection(self.velocity, direction);
		if (difference > 10)
		{
			self.velocity -= difference * normalize(direction);
		}
	}
	
	float pullSpeed = cvar("sv_gravity") * frametime * 2;
	if (input_buttons & BUTTON_MOD2 && vlen(Projection(self.velocity, direction)) < 1000 &&
		self.hookDistance > 128)
	{
		self.velocity -= pullSpeed * normalize(direction);
		self.hookDistance = vlen(self.origin - self.currentHook.origin) - pullSpeed;
	}
}

#ifdef SSQC
void DoEffects()
{
	if (self.moveFlags & MF_GRINDING)
	{
		if (self.moveFlags & MF_REVERSEGRAV)
		{
			particle4(self.origin + '0 0 40', 12, 192, 0, 10);
		}
		else
		{
			particle4(self.origin - '0 0 40', 12, 192, 0, 10);
		}
	}
	else if (self.grindTime > 0 && !IsOnGround(self))
	{
		sound(self, CHAN_VOICE, "null.wav", 1, ATTN_NORM);
		self.grindTime = -1;
	}
}
#endif

void PlayerMove()
{
	float oldFrametime = frametime;
	float pmoveTime = cvar("sv_pmovetime");
	float remainingTime = time - self.lastMoveTime;
	float oldFlags = self.moveFlags;

	if (pmoveTime <= 0)
	{
		pmoveTime = 0.008;
	}

	while (remainingTime > pmoveTime)
	{
		frametime = pmoveTime;
		remainingTime -= pmoveTime;
		self.lastMoveTime += pmoveTime;

		GroundTrace();
		WallTrace();
		CheckJumpReleased();

		if (self.moveFlags & MF_REVERSEGRAV)
		{
			self.view_ofs = -PLAYER_VIEW_STAND;
		}
		else
		{
			self.view_ofs = PLAYER_VIEW_STAND;
		}

		if (self.movetype == MOVETYPE_NONE)
		{
		}
		else if (self.movetype == MOVETYPE_NOCLIP)
		{
			NoclipMove();
		}
		else if (cvar("sv_fly") > 0)
		{
			FlyMove();
		}
		else if (IsOnGround(self))
		{
			GroundMove();
		}
		else if (IsOnWall(self))
		{
			WallMove();
		}
		else
		{
			AirMove();
		}

		touchtriggers();
	}

#ifdef SSQC
	DoEffects();
#endif

	frametime = oldFrametime;
}
