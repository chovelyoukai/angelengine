#include "receive.qh"

void CSQC_Parse_Event()
{
	float command = readbyte();
	float amount;
	float pitch;

	switch (command)
	{
		case CMD_HIT:
			amount = readlong();		
			pitch = 180 - amount;
			sound(player, CHAN_AUTO, "ui/hit.wav", 1, ATTN_NONE, pitch);
			break;
		case CMD_KILL:
			sound(player, CHAN_AUTO, "ui/kill.wav", 1, ATTN_NONE, pitch);
			break;
		case CMD_DAMAGE_KNOCKBACK:
			ReceiveDamage(TRUE);
			break;
		case CMD_DAMAGE_HURT:
			ReceiveDamage(FALSE);
			break;
		case CMD_WEAPON_SPAWN:
			ReceiveWeaponSpawn();
			break;
		case CMD_WEAPON_REMOVE:
			ReceiveWeaponRemove();
			break;
		case CMD_DEATH:
			InitializePlayer();
			break;
	}
}

void CSQC_Ent_Update(float isNew)
{
	float entType = readbyte();

	switch (entType)
	{
	case ENT_PLAYER:
		ReceivePlayer(isNew, TRUE);
		break;
	case ENT_PLAYER_OTHER:
		ReceivePlayer(isNew, FALSE);
		break;
	case ENT_PROJECTILE:
		ReceiveProjectile();
		break;
	}
}

void ReceivePlayer(float isNew, float isLocalPlayer)
{
	vector newOrigin;
	vector newVelocity;
	float flags;
	float newMoveFlags;
	float moveInterp = cvar("cl_moveinterp");
	float frameDifference = clientcommandframe - servercommandframe;

	flags = readlong();
	if (flags & FL_ORIGIN)
	{
		newOrigin.x = readcoord();
		newOrigin.y = readcoord();
		newOrigin.z = readcoord();
		
		if (isLocalPlayer && cvar("cl_receive") > 0)
		{
			if (flags & FL_SNAP)
			{
				setorigin(self, newOrigin);
			}
			else
			{
				self.correctOrigin = newOrigin;
				self.fixOrigin = TRUE;
			}
		}
		else if (!isLocalPlayer)
		{
			setorigin(self, newOrigin);
		}
	}
	if (flags & FL_VELOCITY)
	{
		newVelocity.x = readcoord();
		newVelocity.y = readcoord();
		newVelocity.z = readcoord();

		if (isLocalPlayer && cvar("cl_receive") > 0)
		{
			if (vlen(self.velocity - newVelocity) > 0.1 * vlen(self.velocity)
			    * frameDifference || cvar("cl_errorcorrect") == 0)
			{
				self.velocity = newVelocity;
			}
			else
			{
				self.correctVelocity = newVelocity;
				self.fixVelocity = TRUE;
			}
		}
		else if (!isLocalPlayer)
		{
			self.velocity = newVelocity;
		}
	}
	if (flags & FL_MOVETYPE)
	{
		self.movetype = readlong();
		if (isLocalPlayer && self.movetype == MOVETYPE_WALK
		    && cvar("cl_receive") > 0)
		{
			self.movetype = MOVETYPE_FLY;
		}
	}
	if (flags & FL_MOVEFLAGS)
	{
		newMoveFlags = readlong();
		if (cvar("cl_receive") > 0)
		{
			self.moveFlags = newMoveFlags;
		}
	}
	if (flags & FL_DISCONNECT && !(flags & FL_MODELINDEX))
	{
		setmodel(self, "");
		setsize(self, '0 0 0', '0 0 0');
		return;
	}
	if (flags & FL_NETNAME)
	{
		self.netname = readstring();
	}
	if (flags & FL_MODELINDEX)
	{
		readbyte();
	}

	if (isLocalPlayer)
	{
		player = self;  
		if (isNew)
		{
			self.classname = "player";
		}
	}
	else if (!isLocalPlayer && isNew)
	{
		self.classname = "player";
		self.drawmask = MASK_ENGINE;
		setmodel(self, "models/player.iqm");
	}
	setsize(self, PLAYER_MIN_STAND, PLAYER_MAX_STAND);
	self.solid = SOLID_SLIDEBOX;
}

void ReceiveDamage(float isKnockback)
{
	entity damager = spawn();

	damager.classname = "damager";
	damager.think = RemoveSelf;
	damager.nextthink = time + 1;
	damager.knockback = isKnockback;
	damager.origin.x = readcoord();
	damager.origin.y = readcoord();
	damager.origin.z = readcoord();
	damager.health = readfloat();
	setorigin(damager, damager.origin);
}

void ReceiveWeaponSpawn()
{
	float weaponType = readfloat();

	GiveWeapon(player, weaponType);
}

void ReceiveWeaponRemove()
{
	float weaponType = readfloat();

	RemoveWeapon(player, slot[weaponType]);
}

void ReceiveProjectile()
{
	float flags = readlong();
	float projectileType = readbyte();

	if (flags & FL_ORIGIN)
	{
		self.origin.x = readcoord();
		self.origin.y = readcoord();
		self.origin.z = readcoord();
		setorigin(self, self.origin);
	}
	if (flags & FL_VELOCITY)
	{
		self.velocity.x = readcoord();
		self.velocity.y = readcoord();
		self.velocity.z = readcoord();
		self.movetype = MOVETYPE_FLYMISSILE;
		self.angles = vectoangles(self.velocity);
	}

	self.drawmask = MASK_ENGINE;
	setmodel(self, worldmodels[projectileType]);
}

void CSQC_Ent_Remove()
{
	remove(self);
}
