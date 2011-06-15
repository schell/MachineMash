//
//  UserAnimations.h
//  MachineMash
//
//  Created by Schell Scivally on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __MOD_MASH_USER_ANIMATIONS_CLASS__
#define __MOD_MASH_USER_ANIMATIONS_CLASS__

#include "BlitAnimation.h"

/**
 *	A collection of userland animations.
 *  
 *	@author Schell Scivally
 */
class UserAnimations {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /**
     *	A shared instance of UserAnimations.
     *  Static.
     *
     *	@return UserAnimations the static shared instance.
     */
    static UserAnimations sharedInstance();
    /**
     *	An animation of a tire.
     *  3 frames.
     */
    BlitAnimation* tire1();
private:
};

#endif
