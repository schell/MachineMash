//
//  DrawableUserData.h
//  MachineMash
//
//  Created by Schell Scivally on 5/16/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __DRAWABLE_USER_DATA_CLASS__
#define __DRAWABLE_USER_DATA_CLASS__

#include "DrawableUserData.h"
/**
 *	A base class for drawable things.
 *  
 *	@author Schell Scivally
 */
class DrawableUserData {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /**
     *  Constructor
     */
    DrawableUserData();
    /**
     *  Deconstructor
     */
    ~DrawableUserData();
    /**
     *	Draws the object to the screen.
     *
     *  @param void* A pointer to this user data's parent.
     *	@return void 
     */
    virtual void draw(void* parentPtr)=0;
    //--------------------------------------
    //  Variables   
    //--------------------------------------
    float scaleX;
    float scaleY;
};

#endif