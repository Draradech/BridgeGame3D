#ifndef _SPRINGPHYSICS_H_
#define _SPRINGPHYSICS_H_

#include <godot_cpp/classes/ref_counted.hpp>
#include "Vec3f.h"

typedef struct
{
   Vec3f position;
   Vec3f velocity;
   Vec3f force;
   float own_mass;
   float mass;
   bool fixed;
} PhysNode;

typedef struct
{
   PhysNode* node_a;
   PhysNode* node_b;
   float mass;
   float stiffness;
   float damping;
   float target_length;
} PhysBeam;

namespace godot
{
    class SpringPhysics: public RefCounted
    {
        GDCLASS(SpringPhysics, RefCounted);

        private:
            float gravity;
            float velo_damping;
            float velo_factor;
            bool z_fix;
            PhysNode* nodes;
            PhysBeam* beams;
            void update_masses();
            void update_forces();
            void integrate(float delta);
            int num_nodes;
            int num_beams;
            float node_mass;
        
        protected:
            static void _bind_methods();
        
        public:
            SpringPhysics();
            ~SpringPhysics();
            void construct(float gravity, float velo_damping, bool z_fix, float node_mass);
            void addNode(Vector3 position, bool fixed, float own_mass);
            void addBeam(int index_a, int index_b, float mass_per_m, float stiffness, float damping);
            void sim_step(float delta, int batching);
            void add_mass(int i, float add_mass);
            void break_beam(int i);
            int get_num_nodes();
            float get_node_mass(int i);
            Vector3 get_node_position(int i);
            bool get_node_fixed(int i);
            int get_num_beams();
            Vector3 get_beam_pos_a(int i);
            Vector3 get_beam_pos_b(int i);
            float get_beam_length(int i);
            float get_beam_force(int i);
    };
}

#endif /* _SPRINGPHYSICS_H_ */