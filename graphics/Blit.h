//
//  Blit.h
//  MachineMash
//
//  Created by Schell Scivally on 6/8/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __MOD_MASH_BLIT_CLASS__
#define __MOD_MASH_BLIT_CLASS__

#include <vector>
#include <OpenGLES/ES2/gl.h>
#include "Texture.h"

/**
 *	An image element.
 *  All or part of a 2d texture + drawing functions. 
 *  Lower level than a Sprite or Animation, higher level than
 *  a Texture and VAO.
 *  
 *	@author Schell Scivally
 */
class Blit {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /**
     *	Constructor.
     */
    Blit();
    Blit(GLuint vao, Texture texture);
    Blit(std::vector<GLfloat> verts, std::vector<GLfloat> coords, std::vector<GLushort> indices, Texture texture);
    /**
     *	Draws the blit to the screen.
     *  Does not update any matrix uniforms.
     *  @param GLenum mode - the draw mode (default GL_TRIANGLE_FAN)
     */
    void draw();
    void draw(GLenum mode);
    //--------------------------------------
    //  Variables
    //--------------------------------------
    GLuint vao;
    Texture texture;
private:
};

#endif