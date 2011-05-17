//
//  UserJoint.h
//  MachineMash
//
//  Created by Schell Scivally on 4/26/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __USER_JOINT_CLASS__
#define __USER_JOINT_CLASS__

#include <string>
#include "DrawableUserData.h"

class UserJoint : public DrawableUserData {
public:
    float threshold;
    float hp;
    std::string tag;
    
    UserJoint();
    UserJoint(float threshold, float hp);
    ~UserJoint();
    void draw(void* parentPtr);
};

#endif