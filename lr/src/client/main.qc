#include "main.qh"

void CSQC_Init(float apiVer, string engineName, float engineVer)
{
    drawfont = loadfont("", autocvar(menu_font, "LiberationMono-Regular.ttf"),
        "12", -1, 0, 0);
    InitializeViewmodel();
}

void CSQC_UpdateView(float width, float height, float menuShown)
{
    clearscene();

    setviewprop(VF_DRAWENGINESBAR, 0);
    setviewprop(VF_DRAWCROSSHAIR, 1);

    addentities((intermission ? 0 : MASK_VIEWMODEL) | MASK_ENGINE);

    Predict();

    renderscene();

    if (player)
    {
        DrawHud(width, height);
    }
}
