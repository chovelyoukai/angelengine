#include "hud.qh"

void DrawHud(float width, float height)
{
	SetFont(monoFont);

	if (cvar("cl_drawhud") > 0)
	{
		SetRealSize([width, height]);
		DrawMeters(width, height);
		DrawKeys(width, height);
		DrawHealth(width, height);
		DrawDamageIndicators(width, height);
		DrawNames(width, height);
		DrawScoreboard(width, height);
		DrawTimer(width, height);
	}

	DrawScanlines(width, height);
}

void DrawMeters(float width, float height)
{
	string speedString, speedString2d;
	float speedWidth, speedWidth2d;
	float cursor = 0; 
	vector speedPos, speedPos2d, accelPos;
	vector accelSize;
	vector accelColor;
	float accel2D, accel3D, accelReal;
	float health = getstatf(STAT_HEALTH);

	SetFont(textFont);

	if (cvar("cl_drawhspeed") > 0)
	{
		speedString2d = ftos(rint(vlen2d(player.velocity)));
		speedString2d = strcat("H: ", speedString2d, " UPS");
		speedWidth2d = stringwidth(speedString2d, TRUE, '12 12');
		speedPos2d.x = (width - speedWidth2d) / 2;
		speedPos2d.y = height / 2 + height / 32 + cursor;
		cursor += 14;
		drawstring(speedPos2d, speedString2d, '12 12', '1 1 1', 1.0, 1);
	}

	if (cvar("cl_drawaspeed") > 0)
	{
		speedString = ftos(rint(vlen(player.velocity)));
		speedString = strcat("A: ", speedString, " UPS");
		speedWidth = stringwidth(speedString, TRUE, '12 12');
		speedPos.x = (width - speedWidth) / 2;
		speedPos.y = height / 2 + height / 32 + cursor;
		cursor += 14;
		drawstring(speedPos, speedString, '12 12', '1 1 1', 1.0, 1);
	}

	if (cvar("cl_drawvspeed") > 0)
	{
		speedString = ftos(fabs(rint(player.velocity.z)));
		speedString = strcat("V: ", speedString, " UPS");
		speedWidth = stringwidth(speedString, TRUE, '12 12');
		speedPos.x = (width - speedWidth) / 2;
		speedPos.y = height / 2 + height / 32 + cursor;
		cursor += 14;
		drawstring(speedPos, speedString, '12 12', '1 1 1', 1.0, 1);
	}


	if (cvar("cl_drawaccel") > 0)
	{
		accelColor = ACCEL_GROUND_COLOR;

		accel2D = UpdateAccel2D(width);
		accel3D = UpdateAccel(width);
		accelReal = 0;

		switch (player.accelType)
		{
			case ACCEL_GROUND:
				accelColor = ACCEL_GROUND_COLOR;
				accelReal = accel2D;
				break;
			case ACCEL_WALL:
				accelColor = ACCEL_WALL_COLOR;
				accelReal = accel3D;
				break;
			case ACCEL_QW:
				accelColor = ACCEL_QW_COLOR;
				accelReal = accel2D;
				break;
			case ACCEL_Q3:
				accelColor = ACCEL_Q3_COLOR;
				accelReal = accel2D;
				break;
			case ACCEL_NOCLIP:
				accelColor = ACCEL_NOCLIP_COLOR;
				accelReal = accel3D;
				break;
			case ACCEL_FLY:
				accelColor = ACCEL_FLY_COLOR;
				accelReal = accel3D;
				break;
			default:
				accelColor = ACCEL_GROUND_COLOR;
				accelReal = accel3D;
		}

		accelSize.x = accelReal * cvar("cl_accelmultiplier");
		accelSize.y = 12;
		accelPos.x = (width - accelSize.x) / 2;
		accelPos.y = height / 2 + height / 32 + cursor;
		drawfill(accelPos, accelSize, accelColor, 1.0, DRAWFLAG_NORMAL);
	}
}

