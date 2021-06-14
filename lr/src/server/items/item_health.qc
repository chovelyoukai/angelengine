#include "item_health.qh"

void item_health()
{
    setmodel(self, "models/objects/health.iqm");
    setsize(self, '-16 -16 -16', '16 16 16');
    self.solid = SOLID_TRIGGER;
    self.enabled = TRUE;
    self.think = item_healthThink;
    self.touch = item_healthTouch;
}

void item_healthTouch()
{
    if (other.classname == "player" && self.enabled)
    {
        other.health += 5;
        if (other.health > 200)
        {
            other.health = 200;
        }
        other.nextHealthTick = time + 1;

        self.enabled = FALSE;
        setmodel(self, "");
        self.nextthink = time + ITEM_HEALTH_RESPAWN;
        sound(self, CHAN_AUTO, "world/pickup_health.wav", 1, ATTN_NORM);
    }
}

void item_healthThink()
{
    self.enabled = TRUE;
    setmodel(self, "models/objects/health.iqm");
    setsize(self, '-16 -16 -16', '16 16 16');
    sound(self, CHAN_AUTO, "world/respawn_health.wav", 0.1, ATTN_NORM);
}
