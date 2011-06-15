//
//  UserBody.h
//  MachineMash
//
//  Created by Schell Scivally on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __MOD_MASH_USER_BODY_CLASS__
#define __MOD_MASH_USER_BODY_CLASS__

#include <string>
#include "DrawableUserData.h"
#include "BlitAnimation.h"

/**
 *	Userland data for b2Body.
 *  
 *	@author Schell Scivally
 */
class UserBody : public DrawableUserData {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /**
     *  Constructor
     */
    UserBody();
    UserBody(std::string animationName);
    /**
     *  Deconstructor
     */
    ~UserBody();
    /**
     *	Draws the body.
     *
     *	@param  void* pointer to the b2Body this userData belongs to
     *	@return void 
     */
    void draw(void* parentPtr);
    /**
     *	Returns this UserBody's animation.
     *
     *	@return BlitAnimation* animation
     */
    BlitAnimation* animation();
    //--------------------------------------
    //  Variables
    //--------------------------------------
private:
    std::string _animationName;
    BlitAnimation* _animation;
};

#endif