#include "main.qh"

void CSQC_Init(float apiVer, string engineName, float engineVer)
{
	precache_model("models/player.iqm");
    precache_model("models/objects/health.iqm");
    precache_model("models/weapons/chovel.iqm");
    precache_model("models/weapons/shotgun.iqm");
	precache_model("models/weapons/rocket.iqm");
	precache_model("models/weapons/rocketlauncher.iqm");
    precache_sound("player/step.wav");
    precache_sound("world/pickup_health.wav");
    precache_sound("world/pickup_weapon.wav");
    precache_sound("world/respawn_health.wav");
    precache_sound("world/respawn_weapon.wav");
    precache_sound("weapons/chovel_fire.wav");
    precache_sound("weapons/chovel_hit.wav");
    precache_sound("weapons/rocket_fire.ogg");
    precache_sound("weapons/shotgun_fire.ogg");
    precache_sound("weapons/r_exp3.wav");
    
    drawfont = loadfont("", autocvar(menu_font, "LiberationMono-Regular.ttf"),
        "12", -1, 0, 0);
    InitializeViewmodel();
}

void CSQC_UpdateView(float width, float height, float menuShown)
{
    clearscene();

    setviewprop(VF_DRAWENGINESBAR, 0);
    if (cvar("cl_drawhud") > 0)
    {
        setviewprop(VF_DRAWCROSSHAIR, 1);
    }
    else
    {
        setviewprop(VF_DRAWCROSSHAIR, 0);
    }

    addentities((intermission ? 0 : MASK_VIEWMODEL) | MASK_ENGINE);

    Predict();

    renderscene();

    if (player)
    {
        if (cvar("cl_predict") > 0)
        {
            player.customphysics = PlayerMove;
        }
        else
        {
            player.customphysics = DoNothing;
        }
        DrawHud(width, height);
    }
}
