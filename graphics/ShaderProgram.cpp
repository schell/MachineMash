//
//  ShaderProgram.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/16/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#include "ShaderProgram.h"
#include "Types.h"
#include "ErrorHandler.h"

std::map<std::string, ShaderProgram> ShaderProgram::__storedPrograms;

ShaderProgram::ShaderProgram() {
    this->_name = glCreateProgram();
}

ShaderProgram::~ShaderProgram() {}

void ShaderProgram::setVertexShader(std::string vsh) {
    if (!compileShader(&_vertShader, GL_VERTEX_SHADER, vsh)) {
        printf("ShaderProgram::serVertexShader() could not compile shader.\n");
    }
}

void ShaderProgram::setFragmentShader(std::string fsh) {
    if (!compileShader(&_fragShader, GL_FRAGMENT_SHADER, fsh)) {
        printf("ShaderProgram::setFragmentShader() could not compile shader.\n");
    }
}

bool ShaderProgram::compileShader(GLuint* shader, GLenum type, std::string src) {
    GLint status;
    const GLchar* source = src.c_str();
	
    if (!source) {
        printf("ShaderProgram::compileShader() failed to load %s shader",type == GL_FRAGMENT_SHADER ? "fragment" : "vertex");
        return false;
    }
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
	
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    GLchar *log = (GLchar *)malloc(logLength);
    glGetShaderInfoLog(*shader, logLength, &logLength, log);
    printf("ShaderProgram::compileShader() shader compile log:\n%s", log);
    free(log);
	
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return false;
    }
	
    return true;
}

void bindAtrributes(GLuint program) {
    glBindAttribLocation(program, ShaderProgramAttributePosition, "position");
    glBindAttribLocation(program, ShaderProgramAttributeColor, "color");
    ErrorHandler::checkErr("ProgramShader::bindAttributes()");
}

bool ShaderProgram::link() {
    glAttachShader(this->_name, this->_vertShader);
    glAttachShader(this->_name, this->_fragShader);
    bindAtrributes(this->_name);
    
    GLint logLength,status;
    glLinkProgram(this->_name);
    glGetProgramiv(this->_name, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(this->_name, logLength, &logLength, log);
        printf("ShaderProgram::link() program link log:\n%s", log);
        free(log);
    }
	
    glGetProgramiv(this->_name, GL_LINK_STATUS, &status);
    if (status == 0) {
        glDeleteShader(this->_vertShader);
        glDeleteShader(this->_fragShader);
        if (this->_name) {
            glDeleteProgram(this->_name);
            this->_name = 0;
        }
        return false;
    }
    
    glValidateProgram(this->_name);
    glGetProgramiv(this->_name, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(this->_name, logLength, &logLength, log);
        printf("ShaderProgram::link() program validate log:\n%s", log);
        free(log);
    }
	
    glGetProgramiv(this->_name, GL_VALIDATE_STATUS, &status);
    
    glDeleteShader(this->_vertShader);
    glDeleteShader(this->_fragShader);
	
    return status != 0;
}

GLuint ShaderProgram::name() {
    return this->_name;
}

GLuint ShaderProgram::uniform(std::string uniform) {
    std::map<std::string,GLuint>::iterator it = this->_uniformLocations.find(uniform);
    if (it == this->_uniformLocations.end()) {
        this->_uniformLocations[uniform] = glGetUniformLocation(this->_name, uniform.c_str());
        it = this->_uniformLocations.find(uniform);
    }
    return (*it).second;
}

ShaderProgram* ShaderProgram::namedInstance(std::string programName) {
    std::map<std::string,ShaderProgram>::iterator it = ShaderProgram::__storedPrograms.find(programName);
    if (it == ShaderProgram::__storedPrograms.end()) {
        ShaderProgram::__storedPrograms[programName] = ShaderProgram();
        it = ShaderProgram::__storedPrograms.find(programName);
    }
    return &(*it).second;
}