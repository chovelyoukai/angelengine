float CSQC_InputEvent(float eventType, float scanx, float chary, float devid)
{
	return FALSE;
}

float CSQC_ConsoleCommand(string command)
{
	if (command == "noclip")
	{
		if (cvar("sv_cheats") != 1)
		{
			return FALSE;
		}
		if (player.movetype != MOVETYPE_WALK)
		{
			player.movetype = MOVETYPE_WALK;
		}
		else
		{
			player.movetype = MOVETYPE_NOCLIP;
		}
		return FALSE;
	}
	return FALSE;
}
