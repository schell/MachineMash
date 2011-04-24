//
//  LevelWithRadialGravity.m
//  MachineMash
//
//  Created by Schell Scivally on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LevelWithRadialGravity.h"
#import "Renderer.h"

#define GRAVITY_SCALAR 10.0f

@implementation LevelWithRadialGravity

- (b2Vec2)gravityVector {
    return b2Vec2(0.0, 0.0);
}

- (BOOL)orientationFollowsActualGravity {
    return YES;
}

- (BOOL)handlesSteppingWorld {
    return YES;
}

b2RevoluteJoint* lm;
b2RevoluteJoint* rm;
- (void)setup {
    planet = NULL;
    actor = NULL;
    /* define the planet */ {
        b2BodyDef bd;
        bd.type = b2_staticBody;
        planet = world->CreateBody(&bd);
        
        b2CircleShape round;
        round.m_radius = 100.0f;
        planet->CreateFixture(&round, 0);
    }
    
    /* define the actor */ {
        b2BodyDef bd;
        b2Body* body;
        b2Body* lw;
        b2Body* rw;
        b2CircleShape round;
        b2PolygonShape box;
        b2RevoluteJointDef jd;
        // fuselage 
        bd.type = b2_dynamicBody;
        bd.position.Set(0.0f, 102.0f);
        body = world->CreateBody(&bd);
        box.SetAsBox(2.0f, 0.2f);
        body->CreateFixture(&box, 10.0f);
        // left wheel
        bd.position.Set(-3.0f, 102.0f);
        lw = world->CreateBody(&bd);
        round.m_radius = 1.0f;
        lw->CreateFixture(&round, 15.0f);
        // right wheel
        bd.position.Set(3.0, 102.0f);
        rw = world->CreateBody(&bd);
        rw->CreateFixture(&round, 15.0f);
        // joints
        jd.maxMotorTorque = 400.0f;
        jd.motorSpeed = 4000.0f;
        jd.enableMotor = true;
        jd.Initialize(lw, body, lw->GetWorldCenter());
        lm = (b2RevoluteJoint*)world->CreateJoint(&jd);
        
        jd.Initialize(rw, body, rw->GetWorldCenter());
        rm = (b2RevoluteJoint*)world->CreateJoint(&jd);
        actor = body;
    }
    
    /* define a brick */ {
        b2BodyDef bd;
        bd.type = b2_dynamicBody;
        bd.position.Set(110.0f, 0.0f);
        
        b2Body* brick = world->CreateBody(&bd);
        
        b2PolygonShape tri;
        b2Vec2 verts[] = {
            b2Vec2(1.0, 1.0),
            b2Vec2(-1.0, -1.0),
            b2Vec2(1.0, -1.0),
        };
        tri.Set(verts, 3);
        brick->CreateFixture(&tri, 10.0f);
    }
    
    // matrix stuff
    mat4LoadIdentity(&matrix);
}

- (void)step {
    Renderer* renderer = [Renderer sharedRenderer];
    // account for the angle the user is holding the device at
    mat4Rotate([renderer preMultiplyMatrix], super.accelerationAngle, 0.0, 0.0, 1.0);
    // move the screen to our actor's position
    CGFloat zoomScale = [renderer zoomScale];
    b2Vec2 p = actor->GetPosition();
    mat4Translate([renderer preMultiplyMatrix], -p.x*zoomScale, -p.y*zoomScale, 0.0);
    // rotate the screen orthog to the planet surface
    float32 worldAngle = atan2f(p.x, p.y)*180/M_PI;
    mat4Rotate([renderer preMultiplyMatrix], worldAngle, 0.0, 0.0, 1.0);
    
    // TODO - fix this time-step
	// http://gafferongames.com/game-physics/fix-your-timestep/

	float32 timeStep = 1.0f/60.0f;
    int32 velocityIterations = 10;
    int32 positionIterations = 8;
	world->Step(timeStep, velocityIterations, positionIterations);
	//iterate over the bodies in the physics world and do stuff
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        b2CircleShape* circle = (b2CircleShape*)planet->GetFixtureList()->GetShape();
        b2Vec2 center = planet->GetWorldPoint(circle->m_p);
        b2Vec2 position = b->GetPosition();
        b2Vec2 d = center - position;
        d.Normalize();
        b2Vec2 gravity = b->GetMass() * GRAVITY_SCALAR * d;
        b->SetAwake(true);
        b->ApplyForce(gravity, position);
	}
}

- (void)touchesBegan:(NSSet *)touches inView:(UIView *)view {
    NSLog(@"%s",__FUNCTION__);
}

- (void)touchesMoved:(NSSet*)touches inView:(UIView *)view {
    return; // !!!
    if ([touches count] < 2) {
        UITouch* touch = [touches anyObject];
        CGPoint lastPoint = [touch previousLocationInView:view];
        CGPoint thisPoint = [touch locationInView:view];
        CGPoint diffPoint = CGPointMake(thisPoint.x - lastPoint.x, thisPoint.y - lastPoint.y);
        mat4Translate(&matrix, -diffPoint.x, diffPoint.y, 0);
        mat4Print(&matrix);
    }
}

- (void)touchesEnded:(NSSet *)touches inView:(UIView *)view {
    NSLog(@"%s",__FUNCTION__);
}
@end
