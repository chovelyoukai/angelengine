#include "main.qh"
#include "../shared/math.qh"
#include "../shared/pmove/pmove.qh"

void CSQC_Init(float apiVer, string engineName, float engineVer)
{
	drawfont = loadfont("", autocvar(menu_font, "LiberationMono-Regular.ttf"),
		"12", -1, 0, 0);
}

void CSQC_UpdateView(float width, float height, float menuShown)
{
	entity oldSelf;
	string speedString;
	float speedWidth;
	vector speedPos;

	clearscene();

	setviewprop(VF_DRAWENGINESBAR, 0);
	setviewprop(VF_DRAWCROSSHAIR, 1);

	addentities((intermission ? 0 : MASK_VIEWMODEL) | MASK_ENGINE);

	if (player)
	{
		oldSelf = self;
		self = player;
		PlayerMove();
		setviewprop(VF_ORIGIN, player.origin + PLAYER_VIEW_STAND);
		self = oldSelf;
	}

	renderscene();

	speedString = ftos(rint(vlen2d(player.velocity)));
	speedString = strcat("H: ", speedString, " UPS");
	speedWidth = stringwidth(speedString, TRUE);
	speedPos.x = (width - speedWidth * 12) / 2;
	speedPos.y = height / 2 + height / 32;
	drawstring(speedPos, speedString, '12 12 0', '1 1 1', 1.0, 1);

	speedString = ftos(rint(vlen(player.velocity)));
	speedString = strcat("A: ", speedString, " UPS");
	speedWidth = stringwidth(speedString, TRUE);
	speedPos.x = (width - speedWidth * 12) / 2;
	speedPos.y += 14;
	drawstring(speedPos, speedString, '12 12 0', '1 1 1', 1.0, 1);
}
