//
//  ShapeVAOs.h
//  MachineMash
//
//  Created by Schell Scivally on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __SHAPEVAOS_CLASS__
#define __SHAPEVAOS_CLASS__

#include <OpenGLES/ES2/gl.h>
/**
 *	A class for holding one-color shape vertex array objects.
 *  All shapes are normalized to the unit square.
 *  
 *	@author Schell Scivally
 */
class ShapeVAOs {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /**
     *  Constructor
     */
    ShapeVAOs();
    /**
     *	Returns a pointer to the shared instance of ShapeVAOs.
     *
     *	@return ShapeVAOs A shared instance.
     */
    static ShapeVAOs* sharedInstance();
    /**
     *	Returns the id of a circle shape VAO.
     *
     *	@return GLuint
     */
    GLuint circle();
    //--------------------------------------
    //  Variables
    //--------------------------------------
private:
    GLuint _circle;
};

#endif