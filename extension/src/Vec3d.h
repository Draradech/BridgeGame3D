#ifndef _VEC3D_H_
#define _VEC3D_H_

typedef struct
{
   double x;
   double y;
   double z;
} Vec3d;

Vec3d vsub(Vec3d v1, Vec3d v2);
Vec3d vadd(Vec3d v1, Vec3d v2);
Vec3d vmul(Vec3d v, double d);
Vec3d vdiv(Vec3d v, double d);
double vdot(Vec3d v1, Vec3d v2);

double length(Vec3d v);
double distance(Vec3d v1, Vec3d v2);

extern Vec3d V3D_ZERO;
extern Vec3d V3D_DOWN;

#endif /* _VEC3D_H_ */
