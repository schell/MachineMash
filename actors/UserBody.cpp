//
//  UserBody.cpp
//  MachineMash
//
//  Created by Schell Scivally on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "UserBody.h"
#include <Box2D/Box2D.h>
#include <OpenGLES/ES2/gl.h>

UserBody::UserBody():DrawableUserData(),_animation((BlitAnimation*)0),_animationName("") {}

UserBody::UserBody(std::string animationName):DrawableUserData(),_animation((BlitAnimation*)0),_animationName(animationName) {}

UserBody::~UserBody() {}

BlitAnimation* UserBody::animation() {
    if (this->_animation == (BlitAnimation*)0) {
        this->_animation = BlitAnimation::fetchByName(this->_animationName);
    }
    return this->_animation;
}

void UserBody::draw(void* parentPtr) {

}