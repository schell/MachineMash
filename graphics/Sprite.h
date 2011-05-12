//
//  Sprite.h
//  MachineMash
//
//  Created by Schell Scivally on 5/9/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __SPRITE_CLASS__
#define __SPRITE_CLASS__

#include <OpenGLES/ES2/gl.h>
#include <vector>
#include <string>
#include "VertexBufferObject.h"
#include "Matrix.h"
/**
 *	The canonic graphical element.
 *  The Sprite object is a collection of VertexBufferObjects that can 
 *  be drawn with a modelview matrix and alpha.
 *  
 *	@author Schell Scivally
 */
class Sprite {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /**
     *  Sprite constructor.
     */
    Sprite();
    /**
     *	Sprite constructor.
     *  Sets matrixUniformName and alphaUniformName as the Sprite
     *  needs to know where to update its matrix.
     *
     *	@param  std::string matrixUniformName
     *	@param  std::string alphaUniformName
     */
    Sprite(std::string matrixUniformName, std::string alphaUniformName);
    /**
     *	Sprite deconstructor.
     */
    ~Sprite();
    /**
     *	Sets the matrix and alpha uniform names.
     *
     *	@param  std::string The name of the matrix uniform.
     *	@param  std::string The name of the alpha uniform.
     *	@return void 
     */
    void setUniformNames(std::string matrixName, std::string alphaName);
    /**
     *	Adds a VertexBufferObject for drawing.
     *  Returns the index of the VBO in <code>vbos</code>.
     *
     *	@param  VertexBufferObject The VBO to add.
     *	@return unsigned int The index of the added VBO in <code>vbos</code>.
     */
    unsigned int addVBO(VertexBufferObject vbo);
    /**
     *	Returns a pointer to a vbo at <code>index</code>.
     *
     *	@param  unsigned int The index of the vbo to get a pointer to.
     *	@return VertexBufferObject* The VBO pointer.
     */
    VertexBufferObject* getVBOPtr(unsigned int index);
    /**
     *	Replaces a VBO.
     *  Replaces the VBO at index <code>index</code> with <code>vbo</code>.
     *
     *	@param  unsigned int The index of the VBO to replace.
     *	@return VertexBufferObject A copy of the VBO at <code>index</code>
     */
    VertexBufferObject replaceVBOAt(unsigned int index, VertexBufferObject vbo);
    /**
     *	Draws the Sprite.
     *  The default draw operation. Updates the modelview matrix and alpha of 
     *  each VBO's shader program and draws each VBO.
     *
     *	@return void
     */
    virtual void draw();
    //--------------------------------------
    //  Variables
    //--------------------------------------
    /** 
     *  The local modelview transformation matrix.
     *  Must have a corresponding uniform in userland shaders. 
     *  @see matrixUniformName 
     */
    Matrix matrix;
    /** 
     *  The opacity.
     *  Must have a corresponding uniform in userland shaders. 
     *  @see alphaUniformName 
     */
    float alpha;
    /** 
     *  The name of the modelview matrix uniform.
     *  This is the name of the matrix Sprite should update in userland shaders. 
     */
    std::string matrixUniformName;
    /** 
     *  The name of the alpha uniform.
     *  This is the name of the alpha uniform Sprite should update in userland shaders. 
     */
    std::string alphaUniformName;
    /** 
     *  A collection of VBOs.
     *  The VBOs this Sprite will draw. 
     */
    std::vector<VertexBufferObject> vbos;
private:
    // the last matrix uniform location
    GLuint _matrixUniformLocation;
    // the last alpha uniform location
    GLuint _alphaUniformLocation;
    // whether or not we've queried opengl for uniform locations
    bool _haveUniformLocations;
};
#endif