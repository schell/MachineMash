//
//  UserJoint.cpp
//  MachineMash
//
//  Created by Schell Scivally on 4/26/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#include "UserJoint.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <Box2D/Box2D.h>
#include "Graphics.h"

UserJoint::UserJoint() {
    this->tag = "userjoint";
    this->threshold = 20.0;
    this->hp = 50.0;
}

UserJoint::UserJoint(float threshold, float hp) {
    this->tag = "userjoint";
    this->threshold = threshold;
    this->hp = hp;
}

UserJoint::~UserJoint() {}

void UserJoint::draw(void* parentPtr) {
    b2Joint* joint = (b2Joint*)parentPtr;
    b2Body* bodyA = joint->GetBodyA();
	b2Body* bodyB = joint->GetBodyB();
	const b2Transform& xf1 = bodyA->GetTransform();
	const b2Transform& xf2 = bodyB->GetTransform();
	b2Vec2 x1 = xf1.position;
	b2Vec2 x2 = xf2.position;
	b2Vec2 p1 = joint->GetAnchorA();
	b2Vec2 p2 = joint->GetAnchorB();
    
	b2Color color(1.0, 0.0, 1.0);
    
	switch (joint->GetType()) {
        case e_distanceJoint:
            //this->DrawSegment(p1, p2, color);
            break;
            
        case e_pulleyJoint: {
			b2PulleyJoint* pulley = (b2PulleyJoint*)joint;
			b2Vec2 s1 = pulley->GetGroundAnchorA();
			b2Vec2 s2 = pulley->GetGroundAnchorB();
			//this->DrawSegment(s1, p1, color);
			//this->DrawSegment(s2, p2, color);
			//this->DrawSegment(s1, s2, color);
		}
            break;
            
        case e_mouseJoint:
            // don't draw this
            break;
            
        default:
            Matrix modelview;
            //this->DrawSegment(x1, p1, color);
            //this->DrawSegment(p1, p2, color);
            //this->DrawSegment(x2, p2, color);
	}
}