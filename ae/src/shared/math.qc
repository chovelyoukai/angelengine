#include "math.qh"

float vlen2d(vector v)
{
	v.z = 0;
	return vlen(v);
}

float DotProduct(vector u, vector v)
{
	return (u.x * v.x) + (u.y * v.y) + (u.z * v.z);
}

vector CrossProduct(vector u, vector v)
{
	vector out;

	out.x = (u.y * v.z) - (u.z * v.y);
	out.y = (u.z * v.x) - (u.x * v.z);
	out.z = (u.x * v.y) - (u.y * v.x);

	return out;
}

float RadiansToDegrees(float angle)
{
	return angle * 180 / PI;
}

float clamp(float min, float value, float max)
{
    if (value < min)
    {
        value = min;
    }
    else if (value > max)
    {
        value = max;
    }
    return value;
}
