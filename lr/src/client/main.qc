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
        for (inputFrame = servercommandframe + 1;
            inputFrame < clientcommandframe; inputFrame += 1)
        {
            if(!getinputstate(inputFrame))
            {
                continue;
            }

            oldSelf = self;
            self = player;
            PlayerMove();
            self = oldSelf;
        }

        if (vlen(player.origin - player.correctOrigin) > 0.1)
        {
            setorigin(player, (player.origin + player.correctOrigin) / 2);
        }
        if (vlen(player.velocity - player.correctVelocity) > 0.1)
        {
            player.velocity = (player.velocity + player.correctVelocity) / 2;
        }
        setviewprop(VF_ORIGIN, player.origin + PLAYER_VIEW_STAND);
    }

    renderscene();

    if (player)
    {
        DrawMeters(width, height);
    }
}
