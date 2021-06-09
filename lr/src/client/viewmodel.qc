#include "viewmodel.qh"

void InitializeViewmodel()
{
    viewmodel = spawn();
    viewmodel.drawmask |= MASK_VIEWMODEL | MASK_ENGINE;
    viewmodel.renderflags |= RF_VIEWMODEL;
    viewmodel.solid = SOLID_NOT;
}

void UpdateViewmodel(float weaponType)
{
    switch (weaponType)
    {
        case WEP_ROCKETLAUNCHER:
            setmodel(viewmodel, "models/weapon_views/v_rocket.mdl");
            break;
    }
}
