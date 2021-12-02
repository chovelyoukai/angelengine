#include "npc_test.qh"

void npc_test()
{
	setmodel(self, "models/player.iqm");
	setsize(self, PLAYER_MIN_STAND, PLAYER_MAX_STAND);
	self.velocity = '0 0 0';
	self.solid = SOLID_NOT;
	self.moveDist = 0;
	self.nextthink = 1 + time + random() * 5;
	self.think = npc_testIdle;
	tracebox(self.origin + '0 0 80', self.mins, self.maxs, self.origin, MOVE_NORMAL, self);
	setorigin(self, trace_endpos);
	self.gravity = 0;
}

void npc_testIdle()
{
	if (NewMoveDir() == TRUE)
	{
		self.nextthink = time + frametime;
		self.think = npc_testWalk;
	}
	else
	{
		self.nextthink = time + random() * 1;
		self.think = npc_testIdle;
	}
}

void npc_testWalk()
{
	GroundTrace();
	if (!IsOnGround(self))
	{
		self.gravity += cvar("sv_gravity") * frametime;
	}
	else
	{
		self.gravity = 0;
	}
	self.velocity = normalize(self.movedir) * cvar("sv_npcspeed");
	self.velocity.z -= self.gravity;
	self.angles = vectoangles(self.velocity);
	self.angles.x = 0;
	SlideMove();
	self.movedir = normalize(self.velocity);
	self.velocity = '0 0 0';

	if (time > self.moveTime)
	{
		self.nextthink = 1 + time + random() * 5;
		self.think = npc_testIdle;
	}
	else
	{
		self.nextthink = time + frametime;
		self.think = npc_testWalk;
	}
}
