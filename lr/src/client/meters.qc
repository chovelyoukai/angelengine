#include "meters.qh"

void DrawMeters(float width, float height)
{
	string speedString, speedString2d;
	float speedWidth, speedWidth2d;
	vector speedPos, speedPos2d, accelPos;
	vector accelSize;
	vector accelColor;
    float accel2D, accel3D, accelReal;

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

	accelColor = ACCEL_GROUND_COLOR;

    accel2D = UpdateAccel2D(width);
    accel3D = UpdateAccel(width);
    accelReal = 0;

	switch (player.accelType)
	{
		case ACCEL_GROUND:
			accelColor = ACCEL_GROUND_COLOR;
            accelReal = accel2D;
			break;
		case ACCEL_WALL:
			accelColor = ACCEL_WALL_COLOR;
            accelReal = accel3D;
			break;
		case ACCEL_QW:
			accelColor = ACCEL_QW_COLOR;
            accelReal = accel2D;
			break;
		case ACCEL_Q3:
			accelColor = ACCEL_Q3_COLOR;
            accelReal = accel2D;
			break;
		case ACCEL_NOCLIP:
			accelColor = ACCEL_NOCLIP_COLOR;
            accelReal = accel3D;
			break;
        case ACCEL_FLY:
            accelColor = ACCEL_FLY_COLOR;
            accelReal = accel3D;
            break;
		default:
			accelColor = ACCEL_GROUND_COLOR;
            accelReal = accel3D;
	}

	accelSize.x = accelReal;
	accelSize.y = 12;
	accelPos.x = (width - accelReal) / 2;
	accelPos.y = height / 2 + height / 32 + 28;
	drawfill(accelPos, accelSize, accelColor, 1.0, DRAWFLAG_NORMAL);
}

float UpdateAccel2D(float width)
{
    float accelDamp = cvar("cl_acceldamp");
    float diffSpeed;

    oldAccel2D = ((1 - accelDamp) * (vlen2d(player.velocity) - oldSpeed2D)) +
        (accelDamp * oldAccel2D);

    if (vlen2d(player.velocity) < oldSpeed2D)
    {
        diffSpeed = 0;
    }
    diffSpeed = rint(oldAccel2D * 15);
    if (diffSpeed > width / 10)
    {
        diffSpeed = width / 10;
    }

    oldSpeed2D = vlen2d(player.velocity);

    return diffSpeed;
}

float UpdateAccel(float width)
{
    float accelDamp = cvar("cl_acceldamp");
    float diffSpeed;

    oldAccel = ((1 - accelDamp) * (vlen(player.velocity) - oldSpeed)) +
        (accelDamp * oldAccel);

    if (vlen(player.velocity) < oldSpeed)
    {
        diffSpeed = 0;
    }
    diffSpeed = rint(oldAccel * 15);
    if (diffSpeed > width / 10)
    {
        diffSpeed = width / 10;
    }

    oldSpeed = vlen(player.velocity);

    return diffSpeed;
}
