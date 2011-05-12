//
//  Sprite.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/9/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#include "Sprite.h"

Sprite::Sprite():matrixUniformName(""),alphaUniformName(""),_haveUniformLocations(false) {
}

Sprite::~Sprite(){}

void Sprite::setUniformNames(std::string matrixName, std::string alphaName) {
    this->matrixUniformName = matrixName;
    this->alphaUniformName = alphaName;
}

unsigned int Sprite::addVBO(VertexBufferObject vbo) {
    this->vbos.push_back(vbo);
    return this->vbos.size()-1;
}

VertexBufferObject* Sprite::getVBOPtr(unsigned int index) {
    return &this->vbos.at(index);
}

void Sprite::draw() {
    if (matrixUniformName == "") {
        printf("Sprite::draw() matrixUniformName has not been set! Aborting draw op.\n");
        return;
    }
    if (alphaUniformName == "") {
        printf("Sprite::draw() alphaUniformName has not been set! Aborting draw op.\n");
        return;
    }
    size_t n = this->vbos.size();
    for (size_t i = 0; i < n; i++) {
        VertexBufferObject* vbo = &this->vbos.at(i);
        // check to see if we need to switch programs
        if (vbo->switchToProgram() || !this->_haveUniformLocations) {
            // update uniform location
            this->_matrixUniformLocation = glGetUniformLocation(vbo->glProgram, this->matrixUniformName.c_str());
            this->_alphaUniformLocation = glGetUniformLocation(vbo->glProgram, this->alphaUniformName.c_str());
        }
        // update uniforms
        glUniformMatrix4fv(this->_matrixUniformLocation, 1, GL_FALSE, &this->matrix.elements[0]);
        glUniform1f(this->_alphaUniformLocation, this->alpha);
        // draw
        this->vbos.at(i).draw();
    }
}