#include "SpringPhysics.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void SpringPhysics::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("setParameters", "gravity", "velo_damping", "z_fix"), &SpringPhysics::setParameters);
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
    ClassDB::bind_method(D_METHOD("add_mass", "add_mass_index", "add_mass"), &SpringPhysics::add_mass);
    ClassDB::bind_method(D_METHOD("delete_beam", "delete_index"), &SpringPhysics::delete_beam);
}

SpringPhysics::SpringPhysics()
{
}

SpringPhysics::~SpringPhysics()
{
}

void SpringPhysics::setParameters(double gravity, double velo_damping, bool z_fix)
{
    this->gravity = gravity;
    this->velo_damping = velo_damping;
    this->z_fix = z_fix;
}

void SpringPhysics::addNode(Vector3 position, bool fixed, double own_mass)
{
    PhysNode n;
    n.position.x = position.x;
    n.position.y = position.y;
    n.position.z = position.z;
    n.acc = V3D_ZERO;
    n.velocity = V3D_ZERO;
    n.fixed = fixed;
    n.own_mass = own_mass;
    nodes.push_back(n);
}

void SpringPhysics::addBeam(int index_a, int index_b, double mass_per_m, double stiffness, double damping)
{
    PhysBeam b;
    // TODO: these pointers are invalidated if the vector<PhysNode> needs to be reallocated. Guard against that somehow.
    b.node_a = &nodes[index_a];
    b.node_b = &nodes[index_b];

    b.length = distance(b.node_a->position, b.node_b->position);
    b.target_length = b.length;
    b.mass = mass_per_m * b.length;
    b.stiffness = stiffness / b.length;
    b.damping = damping / b.length;
    beams.push_back(b);
}

void SpringPhysics::update_masses()
{
    for(int i = 0; i < nodes.size(); ++i)
    {
        PhysNode* n = &nodes[i];
        n->mass = n->own_mass;
    }
    for(int i = 0; i < beams.size(); ++i)
    {
        PhysBeam* b = &beams[i];
        b->node_a->mass += b->mass / 2;
        b->node_b->mass += b->mass / 2;
    }
}

void SpringPhysics::update_forces()
{
    for(int i = 0; i < nodes.size(); ++i)
    {
        PhysNode* n = &nodes[i];
        n->force = vmul(V3D_DOWN, n->mass * gravity);
    }
    for(int i = 0; i < beams.size(); ++i)
    {
        PhysBeam* b = &beams[i];
        Vec3d b_to_a = vsub(b->node_a->position, b->node_b->position);
        b->length = length(b_to_a);
        Vec3d direction = vdiv(b_to_a, b->length);
        Vec3d velo = vsub(b->node_b->velocity, b->node_a->velocity);
        double velo_s = vdot(velo, direction);
        double spring_force = (b->target_length - b->length) * b->stiffness;
        double damp_force = velo_s * b->damping;
        // if(is_cable)
        if(b->length > 10.0 && spring_force > 0.0)
        {
            spring_force = 0;
            damp_force = 0;
        }
        b->force = spring_force; // + damp_force;
        Vec3d force_vector_spring = vmul(direction, spring_force);
        Vec3d force_vector_damp = vmul(direction, damp_force);
        b->node_a->force = vadd(b->node_a->force, force_vector_spring);
        b->node_b->force = vsub(b->node_b->force, force_vector_spring);
        // if(is_spring)
        if(b->stiffness < 1.0e6)
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

void SpringPhysics::integrate(double delta)
{
    double velo_factor = pow(velo_damping, delta);
    for(int i = 0; i < nodes.size(); ++i)
    {
        PhysNode* n = &nodes[i];
        // if(!n->fixed)
        {
            n->acc = vdiv(n->force, n->mass);
            n->velocity = vadd(n->velocity, vmul(n->acc, delta));
            n->velocity = vmul(n->velocity, velo_factor);
            n->position = vadd(n->position, vmul(n->velocity, delta));
        }
        // temp wheel stuff
        if(n->fixed && n->position.y < 0.3)
        {
            n->velocity.y = 0;
            n->position.y = 0.3;
        }
    }
}

void SpringPhysics::sim_step(double delta, int batching)
{
    for(int i = 0; i < batching; ++i)
    {
        update_masses();
        update_forces();
        integrate(delta);
        if(z_fix)
        {
            for(int i = 0; i < nodes.size(); ++i)
            {
                PhysNode* n = &nodes[i];
                n->force.z = 0;
			    n->velocity.z = 0;
			    n->position.z = 0;
            }
        }
    }
}

int SpringPhysics::get_num_nodes()
{
    return nodes.size();
}

double SpringPhysics::get_node_mass(int i)
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
    return beams.size();
}

Vector3 SpringPhysics::get_beam_pos_a(int i)
{
    return Vector3(beams[i].node_a->position.x, beams[i].node_a->position.y, beams[i].node_a->position.z);
}

Vector3 SpringPhysics::get_beam_pos_b(int i)
{
    return Vector3(beams[i].node_b->position.x, beams[i].node_b->position.y, beams[i].node_b->position.z);
}

double SpringPhysics::get_beam_length(int i)
{
    return beams[i].length;
}

double SpringPhysics::get_beam_force(int i)
{
    return beams[i].force;
}

void SpringPhysics::add_mass(int add_mass_index, double add_mass)
{
    nodes[add_mass_index].own_mass += add_mass;
}

void SpringPhysics::delete_beam(int delete_index)
{
    beams.erase(beams.begin() + delete_index);
}