float UpdateAccel2D(float width)
{
	float accelDamp = cvar("cl_acceldamp");
	float diffSpeed;

	oldAccel2D = ((1 - accelDamp) * (vlen2d(player.velocity) - oldSpeed2D)) +
	             (accelDamp * oldAccel2D);

	if (vlen2d(player.velocity) < oldSpeed2D)
	{
		diffSpeed = 0;
	}
	diffSpeed = rint(oldAccel2D * 15);
	if (diffSpeed > width / 10)
	{
		diffSpeed = width / 10;
	}

	oldSpeed2D = vlen2d(player.velocity);

	return diffSpeed;
}

float UpdateAccel(float width)
{
	float accelDamp = cvar("cl_acceldamp");
	float diffSpeed;

	oldAccel = ((1 - accelDamp) * (vlen(player.velocity) - oldSpeed)) +
	           (accelDamp * oldAccel);

	if (vlen(player.velocity) < oldSpeed)
	{
		diffSpeed = 0;
	}
	diffSpeed = rint(oldAccel * 15);
	if (diffSpeed > width / 10)
	{
		diffSpeed = width / 10;
	}

	oldSpeed = vlen(player.velocity);

	return diffSpeed;
}

void DrawHealth(float width, float height)
{
	float health = rint(getstatf(STAT_HEALTH));
	vector healthPos, healthSize, healthColor;
	string healthString = ftos(health);
	healthString = strcat("Health: ", healthString);

	SetFont(textFont);

	healthPos.x = 3 * (width / 4);
	healthPos.y = 3 * (height / 4);

	drawstring(healthPos, healthString, '16 16', '1 1 1', 1.0, 0);

	healthPos.y += 14;
	healthSize.y = 12;
	healthSize.x = health * (width / 1000);
	if (health > 100)
	{
		healthSize.x = 100 * (width / 1000);
	}
	healthColor = '0.8 0 0';

	drawfill(healthPos, healthSize, HEALTH_COLOR, 1.0, DRAWFLAG_NORMAL);

	if (health > 100)
	{
		health -= 100;
		healthSize.x = health * (width / 1000);
		healthColor = '0 1 0';
		healthPos.x += 0.005 * width;
		healthPos.y += 0.005 * width;
		drawfill(healthPos, healthSize, OVERHEAL_COLOR, 1.0, DRAWFLAG_NORMAL);
	}
}

void DrawKeys(float width, float height)
{
	float fmove, smove, umove;
	vector keysPos; 
	string topText, middleText, bottomText;
	string left, right, forward, backward, jump, attack, mod;

	if (cvar("cl_drawkeys") == 0)
	{
		return;
	}

	SetFont(monoFont);

	left = right = forward = backward = jump = attack = mod = " ";

	fmove = input_movevalues.x;
	smove = input_movevalues.y;
	umove = input_movevalues.z;

	if (fmove > 10)
	{
		forward = "^";
	}
	else if (fmove < -10)
	{
		backward = "v";
	}
	if (smove > 10)
	{
		right = ">";
	}
	else if (smove < -10)
	{
		left = "<";
	}
	if (umove > 10)
	{
		jump = "J";
	}
	if (input_buttons & BUTTON_ATTACK)
	{
		attack = "A";
	}
	if (input_buttons & BUTTON_MOD1)
	{
		mod = "o";
	}

	topText = strcat(jump, " ", forward, " ", attack);
	middleText = strcat(left, " ", mod, " ", right);
	bottomText = strcat("  ", backward, "  ");

	keysPos.x = cvar("cl_drawkeys_x");
	keysPos.y = cvar("cl_drawkeys_y");

	keysPos.x = keysPos.x * (width - stringwidth(topText, TRUE, '12 12'));
	keysPos.y = keysPos.y * height;
	drawstring(keysPos, topText, '12 12', '1 1 1', 1.0, 1);
	keysPos.y += 14;
	drawstring(keysPos, middleText, '12 12', '1 1 1', 1.0, 1);
	keysPos.y += 14;
	drawstring(keysPos, bottomText, '12 12', '1 1 1', 1.0, 1);
}

