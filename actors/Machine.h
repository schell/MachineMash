//
//  Machine.h
//  MachineMash
//
//  Created by Schell Scivally on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __MOD_MASH_MACHINE_CLASS__
#define __MOD_MASH_MACHINE_CLASS__

#import <Box2D/Box2D.h>
#include <vector>
#include "UserJoint.h"

#define HP_SHOW_TIME 2.0

typedef enum {
    MachineMaterialNone,
    MachineMaterialPlastic,
    MachineMaterialWood,
    MachineMaterialMetal
} MachineMaterial;

/**
 *	A collection of controls, bodies and joints, the main
 *  user agent.
 *  
 *	@author Schell Scivally
 */
class Machine {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /**
     *  Constructor
     */
    Machine(b2World* world);
    /**
     *  Deconstructor
     */
    ~Machine();
    /**
     *	Returns the cpu b2Body.
     *
     *	@return b2Body* cpu
     */
    b2Body* cpu();
    /**
     *	Creates and stores a new instance of Machine and returns a pointer.
     *  Used to create an instance to be managed internally.
     *  
     *	@param b2World* world
     */
    static Machine* create(b2World* world);
    /**
     *	Returns density of a given material enum.
     *  kg/m.
     *
     *	@param  MachineMaterial the material
     *	@return float density (kg/m)
     */
    static float densityOf(MachineMaterial material);
    //--------------------------------------
    //  Variables
    //--------------------------------------
private:
    b2Body* _cpu;
    std::vector<b2Joint*> _joints;
    static std::vector<Machine> __machineStore;
};

#endif