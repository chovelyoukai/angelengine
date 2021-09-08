#include "grapples.qh"

void DrawLine(vector start, vector end)
{
	R_BeginPolygon("colors/grapplerope.png");
	R_PolygonVertex(start, '0 0 0', '1 1 1', 1);
	R_PolygonVertex(end, '0 0 0', '1 1 1', 1);
	R_EndPolygonRibbon(3, '0 0 0');
}

void DrawGrappleLines()
{
	entity hook;
	vector end;

	hook = world;
	hook = nextent(world);

	while (hook)
	{
		if (hook.projectileType == PROJ_HOOK)
		{
			if (hook == player.currentHook)
			{
				makevectors(view_angles);
				end = player.origin + player.view_ofs + (20 * v_forward);
				if (player.moveFlags & MF_REVERSEGRAV)
				{
					end += 10 * v_up;
				}
				else
				{
					end -= 10 * v_up;
				}
			}
			else
			{
				end = hook.ownerOrigin;
			}
			DrawLine(hook.origin, end);
		}

		hook = nextent(hook);
	}
}
