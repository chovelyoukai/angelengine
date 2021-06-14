#include "damage.qh"

void DrawDamageIndicator(float width, float height)
{
    vector playerOrg = player.origin;
    vector sizeMin, sizeMax;
    float x = width / 2;
    float y = height / 2;
    float viewAngle;
    float drawAngle;
    float alpha;
    entity damager;

    damager = world;
    damager = nextent(damager);

    while (damager)
    {
        if (damager.classname == "damager")
        {
            viewAngle = TWOPI360 * view_angles.y;

            // reorient the angle in the world
            viewAngle += ONEHALFPI;
            // correct for quadrant IV
            if (viewAngle < 0)
            {
                viewAngle += 4 * ONEHALFPI;
            }

            drawAngle = atan((-damager.origin_y + playerOrg_y)
                    / (-damager.origin_x + playerOrg_x));

            // reorient the angle in the world
            drawAngle += ONEHALFPI;
            // correct for over lower quadrants 
            if (damager.origin_x < playerOrg_x)
            {
                drawAngle += 2 * ONEHALFPI;
            }

            drawAngle = viewAngle - drawAngle;

            alpha = damager.timeLeft - time; 

            sizeMin_x = -damager.health;
            sizeMin_y = -damager.health;
            sizeMax_x = damager.health;
            sizeMax_y = damager.health;

            drawrotpic([x, y], sizeMin, sizeMax, "gfx/hurt.png",
                '1 1 1', alpha, drawAngle / TWOPI360);
        }
        damager = nextent(damager);
    }
}
