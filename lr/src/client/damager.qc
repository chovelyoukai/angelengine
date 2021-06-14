#include "damager.qh"

void DrawDamageIndicators(float width, float height)
{
    vector playerOrg = player.origin;
    vector sizeMin, sizeMax;
    float x = width / 2;
    float y = height / 2;
    float viewAngle;
    float drawAngle;
    float alpha;
    entity damager;
    string image;

    damager = world;
    damager = nextent(damager);

    while (damager)
    {
        if (damager.classname == "damager")
        {
            viewAngle = TWOPIOVER360 * view_angles.y;

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

            if (damager.knockback)
            {
                image = "gfx/indicator_knockback.png";
            }
            else
            {
                image = "gfx/indicator_damage.png";
            }
            drawrotpic([x, y], sizeMin, sizeMax, image, '1 1 1', alpha,
                drawAngle / TWOPIOVER360);
        }
        damager = nextent(damager);
    }
}
