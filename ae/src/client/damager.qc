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

            drawAngle = atan((-damager.origin.y) / (-damager.origin.x));

            // reorient the angle in the world
            drawAngle += ONEHALFPI;
            // correct for over lower quadrants 
            if (damager.origin.x > 0)
            {
                drawAngle += 2 * ONEHALFPI;
            }

            drawAngle = viewAngle - drawAngle;

            alpha = damager.nextthink - time; 

            sizeMin.x = -damager.health;
            sizeMin.y = -damager.health;
            sizeMax.x = damager.health;
            sizeMax.y = damager.health;

            if (vlen(sizeMax) < 40)
            {
                sizeMin = 40 * normalize(sizeMin);
                sizeMax = 40 * normalize(sizeMax);
            }

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
