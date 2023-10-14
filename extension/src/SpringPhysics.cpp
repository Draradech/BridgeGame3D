#include "SpringPhysics.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void SpringPhysics::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("construct", "gravity", "velo_damping", "z_fix", "node_mass"), &SpringPhysics::construct);
    ClassDB::bind_method(D_METHOD("add_node", "position", "fixed", "own_mass", "is_wheel"), &SpringPhysics::add_node);
    ClassDB::bind_method(D_METHOD("add_beam", "index_a", "index_b", "mass_per_m", "stiffness", "damping", "material"), &SpringPhysics::add_beam);
    ClassDB::bind_method(D_METHOD("add_road", "index_a", "index_b", "mass_per_m2"), &SpringPhysics::add_road);
    ClassDB::bind_method(D_METHOD("sim_step", "delta", "batching"), &SpringPhysics::sim_step);
    ClassDB::bind_method(D_METHOD("get_num_nodes"), &SpringPhysics::get_num_nodes);
    ClassDB::bind_method(D_METHOD("get_num_beams"), &SpringPhysics::get_num_beams);
    ClassDB::bind_method(D_METHOD("get_node_mass", "i"), &SpringPhysics::get_node_mass);
    ClassDB::bind_method(D_METHOD("get_node_fixed", "i"), &SpringPhysics::get_node_fixed);
    ClassDB::bind_method(D_METHOD("get_node_position", "i"), &SpringPhysics::get_node_position);
    ClassDB::bind_method(D_METHOD("get_beam_pos_a", "i"), &SpringPhysics::get_beam_pos_a);
    ClassDB::bind_method(D_METHOD("get_beam_pos_b", "i"), &SpringPhysics::get_beam_pos_b);
    ClassDB::bind_method(D_METHOD("get_beam_length", "i"), &SpringPhysics::get_beam_length);
    ClassDB::bind_method(D_METHOD("get_beam_force", "i"), &SpringPhysics::get_beam_force);
    ClassDB::bind_method(D_METHOD("add_mass", "i", "add_mass"), &SpringPhysics::add_mass);
    ClassDB::bind_method(D_METHOD("break_beam", "i"), &SpringPhysics::break_beam);
}

SpringPhysics::SpringPhysics()
{

}

SpringPhysics::~SpringPhysics()
{
    delete[] nodes;
    delete[] beams;
    delete[] wheels;
    delete[] roads;
}

void SpringPhysics::construct(float gravity, float velo_damping, bool z_fix, float node_mass)
{
    this->gravity = gravity;
    this->velo_damping = velo_damping;
    this->z_fix = z_fix;
    this->node_mass = node_mass;

    nodes = new PhysNode[2000]();
    beams = new PhysBeam[2000]();
    wheels = new PhysWheel[200]();
    roads = new PhysRoad[200]();
    num_nodes = 0;
    num_beams = 0;
    num_wheels = 0;
    num_roads = 0;
}

void SpringPhysics::add_node(Vector3 position, bool fixed, float own_mass, bool is_wheel)
{
    PhysNode* n = &nodes[num_nodes++];
    n->position.x = position.x;
    n->position.y = position.y;
    n->position.z = position.z;
    n->velocity = V3D_ZERO;
    n->fixed = fixed;
    n->own_mass = own_mass + node_mass;
    if (is_wheel)
    {
        PhysWheel* w = &wheels[num_wheels++];
        w->node = n;
        w->radius = 0.3f;
    }
}

void SpringPhysics::add_beam(int index_a, int index_b, float mass_per_m, float stiffness, float damping, int material)
{
    PhysBeam* b = &beams[num_beams++];

    b->node_a = &nodes[index_a];
    b->node_b = &nodes[index_b];

    float length = distance(b->node_a->position, b->node_b->position);
    b->target_length = length;
    b->mass = mass_per_m * length;
    b->stiffness = stiffness / length;
    b->damping = damping / length;
    b->material = material;
    update_masses();
}

