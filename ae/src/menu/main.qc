#include "menu.qh"

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
    setwindowcaption("Angel Engine");
}

void m_shutdown()
{
}

void m_draw(vector screensize)
{   
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
    }

    return 0;
}
