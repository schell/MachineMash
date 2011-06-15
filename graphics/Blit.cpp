//
//  Blit.cpp
//  MachineMash
//
//  Created by Schell Scivally on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Blit.h"
#include <OpenGLES/ES2/glext.h>
#include "Buffer.h"
#include "ShaderProgram.h"

Blit::Blit():vao(0){}

Blit::Blit(GLuint vao, Texture texture):vao(vao),texture(texture){}

Blit::Blit(std::vector<GLfloat> verts, std::vector<GLfloat> coords, std::vector<GLushort> indices, Texture texture):texture(texture) {
    // interleave the vertex and tex coords
    Buffer<GLfloat> texBuff(verts, 2);
    texBuff.interleaveData(coords, 2);
    
    glGenVertexArraysOES(1, &this->vao);
    glBindVertexArrayOES(this->vao);
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*texBuff.data.size(), &texBuff.data[0], GL_STATIC_DRAW);
    glEnableVertexAttribArray(ShaderProgramAttributePosition);
    glVertexAttribPointer(ShaderProgramAttributePosition, 2, GL_FLOAT, GL_FALSE, texBuff.stride(), 0);
    glEnableVertexAttribArray(ShaderProgramAttributeTexCoord);
    glVertexAttribPointer(ShaderProgramAttributeTexCoord, 2, GL_FLOAT, GL_FALSE, texBuff.stride(), (GLvoid*)(2*sizeof(GLfloat)));
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    GLuint ndxBuffer;
    glGenBuffers(1, &ndxBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ndxBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort)*indices.size(), &indices[0], GL_STATIC_DRAW);
    
    glBindVertexArrayOES(0);
}

void Blit::draw() {
    this->draw(GL_TRIANGLE_FAN);
}

void Blit::draw(GLenum mode) {
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, this->texture.name());
    glBindVertexArrayOES(this->vao);
    glDrawElements(mode, 4, GL_UNSIGNED_SHORT, (void*)0);
    glBindVertexArrayOES(0);
}