float heron(Vec3f pa, Vec3f pb, Vec3f pc)
{
    float a = distance(pb, pc);
    float b = distance(pa, pc);
    float c = distance(pa, pb);
    float s = 0.5f * (a + b + c);
    return sqrt(s * (s - a) * (s - b) * (s - c));
}

void SpringPhysics::add_road(int index_a, int index_b, float mass_per_m2)
{
    PhysRoad* r = &roads[num_roads++];

    r->beam_a = &beams[index_a];
    r->beam_b = &beams[index_b];
    float masses[4];
    float inv_d_sum = 0.0f;
    float total_mass = 0.0f;
    float inv_distances[4];
    Vec3f rnodes[4] = {r->beam_a->node_a->position, r->beam_a->node_b->position, r->beam_b->node_b->position, r->beam_b->node_a->position};
    Vec3f center = vmul(vadd(vadd(rnodes[0], rnodes[1]), vadd(rnodes[2], rnodes[3])), 0.25);
    for (int i = 0; i < 4; ++i) { inv_distances[i] = 1.0f / distance(rnodes[i], center); inv_d_sum += inv_distances[i]; }
    for (int i = 0; i < 4; ++i) total_mass += heron(rnodes[i], rnodes[(i + 1) % 4], center) * mass_per_m2;
    for (int i = 0; i < 4; ++i) masses[i] = total_mass * inv_distances[i] / inv_d_sum;
    r->mass_aa = masses[0]; r->mass_ab = masses[1]; r->mass_bb = masses[2]; r->mass_ba = masses[3];
    update_masses();
}

void SpringPhysics::update_masses()
{
    for (int i = num_nodes - 1; i >= 0; --i)
    {
        PhysNode* n = &nodes[i];
        n->mass = n->own_mass;
    }
    for (int i = num_beams - 1; i >= 0; --i)
    {
        PhysBeam* b = &beams[i];
        b->node_a->mass += b->mass * 0.5f;
        b->node_b->mass += b->mass * 0.5f;
    }
    for (int i = num_roads - 1; i >= 0; --i)
    {
        PhysRoad* r = &roads[i];
        r->beam_a->node_a->mass += r->mass_aa;
        r->beam_a->node_b->mass += r->mass_ab;
        r->beam_b->node_a->mass += r->mass_ba;
        r->beam_b->node_b->mass += r->mass_bb;
    }
}

_FORCE_INLINE_ void SpringPhysics::update_forces()
{
    for(int i = num_nodes - 1; i >= 0; --i)
    {
        PhysNode* n = &nodes[i];
        n->force = vmul(V3D_DOWN, n->mass * gravity);
    }
    for(int i = num_beams - 1; i >= 0; --i)
    {
        PhysBeam* b = &beams[i];
        Vec3f b_to_a = vsub(b->node_a->position, b->node_b->position);
        float lsq = vdot(b_to_a, b_to_a);
        float rl = rsqrt(lsq);
        float length = lsq * rl;
        float spring_force = (b->target_length - length) * b->stiffness;
        if(b->material == CABLE && spring_force > 0.0f) continue; // no compression in cable
        Vec3f direction = vmul(b_to_a, rl);
        Vec3f force_vector_spring = vmul(direction, spring_force);
        b->node_a->force = vadd(b->node_a->force, force_vector_spring);
        b->node_b->force = vsub(b->node_b->force, force_vector_spring);

        Vec3f velo = vsub(b->node_b->velocity, b->node_a->velocity);
        float velo_s = vdot(velo, direction);
        float damp_force = velo_s * b->damping;
        Vec3f force_vector_damp = vmul(direction, damp_force);
        if(b->material == SPRING)
        {
            b->node_a->force = vadd(b->node_a->force, force_vector_damp);
            b->node_b->force = vsub(b->node_b->force, force_vector_damp);
        }
        else
        {
            b->node_a->force = vadd(b->node_a->force, vmul(force_vector_damp, b->node_a->mass));
            b->node_b->force = vsub(b->node_b->force, vmul(force_vector_damp, b->node_b->mass));
        }
    }
}

