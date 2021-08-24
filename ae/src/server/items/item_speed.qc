#include "item_speed.qh"

void item_speed()
{
    setmodel(self, "models/objects/speed.iqm");
    setsize(self, '-16 -16 -16', '16 16 16');
    self.frame = 0;
    self.solid = SOLID_TRIGGER;
    self.enabled = TRUE;
    self.think = item_speedThink;
    self.touch = item_speedTouch;
}

void item_speedTouch()
{
    if (other.classname == "player" && self.enabled)
    {
        other.moveFlags |= MF_DIFFERENTIAL;
        self.enabled = FALSE;
        self.effects |= EF_ADDITIVE;
        self.nextthink = time + ITEM_SPEED_RESPAWN;
        sound(self, CHAN_AUTO, "world/pickup_speed.wav", 1, ATTN_NORM);
    }
}

void item_speedThink()
{
    self.enabled = TRUE;
    self.effects &= ~EF_ADDITIVE;
    sound(self, CHAN_AUTO, "world/respawn_speed.wav", 0.5, ATTN_NORM);
}
