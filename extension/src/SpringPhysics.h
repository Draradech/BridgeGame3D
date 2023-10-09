#ifndef _SPRINGPHYSICS_H_
#define _SPRINGPHYSICS_H_

#include <godot_cpp/classes/ref_counted.hpp>
#include <vector>
#include "Vec3d.h"

typedef struct
{
   Vec3d position;
   bool fixed;
   Vec3d velocity;
   Vec3d force;
   Vec3d acc;
   double own_mass;
   double mass;
} PhysNode;

typedef struct
{
   PhysNode* node_a;
   PhysNode* node_b;
   double mass;
   double stiffness;
   double damping;
   double target_length;
   double length;
   double force;
} PhysBeam;

namespace godot
{
    class SpringPhysics: public RefCounted
    {
        GDCLASS(SpringPhysics, RefCounted);

        private:
            double gravity;
            double velo_damping;
            bool z_fix;
            std::vector<PhysNode> nodes;
            std::vector<PhysBeam> beams;
            void update_masses();
            void update_forces();
            void integrate(double delta);
        
        protected:
            static void _bind_methods();
        
        public:
            SpringPhysics();
            ~SpringPhysics();
            void setParameters(double gravity, double velo_damping, bool z_fix);
            void addNode(Vector3 position, bool fixed, double own_mass);
            void addBeam(int index_a, int index_b, double mass_per_m, double stiffness, double damping);
            void sim_step(double delta, int batching);
            void add_mass(int add_mass_index, double add_mass);
            void delete_beam(int delete_index);
            int get_num_nodes();
            double get_node_mass(int i);
            Vector3 get_node_position(int i);
            bool get_node_fixed(int i);
            int get_num_beams();
            Vector3 get_beam_pos_a(int i);
            Vector3 get_beam_pos_b(int i);
            double get_beam_length(int i);
            double get_beam_force(int i);
    };
}

#endif /* _SPRINGPHYSICS_H_ */