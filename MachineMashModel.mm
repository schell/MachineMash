//
//  MachineMashModel.m
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import "MachineMashModel.h"
#import "LevelWithRadialGravity.h"

static MachineMashModel* sharedModel = nil;

@implementation MachineMashModel

#pragma -
#pragma Lifecycle

- (id)init {
    self = [super init];
    b2Vec2 gravity;
    gravity.Set(0.0f, -10.f);
    bool doSleep = true;
    acceleration = CGPointMake(0, 0);
    [UIAccelerometer sharedAccelerometer].delegate = self;
    world = new b2World(gravity, doSleep);
    world->SetContinuousPhysics(true);
    level = [[Level alloc] initWithWorld:world];
    world->SetGravity([level gravityVector]);
    return self;
}

#pragma -
#pragma Class Methods

+ (MachineMashModel*)sharedModel {
    if (sharedModel == nil) {
        sharedModel = [[MachineMashModel alloc] init];
    }
    return sharedModel;
}

#pragma -
#pragma Setup

- (void)setGLESAPI:(int)api {
    switch (api) {
        case 1:
            [Renderer use:[Renderer ES1Renderer]];
            break;
            
        case 2:
            [Renderer use:[Renderer ES2Renderer]];
            break;
        default:
            [NSException raise:@"could not set GLES API" format:@"%i is not a GLES version"];
            break;
    }
}

#pragma -
#pragma Acceleration
#define kFilterFactor 0.28
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)accel {
    // low pass filter
    acceleration.x = accel.x * kFilterFactor + acceleration.x * (1.0 - kFilterFactor);
    acceleration.y = accel.y * kFilterFactor + acceleration.y * (1.0 - kFilterFactor);
}

- (CGFloat)accelerationAngle {
    return atan2(acceleration.y, acceleration.x)*180/M_PI;
}

#pragma -
#pragma Stepping

- (void)physicsStep {
    if ([level handlesSteppingWorld]) {
        [level step];
        return;
    }
    
    //TODO - fix this time-step
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	float32 timeStep = 1.0f / 60.f;
    int32 velocityIterations = 10;
    int32 positionIterations = 8;
	world->Step(timeStep, velocityIterations, positionIterations);
	
	//iterate over the bodies in the physics world and do stuff
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        
	}
    //iterate over the joints and apply damage
    for (b2Joint* j = world->GetJointList(); j; j = j->GetNext()) {
        float force = j->GetReactionForce(1.0).Length();
        UserJoint* uj = (UserJoint*)j->GetUserData();
        
        if (uj && force > uj->threshold) {
            float damage = force - uj->threshold;
            uj->hp -= damage;
            NSLog(@"%s takes %f damage",uj->tag.c_str(),damage);
            if (uj->hp <= 0.0) {
                NSLog(@"%s is destroyed",uj->tag.c_str());
            }
        }
    }
}

- (void)step {
    // draw stuff
    [[Renderer sharedRenderer] render:world];
    // set the level's accelerationAngle
    level.accelerationAngle = [self accelerationAngle];
    if (paused) {
        return;
    }
    // step box2d
    [self physicsStep];
}

#pragma -
#pragma Access

- (b2World*)world {
    return world;
}

- (Level*)level {
    return level;
}

#pragma -
#pragma Control

- (void)togglePause {
    paused = !paused;
}

@end
