#include "hud.qh"

void DrawHud(float width, float height)
{
    if (cvar("cl_drawhud") > 0)
    {
        DrawMeters(width, height);
        DrawKeys(width, height);
        DrawHealth(width, height);
        DrawDamageIndicators(width, height);
    }
}

void DrawMeters(float width, float height)
{
    string speedString, speedString2d;
    float speedWidth, speedWidth2d;
    float cursor = 0; 
    vector speedPos, speedPos2d, accelPos;
    vector accelSize;
    vector accelColor;
    float accel2D, accel3D, accelReal;
    float health = getstatf(STAT_HEALTH);

    if (cvar("cl_drawhspeed") > 0)
    {
        speedString2d = ftos(rint(vlen2d(player.velocity)));
        speedString2d = strcat("H: ", speedString2d, " UPS");
        speedWidth2d = stringwidth(speedString2d, TRUE, '12 12');
        speedPos2d.x = (width - speedWidth2d) / 2;
        speedPos2d.y = height / 2 + height / 32 + cursor;
        cursor += 14;
        drawstring(speedPos2d, speedString2d, '12 12', '1 1 1', 1.0, 1);
    }

    if (cvar("cl_drawaspeed") > 0)
    {
        speedString = ftos(rint(vlen(player.velocity)));
        speedString = strcat("A: ", speedString, " UPS");
        speedWidth = stringwidth(speedString, TRUE, '12 12');
        speedPos.x = (width - speedWidth) / 2;
        speedPos.y = height / 2 + height / 32 + cursor;
        cursor += 14;
        drawstring(speedPos, speedString, '12 12', '1 1 1', 1.0, 1);
    }

    if (cvar("cl_drawaccel") > 0)
    {
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
        accelPos.y = height / 2 + height / 32 + cursor;
        drawfill(accelPos, accelSize, accelColor, 1.0, DRAWFLAG_NORMAL);
    }
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

void DrawHealth(float width, float height)
{
    float health = rint(getstatf(STAT_HEALTH));
    vector healthPos, healthSize, healthColor;
    string healthString = ftos(health);
    healthString = strcat("Health: ", healthString);

    healthPos.x = 3 * (width / 4);
    healthPos.y = 3 * (height / 4);

    drawstring(healthPos, healthString, '12 12', '1 1 1', 1.0, 0);

    healthPos.y += 14;
    healthSize.y = 12;
    healthSize.x = health * (width / 1000);
    if (health > 100)
    {
        healthSize.x = 100 * (width / 1000);
    }
    healthColor = '0.8 0 0';

    drawfill(healthPos, healthSize, healthColor, 1.0, DRAWFLAG_NORMAL);

    if (health > 100)
    {
        health -= 100;
        healthSize.x = health * (width / 1000);
        healthColor = '0 1 0';
        healthPos.x += 0.005 * width;
        healthPos.y += 0.005 * width;
        drawfill(healthPos, healthSize, healthColor, 1.0, DRAWFLAG_NORMAL);
    }
}

void DrawKeys(float width, float height)
{
    float fmove, smove, umove;
    vector keysPos; 
    string topText, bottomText;
    string left, right, forward, backward, jump, attack;

    if (cvar("cl_drawkeys") == 0)
    {
        return;
    }

    left = right = forward = backward = jump = attack = " ";

    fmove = input_movevalues.x;
    smove = input_movevalues.y;
    umove = input_movevalues.z;

    if (fmove > 10)
    {
        forward = "^";
    }
    else if (fmove < -10)
    {
        backward = "v";
    }
    if (smove > 10)
    {
        right = ">";
    }
    else if (smove < -10)
    {
        left = "<";
    }
    if (umove > 10)
    {
        jump = "J";
    }
    if (input_buttons & BUTTON_ATTACK)
    {
        attack = "A";
    }

    topText = strcat(jump, " ", forward, " ", attack);
    bottomText = strcat(left, " ", backward, " ", right);

    keysPos.x = cvar("cl_drawkeys_x");
    keysPos.y = cvar("cl_drawkeys_y");

    keysPos.x = keysPos.x * (width - stringwidth(topText, TRUE, '12 12'));
    keysPos.y = keysPos.y * height;
    drawstring(keysPos, topText, '12 12', '1 1 1', 1.0, 1);
    keysPos.y += 14;
    drawstring(keysPos, bottomText, '12 12', '1 1 1', 1.0, 1);
}
