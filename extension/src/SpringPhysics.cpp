#include "SpringPhysics.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <immintrin.h>

using namespace godot;

void SpringPhysics::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("construct", "gravity", "velo_damping", "z_fix", "node_mass"), &SpringPhysics::construct);
    ClassDB::bind_method(D_METHOD("addNode", "position", "fixed", "own_mass"), &SpringPhysics::addNode);
    ClassDB::bind_method(D_METHOD("addBeam", "index_a", "index_b", "mass_per_m", "stiffness", "damping"), &SpringPhysics::addBeam);
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
}

void SpringPhysics::construct(float gravity, float velo_damping, bool z_fix, float node_mass)
{
    this->gravity = gravity;
    this->velo_damping = velo_damping;
    this->z_fix = z_fix;
    this->node_mass = node_mass;

    nodes = new PhysNode[200]();
    beams = new PhysBeam[200]();
    num_nodes = 0;
    num_beams = 0;
}

void SpringPhysics::addNode(Vector3 position, bool fixed, float own_mass)
{
    PhysNode* n = &nodes[num_nodes++];
    n->position.x = position.x;
    n->position.y = position.y;
    n->position.z = position.z;
    n->velocity = V3D_ZERO;
    n->fixed = fixed;
    n->own_mass = own_mass + node_mass;
}

void SpringPhysics::addBeam(int index_a, int index_b, float mass_per_m, float stiffness, float damping)
{
    PhysBeam* b = &beams[num_beams++];

    b->node_a = &nodes[index_a];
    b->node_b = &nodes[index_b];

    float length = distance(b->node_a->position, b->node_b->position);
    b->target_length = length;
    b->mass = mass_per_m * length;
    b->stiffness = stiffness / length;
    b->damping = damping / length;
    update_masses();
}

float rsqrt(float f)
{
    __m128 temp = _mm_set_ss(f);
    temp = _mm_rsqrt_ss(temp);
    return _mm_cvtss_f32(temp);
}

void SpringPhysics::update_masses()
{
    for(int i = num_nodes - 1; i >= 0; --i)
    {
        PhysNode* n = &nodes[i];
        n->mass = n->own_mass;
    }
    for(int i = num_beams - 1; i >= 0; --i)
    {
        PhysBeam* b = &beams[i];
        b->node_a->mass += b->mass * 0.5f;
        b->node_b->mass += b->mass * 0.5f;
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
        Vec3f direction = vmul(b_to_a, rl);
        Vec3f velo = vsub(b->node_b->velocity, b->node_a->velocity);
        float velo_s = vdot(velo, direction);
        float spring_force = (b->target_length - length) * b->stiffness;
        float damp_force = velo_s * b->damping;
        // if(is_cable)
        if(length > 10.0f && spring_force > 0.0f)
        {
            spring_force = 0.0f;
            damp_force = 0.0f;
        }
        Vec3f force_vector_spring = vmul(direction, spring_force);
        Vec3f force_vector_damp = vmul(direction, damp_force);
        b->node_a->force = vadd(b->node_a->force, force_vector_spring);
        b->node_b->force = vsub(b->node_b->force, force_vector_spring);
        // if(is_spring)
        if(b->stiffness < 1.0e6f)
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
        /* temp wheel stuff
        if(n->fixed && n->position.y < 0.3f)
        {
            n->velocity.y = 0.0f;
            n->position.y = 0.3f;
        }
        */
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
