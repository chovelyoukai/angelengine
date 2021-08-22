void SetRealSize(vector size)
{
    realSize = size;
}

void SetCoords(vector newCoords)
{
    relCoords = newCoords;
    absCoords.x = newCoords.x * realSize.x / 100;
    absCoords.y = newCoords.y * realSize.y / 100;
}

void AddCoords(vector newCoords)
{
    SetCoords(relCoords + newCoords);
}

vector RelToAbs(vector coords)
{
    coords /= 100;
    coords.x = coords.x * realSize.x;
    coords.y = coords.y * realSize.y;
    return coords;
}

vector AbsToRel(vector coords)
{
    coords *= 100;
    coords.x = coords.x / realSize.x;
    coords.y = coords.y / realSize.y;
    return coords;
}

void SetAlign(float alignX, float alignY)
{
    drawAlignX = alignX;
    drawAlignY = alignY;
}

void AlignCoords(float alignX, float alignY)
{
    SetCoords('0 0 0');

    switch (alignX)
    {
        case ALIGN_LEFT:
            AddCoords('10 0 0');
            break;
        case ALIGN_RIGHT:
            AddCoords('90 0 0');
            break;
        case ALIGN_CENTER:
            AddCoords('50 0 0');
            break;
    }
    switch (alignY)
    {
        case ALIGN_TOP:
            AddCoords('0 10 0');
            break;
        case ALIGN_BOTTOM:
            AddCoords('0 90 0');
            break;
        case ALIGN_CENTER:
            AddCoords('0 50 0');
            break;
    }
}

vector GetAbsAlignCoords(vector size)
{
    vector coords = absCoords;
    size = RelToAbs(size);

    switch (drawAlignX)
    {
        case ALIGN_LEFT:
            coords.x = absCoords.x;
            break;
        case ALIGN_RIGHT:
            coords.x = absCoords.x - size.x;
            break;
        case ALIGN_CENTER:
            coords.x = absCoords.x - (size.x / 2);
            break;
    }
    switch (drawAlignY)
    {
        case ALIGN_TOP:
            coords.y = absCoords.y;
            break;
        case ALIGN_BOTTOM:
            coords.y = absCoords.y - size.y;
            break;
        case ALIGN_CENTER:
            coords.y = absCoords.y - (size.y / 2);
            break;
    }

    return coords;
}

void DrawBox(vector size, vector color, float alpha)
{
    vector position = GetAbsAlignCoords(size);
    size = RelToAbs(size);
    drawfill(position, size, color, alpha);
}

void DrawText(string text, vector scale, vector color, float alpha)
{
    vector size;
    vector position;

    size.x = stringwidth(text, TRUE, '12 12');
    size.y = AbsToRel(scale).y + 2;

    position = GetAbsAlignCoords(size);

    drawstring(position, text, scale, color, alpha, 1);
}

void DrawTextInc(string text, vector scale, vector color, float alpha)
{
    vector increment = '0 0 0';
    DrawText(text, scale, color, alpha);
    increment.y = AbsToRel(scale).y + 2;
    AddCoords(increment);
}

void DrawFillFullScreen(vector color, float alpha)
{
    drawfill('0 0 0', realSize, color, alpha);
}
