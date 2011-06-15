//
//  BlitAnimation.h
//  MachineMash
//
//  Created by Schell Scivally on 6/11/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __MOD_MASH_BLIT_ANIMATION_CLASS__
#define __MOD_MASH_BLIT_ANIMATION_CLASS__

#include <OpenGLES/ES2/gl.h>
#include <vector>
#include <time.h>
#include <string>
#include "Blit.h"
#include "Texture.h"

/**
 *	An animation of Blits.
 *  A container of Blits that animates over time.
 *  
 *	@author Schell Scivally
 */
class BlitAnimation {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /**
     *	Constructor.
     */
    BlitAnimation(float secondsPerBlit);
    /**
     *	Adds a blit (frame).
     */
    void addBlit(Blit blit);
    void addBlit(GLuint vao, Texture texture);
    void addBlit(std::vector<GLfloat> verts, std::vector<GLfloat> coords, std::vector<GLushort> indices, Texture texture);
    /**
     *	Draws the current blit to the screen.
     *  Does not update any matrix uniforms.
     *  @param GLenum mode - the draw mode (default GL_TRIANGLE_FAN)
     */
    void draw();
    void draw(GLenum mode);
    /**
     *	Returns the current blit frame based on time elapsed and bps.
     *
     *	@return clock_t currentBlit
     */
    clock_t currentBlit();
    /**
     *	Creates a new BlitAnimation and stores it, returns the pointer.
     *  Used for creating an animation that should be managed internally.
     *
     *  @param float bps - blits per second (fps)
     *	@return BlitAnimation* theBlitAnimation
     */
    static BlitAnimation* create(float bps);
    /**
     *	Steps through all blits and animates them.
     *
     *	@return void 
     */
    static void step();
    /**
     *	Returns a pointer to a named BlitAnimation.
     *
     *	@param  std::string name
     *	@return BlitAnimation* the named animation
     */
    static BlitAnimation* fetchByName(std::string name);
    //--------------------------------------
    //  Variables
    //--------------------------------------
    std::vector<Blit> blits;
    float secondsPerBlit;
    GLenum mode;
    GLuint frame;
    std::string name;
private:
    size_t _index;
    static std::vector<BlitAnimation> __animations;
};

#endif