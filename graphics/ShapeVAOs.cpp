//
//  ShapeVAOs.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ShapeVAOs.h"
#include <OpenGLES/ES2/glext.h>
#include "Geometry.h"
#include "Types.h"

ShapeVAOs* ShapeVAOs::sharedInstance() {
    static ShapeVAOs* shared = NULL;
    if (shared == NULL) {
        shared = new ShapeVAOs();
    }
    return shared;
}

ShapeVAOs::ShapeVAOs() {
    this->_circle = 0;
}

GLuint ShapeVAOs::circle() {
    if (this->_circle == 0) {
        std::vector<float> circle = Geometry::circle(1.0);
        glGenVertexArraysOES(1, &this->_circle);
        glBindVertexArrayOES(this->_circle);
        GLuint buffer;
        glGenBuffers(1, &buffer);
        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(float)*circle.size(), &circle[0], GL_STATIC_DRAW);
        glEnableVertexAttribArray(ShaderProgramAttributePosition);
        glVertexAttribPointer(ShaderProgramAttributePosition, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), 0);
        glDisableVertexAttribArray(ShaderProgramAttributeColor);
        glVertexAttrib4f(ShaderProgramAttributeColor, 1.0, 1.0, 1.0, 1.0); 
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArrayOES(0);
    }
    return this->_circle;
}