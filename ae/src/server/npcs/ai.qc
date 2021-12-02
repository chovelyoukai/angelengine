#include "ai.qh"

float CanMoveTo(vector direction, float minDist, float maxDist)
{
	vector start = self.origin;
	vector end = self.origin + (direction * maxDist);
	float traveled = 0;
	float remaining = maxDist;
	int i;

	for (i = 0; i < 10; i++)
	{
		tracebox(start, self.mins, self.maxs, end, MOVE_NORMAL, self);
		traveled = trace_fraction * remaining;
		remaining -= traveled;

		if (trace_fraction > 0.99 || trace_plane_normal.z < 0.7)
		{
			return traveled;
		}
		else
		{
			direction = normalize(ClipVector(direction, trace_plane_normal, 1.001));
			start = trace_endpos;
			end = start + (direction * remaining);
		}
	}

	return traveled;
}

float NewMoveDir()
{
	vector testDir = '0 0 0';
	float minDist = cvar("sv_npcspeed") * 0.5;
	float maxDist = minDist + (cvar("sv_npcspeed") * random() * 9);
	float distance;

	for (int i = 0; i < 10; i++)
	{
		testDir.x = random() - 0.5;
		testDir.y = random() - 0.5;
		testDir = normalize(testDir);

		distance = CanMoveTo(testDir, minDist, maxDist);
		if (distance >= minDist)
		{
			self.movedir = testDir;
			self.moveDist = distance;
			self.moveTime = time + distance / cvar("sv_npcspeed");
			return TRUE;
		}
	}
	
	return FALSE;
}
