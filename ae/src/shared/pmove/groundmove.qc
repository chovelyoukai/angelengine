#include "pmove.qh"

void JumpSpeedReduce()
{
	float oldZVel;
	float maxSpeed;

	if (cvar("sv_skate") > 0)
	{
		if (self.grindTime > 0)
		{
			return;
		}
		maxSpeed = cvar("sv_maxskatespeed");
	}
	else
	{
		maxSpeed = cvar("sv_maxburdenedspeed");
	}

	if (vlen2d(self.velocity) > maxSpeed)
	{
	oldZVel = self.velocity.z;
	self.velocity.z = 0;
	self.velocity = normalize(self.velocity);
	self.velocity *= maxSpeed;
	self.velocity.z = oldZVel;
	}
}

void CheckJumpReleased()
{
	float umove = input_movevalues.z;

	if (umove <= 0)
	{
		self.moveFlags |= MF_JUMPRELEASED;
	}
	else if (!IsOnGround(self))
	{
		self.moveFlags &= ~MF_JUMPRELEASED;
	}
}

float CanBhop()
{
	if (cvar("sv_rockethop") > 0)
	{
		return TRUE;
	}

	if (self.moveFlags & MF_GRINDING)
	{
		return TRUE;
	}

	if (self.moveFlags & MF_BURDENED)
	{
		return FALSE;
	}

	return TRUE;
}

float CheckJump()
{
	float umove = input_movevalues.z;
	
	if (umove <= 0)
	{
		self.moveFlags |= MF_JUMPRELEASED;
		return FALSE;
	}

	if (!CanBhop())
	{
		if((self.moveFlags & MF_JUMPRELEASED) == 0)
		{
			return FALSE;
		}
		else 
		{
			JumpSpeedReduce();
		}
	}
	self.moveFlags &= ~MF_JUMPRELEASED;

	#ifdef SSQC
	#ifdef AFPS
	if (self.moveFlags & MF_RAMPSLIDE)
	{
		self.moveFlags &= ~MF_CANCRIT;
		sound(self, CHAN_AUTO, "player/step.wav", 0.3, ATTN_NORM);
	}
	if (self.moveFlags & MF_GRINDING)
	{
		self.moveFlags |= MF_CANCRIT;
	}
	#endif
	#endif
	
	if (self.moveFlags & MF_REVERSEGRAV)
	{
		self.velocity.z -= 270;
		if (self.velocity.z > -270)
		{
			self.velocity.z = -270;
		}

		#ifdef SSQC
		#ifdef AFPS
		if (self.velocity.z < -300)
		{
			self.moveFlags |= MF_CANCRIT;
		}
		if (self.moveFlags & MF_RAMPSLIDE && self.velocity.z > 180)
		{
			self.moveFlags |= MF_CANCRIT;
		}
		#endif
		#endif
	}
	else
	{
		self.velocity.z += 270;
		if (self.velocity.z < 270)
		{
			self.velocity.z = 270;
		}

		#ifdef SSQC
		#ifdef AFPS
		if (self.velocity.z > 300)
		{
			self.moveFlags |= MF_CANCRIT;
		}
		if (self.moveFlags & MF_RAMPSLIDE && self.velocity.z < -180)
		{
			self.moveFlags |= MF_CANCRIT;
		}
		#endif
		#endif
	}
	return TRUE;
}

void GroundMove()
{
	float fmove, smove;
	float friction, accel, maxSpeed;
	float wishSpeed;
	float speed;
	vector wishDir;

	if (CheckJump())
	{
		AirMove();
		return;
	}

	self.accelType = ACCEL_GROUND;

	fmove = input_movevalues.x;
	smove = input_movevalues.y;

	accel = cvar("sv_accelerate");
	maxSpeed = cvar("sv_maxspeed");

	if (self.moveFlags & MF_SKATE)
	{
		if (CheckGrind())
		{
			self.moveFlags |= MF_GRINDING;
		}
		else
		{
			self.moveFlags &= ~MF_GRINDING;
		}
	}
	else
	{
		self.moveFlags &= ~MF_GRINDING;
	}

	if (self.moveFlags & MF_GRINDING)
	{
		maxSpeed *= 1.7;
		friction = 0;
		smove = 0;
		if (fmove >= 0)
		{
			fmove = maxSpeed;
		}
		else
		{
			fmove = 0;
		}
		makevectors(vectoangles(self.velocity));
	}
	else
	{
		friction = cvar("sv_friction");
#ifdef SSQC
		makevectors(self.v_angle);
#else
		makevectors(view_angles);
#endif
	}

	v_forward.z = 0;
	v_right.z = 0;

	v_forward = ClipVector(v_forward, self.groundNormal, OVERBOUNCE);
	v_right = ClipVector(v_right, self.groundNormal, OVERBOUNCE);
	v_forward = normalize(v_forward);
	v_right = normalize(v_right);

	if (!((self.moveFlags & MF_SKATE) && (input_buttons & BUTTON_MOD1) && vlen(self.velocity) < 700))
	{
		Friction(friction, cvar("sv_stopspeed"));
	}

	if (self.moveFlags & MF_REVERSEGRAV)
	{
		smove *= -1;
	}

	wishDir = v_forward * fmove + v_right * smove;
	wishSpeed = vlen(wishDir);
	wishDir = normalize(wishDir);

	if (self.moveFlags & MF_GRINDING)
	{
		maxSpeed *= 1.2;
	}
	else if (self.moveFlags & MF_BURDENED)
	{
		maxSpeed = cvar("sv_maxburdenedspeed");
	}

	Accelerate(wishDir, wishSpeed, accel, maxSpeed);

	speed = vlen(self.velocity);
	self.velocity = ClipVelocity(self.groundNormal, OVERBOUNCE);
	self.velocity = normalize(self.velocity);
	self.velocity *= speed;

	if (self.moveFlags & MF_BURDENED && speed > maxSpeed)
	{
		self.velocity = maxSpeed * normalize(self.velocity);
	}
	if (self.moveFlags & MF_GRINDING)
	{
		ApplyGravity();
	}

	StepSlideMove();

	if (self.moveFlags & MF_GRINDING)
	{
		StickToGround();
	}

#ifdef SSQC
	if (!(self.moveFlags & MF_GRINDING))
	{
		float stepTimeout;
		float pitch;
		speed = vlen(self.velocity);
		if (speed < 1)
		{
			return;
		}
		else if (speed >= cvar("sv_maxspeed"))
		{
			stepTimeout = 0.4;
		}
		else
		{
			stepTimeout = 1.4 - (vlen(self.velocity) / cvar("sv_maxspeed"));
		}

		if (time - self.stepTime > stepTimeout)
		{
			pitch = 100 + (10 * random()) - 5;
			self.stepTime = time;
			sound(self, CHAN_AUTO, "player/step.wav", 0.3, ATTN_NORM, pitch);
		}
	}
#endif
}
