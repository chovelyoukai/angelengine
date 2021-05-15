#inlcude "impulses.qh"

void CheckImpulses()
{
	if (self.impulse >= 0 && self.impulse < MAX_WEAPONS)
	{
		SwitchWeapons(self.impulse);
	}
}
