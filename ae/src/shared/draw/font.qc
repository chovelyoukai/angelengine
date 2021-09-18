void LoadFonts()
{
	autocvar(text_font, "fonts/textFont.ttf");
	autocvar(mono_font, "fonts/monoFont.ttf");
	autocvar(title_font, "fonts/titleFont.ttf");
	textFont = loadfont("", cvar_string("text_font"), "12, 16, 20, 24, 32", -1, 0, 0);
	monoFont = loadfont("", cvar_string("mono_font"), "12, 16, 20, 24, 32", -1, 0, 0);
	titleFont = loadfont("", cvar_string("title_font"), "12, 16, 20, 24, 32", -1, 0, 0);
}

void SetFont(float fontNumber)
{
	if (cvar("cl_usefonts") == 0)
	{
		drawfont = FONT_DEFAULT;
	}
	else
	{
		drawfont = fontNumber;
	}
}
