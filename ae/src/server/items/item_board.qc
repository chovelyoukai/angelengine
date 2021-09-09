#include "item_board.qh"

void item_board()
{
	setmodel(self, "models/objects/board.iqm");
	setsize(self, '-32 -32 -32', '32 32 32');
	self.frame = 0;
	self.solid = SOLID_TRIGGER;
	self.enabled = TRUE;
	self.think = item_boardThink;
	self.touch = item_boardTouch;
}

void item_boardTouch()
{
	if (other.classname == "player" && self.enabled)
	{
		other.moveFlags |= MF_SKATE;
		self.enabled = FALSE;
		self.effects |= EF_ADDITIVE;
		self.nextthink = time + ITEM_BOARD_RESPAWN;
		sound(self, CHAN_AUTO, "world/pickup_speed.wav", 1, ATTN_NORM);
	}
}

void item_boardThink()
{
	self.enabled = TRUE;
	self.effects &= ~EF_ADDITIVE;
	sound(self, CHAN_AUTO, "world/respawn_speed.wav", 0.5, ATTN_NORM);
}