_FORCE_INLINE_ void SpringPhysics::integrate(float delta)
{
    for(int i = num_nodes - 1; i >= 0; --i)
    {
        PhysNode* n = &nodes[i];
        if(!n->fixed)
        {
            Vec3f acc = vdiv(n->force, n->mass);
            n->velocity = vadd(n->velocity, vmul(acc, delta));
            n->velocity = vmul(n->velocity, velo_factor);
            n->position = vadd(n->position, vmul(n->velocity, delta));
        }
    }
}

void SpringPhysics::sim_step(float delta, int batching)
{
    velo_factor = pow(velo_damping, delta);
    for(int i = 0; i < batching; ++i)
    {
        update_forces();
        integrate(delta);
        if(z_fix)
        {
            for(int i = num_nodes - 1; i >= 0; --i)
            {
                PhysNode* n = &nodes[i];
                n->force.z = 0.0f;
			    n->velocity.z = 0.0f;
			    n->position.z = 0.0f;
            }
        }
        collide_wheels();
    }
}

bool is_point_in_triangle(Vec3f a, Vec3f b, Vec3f c, Vec3f p)
{
    Vec3f bary = barycentric(a, b, c, p);
    return (bary.x >= 0.0f && bary.y >= 0.0f && bary.z >= 0.0f && bary.x <= 1.0f && bary.y <= 1.0f && bary.z <= 1.0f);
}

Vec3f closest_point_on_edge(Vec3f a, Vec3f b)
{
    Vec3f v = vsub(b, a);
    float t = vdot(vsub(V3D_ZERO, a), v) / vdot(v, v);
    t = CLAMP(t, 0.0f, 1.0f);
    Vec3f ret = vadd(a, vmul(v, t));
    return ret;
}

Vec3f closest_point_on_triangle_edge(Vec3f a, Vec3f b, Vec3f c)
{
    Vec3f qab = closest_point_on_edge(a, b);
    float dab = length(qab);
    Vec3f qac = closest_point_on_edge(a, c);
    float dac = length(qac);
    Vec3f qbc = closest_point_on_edge(b, c);
    float dbc = length(qbc);
    if (dab <= dac && dab <= dbc) return qab;
    if (dac <= dbc) return qac;
    return qbc;
}

bool sphere_triangle_collision(Vec3f a, Vec3f b, Vec3f c, Vec3f p, float r, Vec3f& normal, float& depth)
{
    // Translate problem so sphere is centered at origin
    a = vsub(a, p);
    b = vsub(b, p);
    c = vsub(c, p);
    // Compute a vector normal to triangle plane and normalize it
    normal = normalize(vcross(vsub(b, a), vsub(c, a)));
    // Compute distance d of sphere center to triangle plane
    float d = vdot(a, normal);
    float ad = abs(d);
    // Early out if too far from plane
    if (ad > r) return false;
    Vec3f projection = vmul(normal, d);
    if (is_point_in_triangle(a, b, c, projection))
    {
        depth = r - ad;
        return true;
    }
    Vec3f on_edge = closest_point_on_triangle_edge(a, b, c);
    ad = length(on_edge);
    // too far from edge
    if (ad > r) return false;
    depth = r - ad;
    normal = vsub(V3D_ZERO, normalize(on_edge));
    return true;
}

