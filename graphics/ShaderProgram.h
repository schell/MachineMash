//
//  Shader.h
//  MachineMash
//
//  Created by Schell Scivally on 5/16/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __SHADER_CLASS__
#define __SHADER_CLASS__

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <string>
#include <vector>
#include <map>
#include "Types.h"

/**
 *	A wrapper for OpenGLES2 shader programs.
 *
 *  @author Schell Scivally
 */
class ShaderProgram {
public:
    ShaderProgram();
    ~ShaderProgram();
    bool setVertexShader(std::string vsh);
    bool setFragmentShader(std::string fsh);
    bool compileShader(GLuint* shader, GLenum type, std::string src);
    bool link(bindBlockPtr bindBlock);
    bool compileProgram(std::string vshFile, std::string fshFile, bindBlockPtr bindBlock);
    GLuint name();
    GLuint uniform(std::string);
    void use();
    static ShaderProgram* namedInstance(std::string programName);
protected:
    GLuint _name;
    GLuint _vertShader;
    GLuint _fragShader;
    std::map<std::string,GLuint> _uniformLocations;
    static std::map<std::string, ShaderProgram> __storedPrograms;
    static GLuint __currentProgramName;
};

#endif