#include "main.qh"

void CSQC_Init(float apiVer, string engineName, float engineVer)
{
	precache_model("models/player.iqm");
    precache_model("models/objects/health.iqm");
    precache_model("models/weapons/chovel.iqm");
    precache_model("models/weapons/hammer.iqm");
	precache_model("models/weapons/rocket.iqm");
	precache_model("models/weapons/rocketlauncher.iqm");
    precache_model("models/weapons/shotgun.iqm");
    precache_sound("player/step.wav");
    precache_sound("ui/hit.wav");
    precache_sound("ui/kill.wav");
    precache_sound("world/pickup_health.wav");
    precache_sound("world/pickup_weapon.wav");
    precache_sound("world/respawn_health.wav");
    precache_sound("world/respawn_weapon.wav");
    precache_sound("weapons/chovel_fire.wav");
    precache_sound("weapons/chovel_hit.wav");
    precache_sound("weapons/hammer_fire.wav");
    precache_sound("weapons/hammer_hit.ogg");
    precache_sound("weapons/rocket_fire.ogg");
    precache_sound("weapons/shotgun_fire.ogg");
    precache_sound("weapons/r_exp3.wav");
    
    drawfont = loadfont("", autocvar(menu_font, "LiberationMono-Regular.ttf"),
        "12", -1, 0, 0);
    InitializeViewmodel();
}

void InitializePlayer()
{
    SetViewmodel("");

    for (float i = 0; i < MAX_WEAPONS; i++)
    {
        if (player.weapons[i] != world)
        {
            remove(player.weapons[i]);
        }

        player.weapons[i] = world;
    }

    player.weaponsHeld = 0;
    player.currentWeapon = world;
    player.moveFlags = 0;
}

void CSQC_UpdateView(float width, float height, float menuShown)
{
    entity oldSelf;
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

    oldSelf = self;
    self = player;
    if (input_impulse >= 1 && input_impulse < MAX_WEAPONS)
    {
        SwitchWeapons(input_impulse);
    }
    CheckWeapons();
    self = oldSelf;
}
