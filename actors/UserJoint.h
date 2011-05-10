//
//  UserJoint.h
//  MachineMash
//
//  Created by Schell Scivally on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <string>

class UserJoint {
public:
    float threshold;
    float hp;
    std::string tag;
    
    UserJoint();
    UserJoint(float threshold, float hp);
    ~UserJoint();
};