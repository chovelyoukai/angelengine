#include "menu.qh"
#include "../shared/draw/draw.qh"

void m_close()
{
	menuActive = FALSE;
	setcursormode(FALSE);
	setkeydest(0);
}

void m_open()
{
	menuActive = TRUE;
	setcursormode(TRUE);
	setkeydest(2);
}

void m_init()
{
	menuActive = FALSE;
	RootMenu();
	setwindowcaption("Angel Engine");
	drawfont = loadfont("", autocvar(menu_font, "LiberationMono-Regular.ttf"),
	                    "12 16 24", -1, 0, 0);
	cursorPosition = 0;
}

void m_shutdown()
{
}

void m_draw(vector screensize)
{
	vector size;

	if (!menuActive)
	{
		return;
	}

	size = getproperty(VF_SCREENPSIZE);
	size /= cvar("vid_conautoscale");
	SetRealSize(size);

	currentMenu_draw();
}

void m_drawloading(vector screensize, float opaque)
{
}

void m_toggle(float wantmode)
{
	if (menuActive)
	{
		m_close();
	}
	else
	{
		m_open();
	}
}

void Menu_RendererRestarted(string rendererDescription)
{
}

float Menu_InputEvent(float evtype, float scanx, float chary, float devid)
{
	switch (evtype)
	{
		case IE_KEYDOWN:
			if (scanx == K_ESCAPE)
			{
				m_toggle(1);
			}
			else
			{
				HandleKeypress(scanx);
			}
			break;
	}

	return 0;
}