void DrawNames(float width, float height)
{
	vector start, end;
	vector location;
	makevectors(view_angles);
	start = self.origin + self.view_ofs;
	end = start + (v_forward * 10000);
	traceline(start, end, MOVE_NORMAL, self);

	SetFont(textFont);

	if (trace_ent.classname == "player")
	{
		location = trace_ent.origin;
		location.z += 50 + (trace_fraction * 500);
		location = project(location);
		location.x -= stringwidth(trace_ent.netname, TRUE, '12 12') / 2;
		drawstring(location, trace_ent.netname, '12 12', '1 1 1', 1.0, 1);
	}
}

void DrawScoreboard(float width, float height)
{
	float i;
	vector position = SB_BG_POS;
	entity nextPlayer = world;

	if (cvar("cl_drawscoreboard") == 0)
	{
		return;
	}
	SetCoords(position);
	SetAlign(ALIGN_LEFT, ALIGN_TOP);
	DrawBox(SB_BG_SIZE, SB_BG_COLOR, SB_BG_ALPHA);

	position.x += 1;
	position.y += 2;
	SetCoords(position);

	vector fSize = SB_FONT_SIZE;
	vector fColor = SB_FONT_COLOR;
	float fAlpha = SB_FONT_ALPHA;

	SetFont(titleFont);
	DrawText("Score", fSize, fColor, fAlpha);
	AddCoords([7, 0]);
	DrawText("Name", fSize, fColor, fAlpha);
	AddCoords([17, 0]);
	DrawTextInc("Ping", fSize, fColor, fAlpha);
	AddCoords([-24, 0]);

	SetFont(textFont);
	string frags = getplayerkeyvalue(player_localnum, INFOKEY_P_FRAGS);
	string name = getplayerkeyvalue(player_localnum, INFOKEY_P_NAME);
	string ping = getplayerkeyvalue(player_localnum, INFOKEY_P_PING);
	DrawText(frags, fSize, fColor, fAlpha);
	AddCoords([7, 0]);
	DrawText(name, fSize, fColor, fAlpha);
	AddCoords([17, 0]);
	DrawTextInc(ping, fSize, fColor, fAlpha);
	AddCoords([-24, 0]);

	for (i = 0; i < maxclients; i++)
	{
		if (i == player_localnum)
		{
			continue;
		}
		frags = getplayerkeyvalue(i, INFOKEY_P_FRAGS);
		name = getplayerkeyvalue(i, INFOKEY_P_NAME);
		ping = getplayerkeyvalue(i, INFOKEY_P_PING);
		DrawText(frags, fSize, fColor, fAlpha);
		AddCoords([5, 0]);
		DrawText(name, fSize, fColor, fAlpha);
		AddCoords([20, 0]);
		DrawTextInc(ping, fSize, fColor, fAlpha);
		AddCoords([-25, 0]);
	}
}

void DrawTimer(float width, float height)
{
	if (cvar("cl_drawtimer") == 0)
	{
		return;
	}

	float minutes;
	float seconds;
	string minutesText, secondsText, text;

	vector position = '0 5 0';
	position.x = cvar("cl_timer_x");

	SetCoords(position);
	AlignCoords(ALIGN_CENTER, ALIGN_TOP);
	SetAlign(ALIGN_CENTER, ALIGN_BOTTOM);
	SetFont(textFont);

	if (gameTime < 0)
	{
		minutes = 99;
		seconds = 99;
	}
	else
	{
		minutes = floor(gameTime / 60);
		seconds = gameTime - (minutes * 60);
	}

	minutesText = ftos(minutes);
	if (minutes < 10)
	{
		minutesText = strcat("0", minutesText);
	}
	secondsText = ftos(seconds);
	if (seconds < 10)
	{
		secondsText = strcat("0", secondsText);
	}

	text = strcat(minutesText, ":", secondsText);

	DrawText(text, TIMER_FONT_SIZE, TIMER_COLOR, 1);
}

void DrawScanlines(float width, float height)
{
	float y;

	if (cvar("cl_scanlines") == 0)
	{
		return;
	}

	for (y = 0; y <= height; y+= height / cvar("cl_scanline_count"))
	{
		drawfill([0, (y + time * cvar("cl_scanline_speed")) % height],
			[width, height / cvar("cl_scanline_size_inv")],
			'0 0 0', cvar("cl_scanline_alpha"));
	}
}
