#include "menu.qh"

void DrawCursor()
{
	float i;

	AlignCoords(ALIGN_LEFT, ALIGN_TOP);
	AddCoords('-2 0 0');

	DrawTextInc("", '24 24 0', '0 0 0', 0);

	for (i = 0; i < cursorPosition; i++)
	{
		DrawTextInc("", '16 16 0', '0 0 0', 0);
	}
	
	DrawTextInc(">", '16 16 0', '1 1 1', 1);
}

void HandleKeypress(float scanx)
{
	switch (scanx)
	{
		case K_DOWNARROW:
		case 's':
			if (cursorPosition >= maxCursorPosition)
			{
				break;
			}

			cursorPosition++;
			break;
		case K_UPARROW:
		case 'w':
			if (cursorPosition <= 0)
			{
				break;
			}

			cursorPosition--;
			break;
		case K_ENTER:
		case K_SPACE:
			currentMenu_select();
			break;
	}
}

void RootMenu()
{
	currentMenu_draw = RootMenu_Draw;
	currentMenu_select = RootMenu_Select;
	cursorPosition = 0;
	maxCursorPosition = 3;
}

void RootMenu_Draw()
{
	DrawTextMenu("Angel Engine", "Servers", "Test Maps", "Disconnect", "Quit");
}

void RootMenu_Select()
{
	switch (cursorPosition)
	{
		case 0:
			localcmd("menu_servers\n");
			break;
		case 1:
			TestMapMenu();
			break;
		case 2:
			localcmd("disconnect\n");
			break;
		case 3:
			localcmd("quit\n");
			break;
	}
}

void TestMapMenu()
{
	currentMenu_draw = TestMapMenu_Draw;
	currentMenu_select = TestMapMenu_Select;
	cursorPosition = 0;
	maxCursorPosition = 3;
}

void TestMapMenu_Draw()
{
	DrawTextMenu("Load Test Map", "test1", "test2", "test3", "Back");
}

void TestMapMenu_Select()
{
	switch (cursorPosition)
	{
		case 0:
			localcmd("map test1\n");
			break;
		case 1:
			localcmd("map test2\n");
			break;
		case 2:
			localcmd("map test3\n");
			break;
		case 3:
			RootMenu();
			break;
	}
	RootMenu();
}
