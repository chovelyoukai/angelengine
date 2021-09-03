#include "trigger_moveflags.qh"

void trigger_moveflags()
{
	InitTrigger();
	self.touch = trigger_moveflagsTouch;
}

void trigger_moveflagsTouch()
{
	if (other.classname != "player")
	{
		return;
	}
	
	other.moveFlags |= self.moveFlags;
	other.moveFlags &= ~self.removeFlags;
}
