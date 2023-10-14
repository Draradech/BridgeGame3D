#ifndef _VEC3F_H_
#define _VEC3F_H_
#include <math.h>
#include <immintrin.h>

typedef struct
{
   float x;
   float y;
   float z;
} Vec3f;

static Vec3f V3D_ZERO = {0, 0, 0};
static Vec3f V3D_DOWN = {0, -1, 0};

static float rsqrt(float f)
{
    __m128 temp = _mm_set_ss(f);
    temp = _mm_rsqrt_ss(temp);
    return _mm_cvtss_f32(temp);
}

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

static Vec3f vmul(Vec3f v, float f)
{
   Vec3f res;
   res.x = v.x * f;
   res.y = v.y * f;
   res.z = v.z * f;
   return res;
}

static Vec3f vcross(Vec3f v1, Vec3f v2)
{
   Vec3f res;
   res.x = v1.y * v2.z - v1.z * v2.y;
   res.y = v1.z * v2.x - v1.x * v2.z;
   res.z = v1.x * v2.y - v1.y * v2.x;
   return res;
}

static float vdot(Vec3f v1, Vec3f v2)
{
   return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

static Vec3f vdiv(Vec3f v, float f)
{
   return vmul(v, 1.0 / f);
}

static Vec3f normalize(Vec3f v)
{
   return vmul(v, rsqrt(vdot(v, v)));
}

static float length(Vec3f v)
{
   return 1.0f / rsqrt(vdot(v, v));
}

static float distance(Vec3f v1, Vec3f v2)
{
   return length(vsub(v1, v2));
}

static Vec3f barycentric(Vec3f a, Vec3f b, Vec3f c, Vec3f p)
{
   Vec3f ret;

   Vec3f ab = vsub(b, a);
   Vec3f ac = vsub(c, a);
   Vec3f ap = vsub(p, a);

   float d1 = vdot(ab, ab) * vdot(ac, ac) - vdot(ab, ac) * vdot(ab, ac);
   float n1 = vdot(ap, ab) * vdot(ac, ac) - vdot(ap, ac) * vdot(ab, ac);
   float n2 = vdot(ap, ac) * vdot(ab, ab) - vdot(ap, ab) * vdot(ab, ac);

   ret.x = n1 / d1;
   ret.y = n2 / d1;
   ret.z = 1.0f - ret.x - ret.y;

   return ret;
}

#endif /* _VEC3F_H_ */
