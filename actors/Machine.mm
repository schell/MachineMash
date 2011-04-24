//
//  Machine.m
//  MachineMash
//
//  Created by Schell Scivally on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Machine.h"

@implementation Machine

#pragma -
#pragma Lifecycle

- (id)initWithWorld:(b2World*)world {
    self = [super init];
    
    // the cpu
    b2BodyDef bd;
    bd.position.Set(0.0f, 0.25f + 0.5f);
    bd.type = b2_dynamicBody;
    _cpu = world->CreateBody(&bd);
    
    b2PolygonShape shape;
    shape.SetAsBox(0.25f, 0.25f);
    _cpu->CreateFixture(&shape, [self densityOf:MachineMaterialMetal]);
    
    b2Body* body;
    bd.position.Set(0.0f, 0.25f + 0.125f);
    body = world->CreateBody(&bd);
    shape.SetAsBox(1.0f, 0.25f);
    body->CreateFixture(&shape, [self densityOf:MachineMaterialWood]);
    
    b2CircleShape round;
    b2Body* lw;
    b2FixtureDef fd;
    fd.friction = 2.0;
    fd.density = [self densityOf:MachineMaterialWood];
    bd.position.Set(-1.5f, 0.25f);
    round.m_radius = 0.5f;
    lw = world->CreateBody(&bd);
    fd.shape = &round;
    lw->CreateFixture(&fd);
    
    b2Body* rw;
    bd.position.Set(1.5f, 0.25f);
    rw = world->CreateBody(&bd);
    rw->CreateFixture(&fd);
    
    b2WeldJointDef wjd;
    wjd.Initialize(_cpu, body, body->GetPosition() + (_cpu->GetPosition() - body->GetPosition()));
    world->CreateJoint(&wjd);
    
    b2RevoluteJointDef rjd;
    rjd.enableMotor = true;
    rjd.maxMotorTorque = 100.0;
    rjd.motorSpeed = -40.0;
    rjd.Initialize(body, lw, lw->GetPosition());
    world->CreateJoint(&rjd);
    
    rjd.Initialize(body, rw, rw->GetPosition());
    world->CreateJoint(&rjd);
    
    _controls = [[NSMutableSet set] retain];
    
    return self;
}

- (void)dealloc {
    _cpu = NULL;
    [_controls release];
    [super dealloc];
}

#pragma -
#pragma Access

- (b2Body*)cpu {
    return _cpu;
}

- (float32)densityOf:(MachineMaterial)material {
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

@end
