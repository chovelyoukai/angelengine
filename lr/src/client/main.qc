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
	float inputFrame;

	clearscene();

	setviewprop(VF_DRAWENGINESBAR, 0);
	setviewprop(VF_DRAWCROSSHAIR, 1);

	addentities((intermission ? 0 : MASK_VIEWMODEL) | MASK_ENGINE);

	if (player)
	{

		inputFrame = clientcommandframe;

		getinputstate(inputFrame);

		oldSelf = self;
		self = player;
		PlayerMove();
		self = oldSelf;

		setviewprop(VF_ORIGIN, player.origin + PLAYER_VIEW_STAND);
	}

	renderscene();

	if (player)
	{
		DrawMeters(width, height);
	}
}