void SpringPhysics::collide_wheels()
{
    for (int i = num_wheels - 1; i >= 0; --i)
    {
        PhysWheel* w = &wheels[i];
        int num_collisions = 0;
        Vec3f normal;
        float depth;
        for (int j = num_roads - 1; j >= 0; --j)
        {
            PhysRoad* r = &roads[j];
            Vec3f rnodes[4] = {r->beam_a->node_a->position, r->beam_a->node_b->position, r->beam_b->node_b->position, r->beam_b->node_a->position};
            Vec3f center = vmul(vadd(vadd(rnodes[0], rnodes[1]), vadd(rnodes[2], rnodes[3])), 0.25);
            for (int i = 0; i < 1; ++i)
            {
                Vec3f resolution;
                if (sphere_triangle_collision(rnodes[i], rnodes[(i + 1) % 4], center, w->node->position, w->radius, normal, depth))
                {
                    num_collisions++;
                    //sum_resolution = vadd(sum_resolution, resolution);
                }
            }
        }
        if (num_collisions)
        {
            Vec3f resolution = vmul(normal, depth);
            Vec3f resolution_velo = vmul(normal, vdot(w->node->velocity, normal));
            w->node->position = vadd(w->node->position, resolution);
            w->node->velocity = vsub(w->node->velocity, resolution_velo);
        }
    }
}

int SpringPhysics::get_num_nodes()
{
    return num_nodes;
}

float SpringPhysics::get_node_mass(int i)
{
    return nodes[i].mass;
}

Vector3 SpringPhysics::get_node_position(int i)
{
    return Vector3(nodes[i].position.x, nodes[i].position.y, nodes[i].position.z);
}

bool SpringPhysics::get_node_fixed(int i)
{
    return nodes[i].fixed;
}

int SpringPhysics::get_num_beams()
{
    return num_beams;
}

Vector3 SpringPhysics::get_beam_pos_a(int i)
{
    return Vector3(beams[i].node_a->position.x, beams[i].node_a->position.y, beams[i].node_a->position.z);
}

Vector3 SpringPhysics::get_beam_pos_b(int i)
{
    return Vector3(beams[i].node_b->position.x, beams[i].node_b->position.y, beams[i].node_b->position.z);
}

float SpringPhysics::get_beam_length(int i)
{
    PhysBeam* b = &beams[i];
    Vec3f b_to_a = vsub(b->node_a->position, b->node_b->position);
    float lsq = vdot(b_to_a, b_to_a);
    float rl = rsqrt(lsq);
    float length = lsq * rl;
    return length;
}

float SpringPhysics::get_beam_force(int i)
{
    PhysBeam* b = &beams[i];
    Vec3f b_to_a = vsub(b->node_a->position, b->node_b->position);
    float lsq = vdot(b_to_a, b_to_a);
    float rl = rsqrt(lsq);
    float length = lsq * rl;
    float spring_force = (b->target_length - length) * b->stiffness;
    return spring_force;
}

void SpringPhysics::add_mass(int i, float add_mass)
{
    nodes[i].own_mass += add_mass;
    update_masses();
}

void SpringPhysics::break_beam(int i)
{
    PhysBeam* b1 = &beams[i];
    PhysBeam* b2 = &beams[num_beams++];
    PhysNode* n1a = b1->node_a;
    PhysNode* n1b = &nodes[num_nodes++];
    PhysNode* n2a = &nodes[num_nodes++];
    PhysNode* n2b = b1->node_b;

    n1b->position = vmul(vadd(n1a->position, n2b->position), 0.5f);
    n1b->velocity = vmul(vadd(n1a->velocity, n2b->velocity), 0.5f);;
    n1b->fixed = false;
    n1b->own_mass = node_mass;
    n2a->position = n1b->position;
    n2a->velocity = n1b->velocity;
    n2a->fixed = false;
    n2a->own_mass = node_mass;

    b1->node_b = n1b;
    b1->target_length = b1->target_length * 0.5;
    b1->mass = b1->mass * 0.5;

    b2->node_a = n2a;
    b2->node_b = n2b;
    b2->target_length = b1->target_length;
    b2->mass = b1->mass;
    b2->stiffness = b1->stiffness;
    b2->damping = b1->damping;

    update_masses();
}
