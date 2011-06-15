//
//  Texture.h
//  MachineMash
//
//  Created by Schell Scivally on 5/18/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __MOD_MASH_TEXTURE_CLASS__
#define __MOD_MASH_TEXTURE_CLASS__

#include <OpengLES/ES2/gl.h>
#include <string>
#include <map>

/**
 *	An OpenGLES2 texture wrapper.
 *  
 *	@author Schell Scivally
 */
class Texture {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /** 
     *  Constructors
     */
    Texture();
    Texture(GLuint width, GLuint height, GLubyte* textureData);
    /**
     *  Deconstructor
     */
    ~Texture();
    /**
     *	Returns this texture's id.
     *
     *	@return GLuint The id.
     */
    GLuint id();
    GLuint name();
    /**
     *	Returns this texture's width.
     *
     *	@return GLuint The width.
     */
    GLuint width();
    /**
     *	Returns this texture's height.
     *
     *	@return GLuint The height.
     */
    GLuint height();
    /**
     *	Sets the textures width, height, and data.
     *  Creates a texture in OpenGLES2.
     *
     *	@param  GLuint width
     *	@param  GLuint height
     *	@param  GLubyte* texData
     *	@return void 
     */
    void setData(GLuint width, GLuint height, GLubyte* texData);
    /**
     *	Returns whether or not this texture is valid.
     *
     *	@return bool
     */
    bool isValid();
    /**
     *	Store the texture by name.
     *  Retrieve with fetchByName.
     *
     *	@param  std::string name
     */
    void storeWithName(std::string name);
    /**
     *	Returns a named texture stored with storeWithName.
     *
     *	@param  std::string name
     */
    static Texture fetchByName(std::string name);
    //--------------------------------------
    //  Variables
    //--------------------------------------
private:
    /** This texture id */
    GLuint _id;
    /** Texture width */
    GLuint _width;
    /** Texture height */
    GLuint _height;
    /** Stored textures */
    static std::map<std::string, Texture> __textures;
};

#endif