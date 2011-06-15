//
//  UserJoint.cpp
//  MachineMash
//
//  Created by Schell Scivally on 4/26/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#include "UserJoint.h"
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
}