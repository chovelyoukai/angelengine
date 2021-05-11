#include "math.qh"

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
