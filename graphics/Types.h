//
//  Types.h
//  MachineMash
//
//  Created by Schell Scivally on 5/16/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __MODMASH_TYPES__
#define __MODMASH_TYPES__

#include <OpenGLES/ES2/gl.h>

typedef enum {
    ShaderProgramUniformProjection,
    ShaderProgramUniformCamera,
    ShaderProgramUniformModelview,
    ShaderProgramUniformAlpha,
    ShaderProgramUniformCount
} ShaderProgramUniform;

typedef enum {
    ShaderProgramAttributePosition,
    ShaderProgramAttributeColor,
    ShaderProgramAttributeTexCoord,
    ShaderProgramAttributeCount
} ShaderProgramAttribute;

#endif