#include "meters.qh"

void DrawMeters(float width, float height)
{
	string speedString, speedString2d;
	float speedWidth, speedWidth2d, diffSpeed;
	float accelDamp = cvar("cl_acceldamp");
	vector speedPos, speedPos2d, accelPos;
	vector accelSize;

	speedString2d = ftos(rint(vlen2d(player.velocity)));
	speedString2d = strcat("H: ", speedString2d, " UPS");
	speedWidth2d = stringwidth(speedString2d, TRUE);
	speedPos2d.x = (width - speedWidth2d * 12) / 2;
	speedPos2d.y = height / 2 + height / 32;
	
	speedString = ftos(rint(vlen(player.velocity)));
	speedString = strcat("A: ", speedString, " UPS");
	speedWidth = stringwidth(speedString, TRUE);
	speedPos.x = (width - speedWidth * 12) / 2;
	speedPos.y = height / 2 + height / 32 + 14;

	drawstring(speedPos2d, speedString2d, '12 12 0', '1 1 1', 1.0, 1);
	drawstring(speedPos, speedString, '12 12 0', '1 1 1', 1.0, 1);

	oldAccel = ((1 - accelDamp) * (vlen2d(player.velocity) - oldSpeed)) +
		(accelDamp * oldAccel);
	diffSpeed = fabs(rint(oldAccel * 10));
	if (diffSpeed < 0)
	{
		diffSpeed = 0;
	}
	oldSpeed = vlen2d(player.velocity);

	accelSize.x = diffSpeed;
	accelSize.y = 12;
	accelPos.x = (width - diffSpeed) / 2;
	accelPos.y = height / 2 + height / 32 + 28;
	drawfill(accelPos, accelSize, '1 1 1', 1.0, 1);
}
