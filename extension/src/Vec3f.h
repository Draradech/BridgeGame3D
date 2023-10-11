#ifndef _VEC3F_H_
#define _VEC3F_H_
#include <math.h>

typedef struct
{
   float x;
   float y;
   float z;
} Vec3f;

static Vec3f V3D_ZERO = {0, 0, 0};
static Vec3f V3D_DOWN = {0, -1, 0};

static Vec3f vsub(Vec3f v1, Vec3f v2)
{
   Vec3f res;
   res.x = v1.x - v2.x;
   res.y = v1.y - v2.y;
   res.z = v1.z - v2.z;
   return res;
}

static Vec3f vadd(Vec3f v1, Vec3f v2)
{
   Vec3f res;
   res.x = v1.x + v2.x;
   res.y = v1.y + v2.y;
   res.z = v1.z + v2.z;
   return res;
}

static Vec3f vmul(Vec3f v, float d)
{
   Vec3f res;
   res.x = v.x * d;
   res.y = v.y * d;
   res.z = v.z * d;
   return res;
}

static Vec3f vdiv(Vec3f v, float d)
{
   float r = 1.0 / d;
   return vmul(v, r);
}

static float vdot(Vec3f v1, Vec3f v2)
{
   return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

static float length(Vec3f v)
{
   return sqrt(vdot(v, v));
}

static float distance(Vec3f v1, Vec3f v2)
{
   return length(vsub(v1, v2));
}

#endif /* _VEC3F_H_ */
