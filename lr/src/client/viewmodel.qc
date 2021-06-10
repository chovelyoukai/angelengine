#include "viewmodel.qh"

void InitializeViewmodel()
{
    viewmodel = spawn();
    viewmodel.drawmask |= MASK_VIEWMODEL | MASK_ENGINE;
    viewmodel.renderflags |= RF_VIEWMODEL;
    viewmodel.solid = SOLID_NOT;
    viewmodel.weaponType = WEP_LAST;
    viewmodel.fireTimeout = 0;
}

void UpdateViewmodel()
{
    float weapon = getstatf(STAT_WEAPON);

    if (weapon != viewmodel.weaponType)
    {
        SetViewmodel(viewmodels[weapon]);
        viewmodel.fireTimeout = 0;
        viewmodel.weaponType = weapon;
    }

    if (input_buttons & BUTTON_ATTACK && viewmodel.fireTimeout <= time)
    {
        viewmodel.frame = 1;
        viewmodel.frame1time = 0;
        viewmodel.fireTimeout = time + fireTimes[weapon];
    }
    else if (viewmodel.fireTimeout <= time)
    {
        viewmodel.frame = 0;
        viewmodel.frame1time = 0;
    }

    viewmodel.frame1time += frametime;
}

void SetViewmodel(string modelname)
{
    setmodel(viewmodel, modelname);
    viewmodel.frame1time = 0;
    viewmodel.frame2time = time;
    viewmodel.frame = 0;
    viewmodel.lerpfrac = 0.5;
}
