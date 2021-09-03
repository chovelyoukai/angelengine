#include "item_prop.qh"

void item_prop()
{
	if (self.modelPath != "")
	{
		precache_model(self.modelPath);
	}
	self.solid = SOLID_NOT;
	self.nextthink = time + 0.1;
	self.think = item_propThink;
}

void item_propThink()
{
	setmodel(self, self.modelPath);
	setsize(self, self.minSize, self.maxSize);
}
