//
//  UserJoint.cpp
//  MachineMash
//
//  Created by Schell Scivally on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "UserJoint.h"

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

UserJoint::~UserJoint() {
    
}