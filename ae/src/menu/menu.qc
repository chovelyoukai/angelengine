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
            menu.currentMenu_select();
            break;
    }
}

void RootMenu()
{
    menu.currentMenu_draw = RootMenu_Draw;
    menu.currentMenu_select = RootMenu_Select;
    cursorPosition = 0;
    maxCursorPosition = 4;
}

void RootMenu_Draw()
{
}

void RootMenu_Select()
{
}
