//
//  Machine.cpp
//  MachineMash
//
//  Created by Schell Scivally on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Machine.h"
#include "BlitAnimation.h"
#include "UserAnimations.h"
#include "UserBody.h"

#define PTM_RATIO 32.0f

std::vector<Machine> Machine::__machineStore;

#pragma -
#pragma Lifecycle

Machine::Machine(b2World* world) {
    // the cpu
    b2BodyDef bd;
    bd.position.Set(0.0f, 0.25f + 0.5f);
    bd.type = b2_dynamicBody;
    _cpu = world->CreateBody(&bd);
    
    b2PolygonShape shape;
    shape.SetAsBox(0.25f, 0.25f);
    _cpu->CreateFixture(&shape,  Machine::densityOf(MachineMaterialMetal));
    
    b2Body* body;
    bd.position.Set(0.0f, 0.25f + 0.125f);
    body = world->CreateBody(&bd);
    shape.SetAsBox(1.0f, 0.25f);
    body->CreateFixture(&shape, Machine::densityOf(MachineMaterialWood));
    
    b2CircleShape round;
    b2Body* lw;
    BlitAnimation* tire1 = UserAnimations::sharedInstance().tire1(); // to make sure it's created
    tire1 = (BlitAnimation*)0; // so no 'unused var' warning
    UserBody* userTire = new UserBody("tire1");
    userTire->scaleX = PTM_RATIO*0.5*2;
    userTire->scaleY = PTM_RATIO*0.5*2;
    b2FixtureDef fd;
    fd.friction = 2.0;
    fd.density = Machine::densityOf(MachineMaterialWood);
    bd.position.Set(-1.5f, 0.25f);
    round.m_radius = 0.5f;
    lw = world->CreateBody(&bd);
    lw->SetUserData(userTire);
    fd.shape = &round;
    lw->CreateFixture(&fd);
    
    b2Body* rw;
    bd.position.Set(1.5f, 0.25f);
    rw = world->CreateBody(&bd);
    rw->SetUserData(userTire);
    rw->CreateFixture(&fd);
    
    b2WeldJointDef wjd;
    wjd.Initialize(_cpu, body, body->GetPosition() + (_cpu->GetPosition() - body->GetPosition()));
    world->CreateJoint(&wjd);
    
    b2RevoluteJointDef rjd;
    rjd.enableMotor = true;
    rjd.maxMotorTorque = 100.0;
    rjd.motorSpeed = -40.0;
    rjd.Initialize(body, lw, lw->GetPosition());
    b2Joint* joint = world->CreateJoint(&rjd);
    UserJoint* uJoint = new UserJoint();
    joint->SetUserData(uJoint);
    _joints.push_back(joint);
    
    rjd.Initialize(body, rw, rw->GetPosition());
    joint = world->CreateJoint(&rjd);
    uJoint = new UserJoint();
    joint->SetUserData(uJoint);
    _joints.push_back(joint);
}

Machine::~Machine() {
    _cpu = NULL;
    _joints.clear();
}

Machine* Machine::create(b2World* world) {
    size_t index = __machineStore.size();
    __machineStore.push_back(Machine(world));
    return &__machineStore[index];
}

#pragma -
#pragma Access

b2Body* Machine::cpu() {
    return _cpu;
}

float Machine::densityOf(MachineMaterial material) {
    switch (material) {
        case MachineMaterialNone:
            return 0.0f;
        case MachineMaterialPlastic:
            return 0.3f;
        case MachineMaterialWood:
            return 1.0f;
        case MachineMaterialMetal:
            return 3.0f;
            
        default:
            break;
    }
    return 0.0f;
}