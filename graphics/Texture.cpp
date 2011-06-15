//
//  Texture.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Texture.h"

std::map<std::string, Texture> Texture::__textures;

Texture::Texture():_width(0),_height(0),_id(0) {}

Texture::Texture(GLuint width, GLuint height, GLubyte* texData) {
    this->setData(width, height, texData);
}

Texture::~Texture() {}

GLuint Texture::id() {
    return this->name();
}

GLuint Texture::name() {
    return this->_id;
}

GLuint Texture::width() {
    return this->_width;
}

GLuint Texture::height() {
    return this->_height;
}

void Texture::setData(GLuint width, GLuint height, GLubyte* texData) {
    this->_width = width;
    this->_height = height;
    glGenTextures(1, &this->_id);
    glBindTexture(GL_TEXTURE_2D, this->_id);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, this->_width, this->_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texData);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
}

bool Texture::isValid() {
    return !(this->_width == 0 || this->_height == 0 || this->_id == 0);
}

void Texture::storeWithName(std::string name) {
    __textures[name] = (*this);
}

Texture Texture::fetchByName(std::string name) {
    std::map<std::string, Texture>::iterator it = __textures.find(name);
    if (it != __textures.end()) {
        return (*it).second;
    }
    return Texture();
}